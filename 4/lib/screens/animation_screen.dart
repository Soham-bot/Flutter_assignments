import 'package:flutter/material.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  // AnimatedContainer state properties
  double _width = 150.0;
  double _height = 150.0;
  Color _color = const Color(0xFF673AB7); // Deep Purple
  BorderRadius _borderRadius = BorderRadius.circular(20.0);
  Alignment _childAlignment = Alignment.center;
  double _elevation = 8.0;
  IconData _icon = Icons.animation;
  String _modeLabel = 'Compact Purple';

  // Toggle state flag
  bool _isExpanded = false;

  void _toggleAnimation() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _width = 250.0;
        _height = 250.0;
        _color = const Color(0xFFE65100); // Deep Orange
        _borderRadius = BorderRadius.circular(125.0); // Full Circle
        _childAlignment = Alignment.center;
        _elevation = 20.0;
        _icon = Icons.auto_awesome;
        _modeLabel = 'Glowing Orange Circle';
      } else {
        _width = 150.0;
        _height = 150.0;
        _color = const Color(0xFF673AB7);
        _borderRadius = BorderRadius.circular(20.0);
        _childAlignment = Alignment.center;
        _elevation = 8.0;
        _icon = Icons.animation;
        _modeLabel = 'Compact Purple';
      }
    });
  }

  void _applyPreset({
    required double width,
    required double height,
    required Color color,
    required double radius,
    required IconData icon,
    required String label,
    required double elevation,
  }) {
    setState(() {
      _width = width;
      _height = height;
      _color = color;
      _borderRadius = BorderRadius.circular(radius);
      _elevation = elevation;
      _icon = icon;
      _modeLabel = label;
      _isExpanded = (width > 200);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interactive Animations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE65100).withValues(alpha: 0.05),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Overview Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE65100).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_graph_rounded,
                        color: Color(0xFFE65100),
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AnimatedContainer implicitly animates changes in size, color, border radius, and elevation over time without requiring custom controllers.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Interactive Playground Area
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        key: const Key('animated_container_target'),
                        width: _width,
                        height: _height,
                        alignment: _childAlignment,
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeInOutCubic,
                        decoration: BoxDecoration(
                          color: _color,
                          borderRadius: _borderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: _color.withValues(alpha: 0.4),
                              blurRadius: _elevation,
                              spreadRadius: _elevation / 4,
                              offset: Offset(0, _elevation / 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _icon,
                              color: Colors.white,
                              size: (_width > 200) ? 48 : 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_width.toInt()} × ${_height.toInt()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: (_width > 200) ? 14 : 11,
                              ),
                            ),
                            if (_width > 200) ...[
                              const SizedBox(height: 2),
                              Text(
                                _modeLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Primary Trigger Button
                ElevatedButton.icon(
                  key: const Key('btn_toggle_animation'),
                  onPressed: _toggleAnimation,
                  icon: const Icon(Icons.touch_app_rounded),
                  label: Text(
                    _isExpanded ? 'Shrink Container' : 'Expand & Morph Container',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),

                const SizedBox(height: 20),

                // Presets Section Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ANIMATION PRESET MODES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Preset Buttons
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PresetChip(
                      label: 'Compact Purple',
                      icon: Icons.square_rounded,
                      color: const Color(0xFF673AB7),
                      onTap: () => _applyPreset(
                        width: 140,
                        height: 140,
                        color: const Color(0xFF673AB7),
                        radius: 16,
                        icon: Icons.animation,
                        label: 'Compact Purple',
                        elevation: 8,
                      ),
                    ),
                    _PresetChip(
                      label: 'Glowing Circle',
                      icon: Icons.circle,
                      color: const Color(0xFFE65100),
                      onTap: () => _applyPreset(
                        width: 240,
                        height: 240,
                        color: const Color(0xFFE65100),
                        radius: 120,
                        icon: Icons.auto_awesome,
                        label: 'Glowing Orange Circle',
                        elevation: 22,
                      ),
                    ),
                    _PresetChip(
                      label: 'Emerald Card',
                      icon: Icons.credit_card_rounded,
                      color: const Color(0xFF2E7D32),
                      onTap: () => _applyPreset(
                        width: 270,
                        height: 150,
                        color: const Color(0xFF2E7D32),
                        radius: 24,
                        icon: Icons.layers_rounded,
                        label: 'Emerald Card',
                        elevation: 12,
                      ),
                    ),
                    _PresetChip(
                      label: 'Ocean Pill',
                      icon: Icons.lens_blur_rounded,
                      color: const Color(0xFF0277BD),
                      onTap: () => _applyPreset(
                        width: 200,
                        height: 100,
                        color: const Color(0xFF0277BD),
                        radius: 50,
                        icon: Icons.waves_rounded,
                        label: 'Ocean Pill',
                        elevation: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Live Inspector Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 18, color: Colors.black87),
                          SizedBox(width: 8),
                          Text(
                            'Live Property Inspector',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      _InspectorRow(
                        property: 'Size (Width × Height)',
                        value: '${_width.toInt()}px × ${_height.toInt()}px',
                      ),
                      const SizedBox(height: 6),
                      _InspectorRow(
                        property: 'Border Radius',
                        value: '${_borderRadius.topLeft.x.toInt()}px',
                      ),
                      const SizedBox(height: 6),
                      _InspectorRow(
                        property: 'Color Hex',
                        value: '#${_color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                      ),
                      const SizedBox(height: 6),
                      const _InspectorRow(
                        property: 'Duration / Curve',
                        value: '650ms / Curves.easeInOutCubic',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}

class _InspectorRow extends StatelessWidget {
  final String property;
  final String value;

  const _InspectorRow({
    required this.property,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          property,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}
