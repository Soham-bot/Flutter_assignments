import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_explorer/models/booking.dart';
import 'package:movie_explorer/models/movie.dart';
import 'package:movie_explorer/theme/app_theme.dart';
import 'package:movie_explorer/utils/constants.dart';
import 'package:movie_explorer/widgets/seat_widget.dart';

/// Screen 4: Interactive Ticket Booking Screen
/// Features a 3-step Stepper flow:
/// Step 1: Date & Showtime Pills
/// Step 2: Interactive 8x6 Cinema Seat Grid with Screen Curve & Legend
/// Step 3: Validated Customer Form (Name, Email, 10-digit Phone, Snacks, SMS)
class BookingFormScreen extends StatefulWidget {
  final Movie movie;
  final int initialStep;

  const BookingFormScreen({
    super.key,
    required this.movie,
    this.initialStep = 0,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  late int _currentStep;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 1: Date & Showtime State
  late final List<DateTime> _dates;
  int _selectedDateIndex = 0;
  String _selectedShowtime = AppConstants.showtimes[1];

  // Step 2: Seat Selection Matrix (8 columns x 6 rows = 48 seats)
  // Rows: A, B, C, D (Regular ₹180), E (Premium ₹280), F (Recliner ₹420)
  final Set<String> _selectedSeats = {'C4', 'C5'};
  final Set<String> _bookedSeats = {'A2', 'A3', 'B5', 'D1', 'D8', 'E4', 'F2'};
  String _seatType = 'Regular';

  // Step 3: Add-ons State
  bool _addPopcornCombo = false;
  bool _sendSmsReminder = true;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    final now = DateTime.now();
    _dates = List.generate(7, (i) => now.add(Duration(days: i)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _seatPrice {
    if (_selectedSeats.any((s) => s.startsWith('F'))) return 420.0;
    if (_selectedSeats.any((s) => s.startsWith('E'))) return 280.0;
    return 180.0;
  }

  double get _totalPrice {
    final seatsTotal = _seatPrice * max(1, _selectedSeats.length);
    final popcornTotal = _addPopcornCombo ? AppConstants.popcornComboPrice : 0.0;
    return seatsTotal + popcornTotal;
  }

  String _generateBookingId() {
    final rand = Random();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final randomSuffix = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
    return 'ME-${DateTime.now().year}-$randomSuffix';
  }

  void _toggleSeat(String seatId) {
    if (_bookedSeats.contains(seatId)) return;
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        if (_selectedSeats.length > 1) {
          _selectedSeats.remove(seatId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('At least 1 seat must remain selected'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (_selectedSeats.length < 8) {
          _selectedSeats.add(seatId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 8 tickets allowed per booking'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Update seat class label
      if (_selectedSeats.any((s) => s.startsWith('F'))) {
        _seatType = 'Recliner';
      } else if (_selectedSeats.any((s) => s.startsWith('E'))) {
        _seatType = 'Premium';
      } else {
        _seatType = 'Regular';
      }
    });
  }

  void _onConfirmPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedDate = _dates[_selectedDateIndex];
    final dateString = '${_getWeekday(selectedDate.weekday)}, ${selectedDate.day} ${_getMonth(selectedDate.month)}';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
        title: const Row(
          children: [
            Icon(Icons.confirmation_num_rounded, color: AppTheme.primaryCrimson, size: 26),
            SizedBox(width: 10),
            Text('Confirm Reservation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.movie.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildSummaryRow('Date:', dateString),
              _buildSummaryRow('Showtime:', _selectedShowtime),
              _buildSummaryRow('Seats:', '${_selectedSeats.join(', ')} ($_seatType)'),
              _buildSummaryRow('Customer:', _nameController.text.trim()),
              _buildSummaryRow('Phone:', _phoneController.text.trim()),
              _buildSummaryRow('Popcorn Combo:', _addPopcornCombo ? 'Included (+₹250)' : 'None'),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    '₹${_totalPrice.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.primaryCrimson,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();

              final booking = Booking(
                bookingId: _generateBookingId(),
                movie: widget.movie,
                customerName: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
                showtime: '$dateString at $_selectedShowtime',
                seatType: '$_seatType (${_selectedSeats.join(',')})',
                seatPrice: _seatPrice,
                ticketsCount: _selectedSeats.length,
                hasPopcorn: _addPopcornCombo,
                sendSms: _sendSmsReminder,
                totalAmount: _totalPrice,
                bookingDate: DateTime.now(),
              );

              Navigator.pushReplacementNamed(
                context,
                '/confirmation',
                arguments: booking,
              );
            },
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Movie Tickets'),
      ),
      body: Column(
        children: [
          // ── 3-Step Custom Progress Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              children: [
                _buildStepPill(0, '1. Date & Time'),
                _buildStepDivider(0),
                _buildStepPill(1, '2. Seats Map'),
                _buildStepDivider(1),
                _buildStepPill(2, '3. Checkout'),
              ],
            ),
          ),

          // ── Step Content Pages ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              child: [
                _buildStep1DateTime(),
                _buildStep2SeatSelection(),
                _buildStep3Details(),
              ][_currentStep],
            ),
          ),

          // ── Bottom Step Navigation Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: const Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TOTAL PAYABLE', style: TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                        Text('₹${_totalPrice.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryCrimson)),
                      ],
                    ),
                  const Spacer(),
                  if (_currentStep < 2)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(_currentStep == 0 ? 'Select Seats' : 'Enter Details'),
                      onPressed: () => setState(() => _currentStep++),
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Confirm & Pay Booking'),
                      onPressed: _onConfirmPressed,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return InkWell(
      onTap: () => setState(() => _currentStep = stepIndex),
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryCrimson
              : isDone
                  ? AppTheme.successGreen.withValues(alpha: 0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive
                ? Colors.white
                : isDone
                    ? AppTheme.successGreen
                    : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildStepDivider(int stepIndex) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: _currentStep > stepIndex ? AppTheme.successGreen : AppTheme.border,
      ),
    );
  }

  // ── Step 1: Date & Time Selection ──
  Widget _buildStep1DateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Show Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final d = _dates[index];
              final isSelected = _selectedDateIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedDateIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 65,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryCrimson : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryCrimson : AppTheme.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekday(d.weekday),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white70 : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _getMonth(d.month),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white70 : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 28),

