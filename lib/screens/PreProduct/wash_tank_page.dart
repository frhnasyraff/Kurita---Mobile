import 'package:flutter/material.dart';
import 'material_verification_page.dart';

// ─── Status Enum ─────────────────────────────────────────────────────────────

enum VerificationStatus { pending, verified, rejected }

// ─── Page ─────────────────────────────────────────────────────────────────────
// Pixel-matches the "Workwise - Tank Cleaning & QC" HTML mock:
// colors, M3-style tokens, underline-style inputs, navy accent-bar job card,
// pulsing status dot, fixed bottom submit button, bottom nav bar.

class WashTankPage extends StatefulWidget {
  final String jobSheetId;
  final String productName;
  final String laneNumber;

  const WashTankPage({
    super.key,
    this.jobSheetId = '#JOB-2024-012',
    this.productName = 'Industrial Solvent B-42',
    this.laneNumber = 'LANE 04 - NORTH',
  });

  @override
  State<WashTankPage> createState() => _WashTankPageState();
}

class _WashTankPageState extends State<WashTankPage> {
  // ── Colour tokens (matched 1:1 to the HTML mock's Tailwind config) ────────
  static const Color primary               = Color(0xFF002046);
  static const Color onPrimary             = Color(0xFFFFFFFF);
  static const Color primaryContainer      = Color(0xFF1B365D);
  static const Color secondaryContainer    = Color(0xFFD1E1F4);
  static const Color onSecondaryContainer  = Color(0xFF556474);
  static const Color background            = Color(0xFFF8F9FA);
  static const Color surface               = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainer      = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh  = Color(0xFFE7E8E9);
  static const Color onSurface             = Color(0xFF191C1D);
  static const Color onSurfaceVariant      = Color(0xFF44474E);
  static const Color outline               = Color(0xFF74777F);
  static const Color outlineVariant        = Color(0xFFC4C6CF);
  static const Color error                 = Color(0xFFBA1A1A);

  // ── State ─────────────────────────────────────────────────────────────────
  final TextEditingController _phController =
      TextEditingController(text: '7.4');
  final TextEditingController _conductivityController =
      TextEditingController(text: '42');

  // "Tested By" is locked, matching the HTML mock (readonly, pre-filled).
  static const String _testedBy = 'MARCUS V.';

  // Date/Time auto-generated from current time, read-only, updates every
  // minute — matching the HTML mock's #auto-time behaviour.
  DateTime _autoDateTime = DateTime.now();