        const Text('Select Showtime Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.showtimes.map((slot) {
            final isSelected = _selectedShowtime == slot;
            return InkWell(
              onTap: () => setState(() => _selectedShowtime = slot),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryCrimson : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryCrimson : AppTheme.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: isSelected ? Colors.white : AppTheme.secondaryGold),
                    const SizedBox(width: 8),
                    Text(
                      slot,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // Quick Cinema Format Badge Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.theaters_rounded, color: AppTheme.primaryCrimson, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Audi 2 • Dolby Atmos & 4K Laser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 2),
                    Text('English (Original) with English Subtitles', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: Interactive Cinema Seat Selection Grid ──
  Widget _buildStep2SeatSelection() {
    const rows = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Column(
      children: [
        // Curved Screen Indicator
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              CustomPaint(
                size: const Size(260, 20),
                painter: _ScreenCurvePainter(),
              ),
              const SizedBox(height: 4),
              const Text(
                'CINEMA SCREEN THIS WAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),

        // 8x6 Seats Matrix
        Column(
          children: rows.map((rowName) {
            final isRecliner = rowName == 'F';
            final isPremium = rowName == 'E';
            final categoryPrice = isRecliner ? '₹420' : isPremium ? '₹280' : '₹180';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      rowName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(8, (colIndex) {
                        final seatId = '$rowName${colIndex + 1}';
                        final isSelected = _selectedSeats.contains(seatId);
                        final isBooked = _bookedSeats.contains(seatId);
                        final status = isBooked
                            ? SeatStatus.booked
                            : isSelected
                                ? SeatStatus.selected
                                : SeatStatus.available;

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 2,
                              right: colIndex == 3 ? 12 : 2, // middle aisle gap
                            ),
                            child: SizedBox(
                              height: 32,
                              child: SeatWidget(
                                seatId: seatId,
                                status: status,
                                onTap: () => _toggleSeat(seatId),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      categoryPrice,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryGold),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Seat Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Available', Theme.of(context).cardColor, AppTheme.border),
            _buildLegendItem('Selected', AppTheme.primaryCrimson, AppTheme.primaryCrimson),
            _buildLegendItem('Booked', Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35), Colors.transparent),
          ],
        ),

        const SizedBox(height: 20),

        // Live Selected Seats Summary Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryCrimson.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.primaryCrimson.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECTED SEATS (${_selectedSeats.length})', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryCrimson)),
                  const SizedBox(height: 2),
                  Text(_selectedSeats.join(', '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Text(
                '₹${(_seatPrice * _selectedSeats.length).toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryCrimson),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: Contact Details & Add-ons Form ──
  Widget _buildStep3Details() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Contact Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'e.g. Alex Johnson',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 3) {
                return 'Please enter your full name (minimum 3 characters)';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              hintText: 'e.g. alex@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email address';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(val.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              labelText: 'Phone Number (10 digits) *',
              hintText: 'e.g. 9876543210',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your mobile number';
              }
              if (val.trim().length != 10) {
                return 'Phone number must be exactly 10 digits';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          const Text('Snacks & Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                CheckboxListTile(
                  value: _addPopcornCombo,
                  activeColor: AppTheme.primaryCrimson,
                  title: const Text('Add Popcorn & Beverage Combo'),
                  subtitle: const Text('Jumbo salted tub + 650ml soda (+₹250)'),
                  secondary: const Icon(Icons.fastfood_rounded, color: AppTheme.secondaryGold),
                  onChanged: (val) => setState(() => _addPopcornCombo = val ?? false),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _sendSmsReminder,
                  activeThumbColor: AppTheme.primaryCrimson,
                  title: const Text('Instant SMS & WhatsApp Alert'),
                  subtitle: const Text('Digital ticket link sent before show'),
                  secondary: const Icon(Icons.sms_rounded, color: AppTheme.successGreen),
                  onChanged: (val) => setState(() => _sendSmsReminder = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }

  String _getWeekday(int d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(d - 1) % 7];
  }

  String _getMonth(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[(m - 1) % 12];
  }
}

/// Custom Painter drawing a subtle curved line representing cinema screen
class _ScreenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryCrimson.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