  VerificationStatus _status = VerificationStatus.pending;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phController.dispose();
    _conductivityController.dispose();
    super.dispose();
  }

  // ── Format DateTime ───────────────────────────────────────────────────────
  // Matches HTML's toLocaleDateString format: "Jun 30, 2026 | 11:12 AM"
  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} | $hour:$minute $ampm';
  }

  // ── Validate & Submit ─────────────────────────────────────────────────────
  void _submit() {
    final ph = double.tryParse(_phController.text);
    final conductivity = double.tryParse(_conductivityController.text);

    if (ph == null) {
      _showDialog('⚠️ Invalid pH', 'Please enter a valid pH value.', isError: true);
      return;
    }
    if (ph < 6.9 || ph > 8.5) {
      _showDialog('⚠️ pH Out of Range',
          'pH value $ph is outside the acceptable range (6.9 – 8.5).\n\nPlease recheck before submitting.',
          isError: true);
      return;
    }
    if (conductivity == null) {
      _showDialog('⚠️ Invalid Conductivity', 'Please enter a valid conductivity value.', isError: true);
      return;
    }
    if (conductivity < 37 || conductivity > 47) {
      _showDialog('⚠️ Conductivity Out of Range',
          'Conductivity $conductivity uS/cm is outside the acceptable range (+/- 5 uS/cm from 42).\n\nPlease recheck.',
          isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _status = VerificationStatus.verified;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _isSubmitting = false);
      _showDialog(
        '✅ Submitted Successfully',
        'Wash Tank verification for ${widget.jobSheetId} has been submitted.\n\nProceeding to Material Verification.',
        isError: false,
        onOk: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MaterialVerificationPage(
                jobId: widget.jobSheetId,
                lane: widget.laneNumber,
                productionDate: '${_formatDateTime(_autoDateTime)} - SHIFT A',
              ),
            ),
          );
        },
      );
    });
  }

  void _showDialog(String title, String message,
      {bool isError = false, VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
            child: Text('OK',
                style: TextStyle(
                    color: isError ? Colors.red : primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _statusLabel() {
    switch (_status) {
      case VerificationStatus.verified: return 'VERIFIED';
      case VerificationStatus.rejected: return 'REJECTED';
      default: return 'PENDING VERIFICATION';
    }
  }

  Color _statusColor() {
    switch (_status) {
      case VerificationStatus.verified: return const Color(0xFF2E7D32);
      default: return error;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      // ── Fixed Top App Bar ──────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: const Border(bottom: BorderSide(color: outlineVariant, width: 1)),
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: outlineVariant),
              color: surfaceContainerHigh,
            ),
            child: const Icon(Icons.person, color: onSurfaceVariant, size: 22),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined, color: onSurfaceVariant),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main Title ──────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'WASH TANK',
                style: TextStyle(
                  fontSize: 30,
                  height: 38 / 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: primary,
                ),
              ),
            ),

            // ── Section 1: Job Details ──────────────────────────────────
            _buildJobDetailsCard(),
            const SizedBox(height: 24),

            // ── Section 2: Cleaning Verification ────────────────────────
            _buildSectionHeader(Icons.fact_check_outlined, 'CLEANING VERIFICATION'),
            const SizedBox(height: 8),
            _buildInstructionsBanner(),
            const SizedBox(height: 16),
            _buildPhField(),
            const SizedBox(height: 16),
            _buildConductivityField(),
            const SizedBox(height: 16),
            _buildTestedByField(),
            const SizedBox(height: 16),
            _buildDateTimeField(),
            const SizedBox(height: 24),

            // ── Section 3: QC Status ─────────────────────────────────────
            _buildQcStatusCard(),

            // Space for fixed submit button + bottom nav
            const SizedBox(height: 140),
          ],
        ),
      ),

      // ── Fixed bottom submit button + bottom nav bar ──────────────────────
      bottomSheet: _buildBottomArea(),
    );
  }

  // ── Section 1: Job Details Card ─────────────────────────────────────────
  Widget _buildJobDetailsCard() => Container(
        decoration: BoxDecoration(
          color: surfaceContainerLowest,
          border: Border.all(color: outlineVariant),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: primary)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('JOB SHEET ID',
                          style: TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.96,
                              color: onSurfaceVariant)),
                      Text(
                        '#${widget.jobSheetId}',
                        style: const TextStyle(
                          fontSize: 20,
                          height: 24 / 20,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: outlineVariant),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _jobDetailCell('PRODUCT NAME', widget.productName)),
                      const SizedBox(width: 16),
                      Expanded(child: _jobDetailCell('LANE NUMBER', widget.laneNumber)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _jobDetailCell(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.96,
                  color: onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w700,
                  color: onSurface)),
        ],
      );

  // ── Section header ─────────────────────────────────────────────────────
  Widget _buildSectionHeader(IconData icon, String title) => Row(
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  color: primary)),
        ],
      );

  // ── Instructions banner ────────────────────────────────────────────────
  Widget _buildInstructionsBanner() => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: secondaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border(left: BorderSide(color: primary, width: 4)),
        ),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 16, height: 24 / 16, color: onSecondaryContainer),
            children: [
              TextSpan(text: 'Instructions: ', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: 'Wash blending tank with tap water. Check pH and Conductivity.'),
            ],
          ),
        ),
      );

  // ── Underline-style input (matches HTML's bg-surface-container + border-b-2 look) ──
  Widget _underlineField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    bool readOnly = false,
    String? readOnlyValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.96,
                  color: onSurfaceVariant)),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: surfaceContainerHigh,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(
              bottom: BorderSide(
                color: outlineVariant,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: readOnly
                    ? Text(readOnlyValue ?? '',
                        style: const TextStyle(
                            fontSize: 16, height: 24 / 16, color: onSurface))
                    : TextField(
                        controller: controller,
                        readOnly: readOnly,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                            fontSize: 20,
                            height: 24 / 20,
                            fontWeight: FontWeight.w700,
                            color: onSurface),
                      ),
              ),
              if (suffix.isNotEmpty)
                Text(suffix,
                    style: const TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.96,
                        color: onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhField() => _underlineField(
        label: 'PH LEVEL (RANGE: 6.9 - 8.5)',
        controller: _phController,
        suffix: 'pH',
      );

  Widget _buildConductivityField() => _underlineField(
        label: 'CONDUCTIVITY (+/- 5 US/CM)',
        controller: _conductivityController,
        suffix: 'uS/cm',
      );

  Widget _buildTestedByField() => _underlineField(
        label: 'TESTED BY (QC)',
        controller: TextEditingController(text: _testedBy),
        suffix: '',
        readOnly: true,
        readOnlyValue: _testedBy,
      );

  Widget _buildDateTimeField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text('DATE/TIME',
                style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.96,
                    color: onSurfaceVariant)),
          ),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: outlineVariant, width: 2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDateTime(_autoDateTime),
                    style: const TextStyle(fontSize: 16, height: 24 / 16, color: onSurface),
                  ),
                ),
                const Icon(Icons.schedule, size: 20, color: onSurfaceVariant),
              ],
            ),
          ),
        ],
      );

  // ── Section 3: QC Status Card ──────────────────────────────────────────
  Widget _buildQcStatusCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceContainer,
          border: Border.all(color: outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT STATUS',
                    style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.96,
                        color: onSurfaceVariant)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _PulsingDot(color: _statusColor()),
                    const SizedBox(width: 8),
                    Text(_statusLabel(),
                        style: TextStyle(
                            fontSize: 16,
                            height: 24 / 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: _statusColor())),
                  ],
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: surface,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
                ],
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.history, color: primaryContainer),
              ),
            ),
          ],
        ),
      );

  // ── Bottom: fixed submit button + bottom nav bar ──────────────────────
  Widget _buildBottomArea() => Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: onPrimary, strokeWidth: 2),
                        )
                      : const Icon(Icons.task_alt, color: onPrimary, size: 22),
                  label: Text(
                    _isSubmitting ? 'SUBMITTING...' : 'SUBMIT',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onPrimary,
                      letterSpacing: 1.4,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 4,
                  ),
                ),
              ),
            ),
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: surface,
                border: Border(top: BorderSide(color: outlineVariant, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (_) => const Icon(Icons.circle, size: 0), // empty nav slots, matches HTML mock (icons not specified)
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Pulsing status dot (matches HTML's animate-pulse) ──────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.4).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}