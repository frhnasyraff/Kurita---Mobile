import 'package:flutter/material.dart';
import 'material_verification_page.dart';

// ─── Status Enum ─────────────────────────────────────────────────────────────

enum VerificationStatus { pending, verified, rejected }

// ─── Page ─────────────────────────────────────────────────────────────────────

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
  // ── Colours ──────────────────────────────────────────────────────────────
  static const Color navy        = Color(0xFF17335C);
  static const Color bgLight     = Color(0xFFF5F6F8);
  static const Color borderGrey  = Color(0xFFE5E7EB);
  static const Color infoBlueBg  = Color(0xFFEFF6FF);
  static const Color infoBlueBdr = Color(0xFFBFDBFE);
  static const Color pendingOrange = Color(0xFFD97706);

  // ── State ─────────────────────────────────────────────────────────────────
  final TextEditingController _phController =
  TextEditingController(text: '7.4');
  final TextEditingController _conductivityController =
  TextEditingController(text: '42');
  final TextEditingController _testedByController =
  TextEditingController(text: 'MARCUS V.');

  DateTime _selectedDateTime = DateTime(2026, 5, 31, 11, 12);
  VerificationStatus _status = VerificationStatus.pending;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phController.dispose();
    _conductivityController.dispose();
    _testedByController.dispose();
    super.dispose();
  }

  // ── Pick Date/Time ────────────────────────────────────────────────────────
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: navy,
            onPrimary: Colors.white,
            onSurface: navy,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: navy,
            onPrimary: Colors.white,
            onSurface: navy,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // ── Format DateTime ───────────────────────────────────────────────────────
  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}, $hour:$minute $ampm';
  }

  // ── Validate & Submit ─────────────────────────────────────────────────────
  void _submit() {
    final ph = double.tryParse(_phController.text);
    final conductivity = double.tryParse(_conductivityController.text);
    final testedBy = _testedByController.text.trim();

    // Validation
    if (testedBy.isEmpty) {
      _showDialog('⚠️ Missing Info', 'Please enter the name of the QC tester.', isError: true);
      return;
    }
    if (ph == null) {
      _showDialog('⚠️ Invalid pH', 'Please enter a valid pH value.', isError: true);
      return;
    }
    if (ph < 6.0 || ph > 8.5) {
      _showDialog('⚠️ pH Out of Range',
          'pH value $ph is outside the acceptable range (6.0 – 8.5).\n\nPlease recheck before submitting.',
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

    // All valid — submit
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
                productionDate: '${_formatDateTime(_selectedDateTime)} - SHIFT A',
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
                    color: isError ? Colors.red : navy,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Status Helpers ────────────────────────────────────────────────────────
  Color _statusColor() {
    switch (_status) {
      case VerificationStatus.verified: return Colors.green[700]!;
      case VerificationStatus.rejected: return Colors.red[700]!;
      default: return pendingOrange;
    }
  }

  String _statusLabel() {
    switch (_status) {
      case VerificationStatus.verified: return '● VERIFIED';
      case VerificationStatus.rejected: return '● REJECTED';
      default: return '● PENDING VERIFICATION';
    }
  }

  IconData _statusIcon() {
    switch (_status) {
      case VerificationStatus.verified: return Icons.check_circle_outline;
      case VerificationStatus.rejected: return Icons.cancel_outlined;
      default: return Icons.sync;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 20),
                    _buildInfoGrid(),
                    const SizedBox(height: 20),
                    _buildCleaningVerificationSection(),
                    const SizedBox(height: 20),
                    _buildPhField(),
                    const SizedBox(height: 14),
                    _buildConductivityField(),
                    const SizedBox(height: 14),
                    _buildTestedByField(),
                    const SizedBox(height: 14),
                    _buildDateTimeField(),
                    const SizedBox(height: 14),
                    _buildStatusField(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.water_outlined,
            color: Colors.white, size: 18),
      ),
      const Spacer(),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.settings_outlined, color: navy),
      ),
    ],
  );

  // ── Title ─────────────────────────────────────────────────────────────────
  Widget _buildTitle() => const Text(
    'WASH TANK',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: navy,
      letterSpacing: 0.5,
    ),
  );

  // ── Info Grid ─────────────────────────────────────────────────────────────
  Widget _buildInfoGrid() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderGrey),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _infoCell('JOB SHEET ID', widget.jobSheetId,
                  valueStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: navy)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _infoCell('LANE NUMBER', widget.laneNumber),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _infoCell('PRODUCT NAME', widget.productName),
      ],
    ),
  );

  Widget _infoCell(String label, String value,
      {TextStyle? valueStyle}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value,
              style: valueStyle ??
                  const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: navy)),
        ],
      );

  // ── Cleaning Verification Section ─────────────────────────────────────────
  Widget _buildCleaningVerificationSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: const [
          Icon(Icons.check_box_outlined, color: navy, size: 18),
          SizedBox(width: 8),
          Text('CLEANING VERIFICATION',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: navy,
                  letterSpacing: 0.5)),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: infoBlueBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: infoBlueBdr),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline, size: 16, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Instructions: Wash blending tank with tap water. Check pH and Conductivity.',
                style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  // ── pH Field ──────────────────────────────────────────────────────────────
  Widget _buildPhField() => _labeledField(
    label: 'PH LEVEL (RANGE 6.0 - 8.5)',
    child: TextField(
      controller: _phController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration('e.g. 7.4').copyWith(
        suffixText: 'pH',
        suffixStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  // ── Conductivity Field ────────────────────────────────────────────────────
  Widget _buildConductivityField() => _labeledField(
    label: 'CONDUCTIVITY (+/- 5 US/CM)',
    child: TextField(
      controller: _conductivityController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration('e.g. 42').copyWith(
        suffixText: 'uS/cm',
        suffixStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  // ── Tested By Field ───────────────────────────────────────────────────────
  Widget _buildTestedByField() => _labeledField(
    label: 'TESTED BY (QC)',
    child: TextField(
      controller: _testedByController,
      textCapitalization: TextCapitalization.characters,
      decoration: _inputDecoration('Enter QC tester name'),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  // ── Date/Time Field ───────────────────────────────────────────────────────
  Widget _buildDateTimeField() => _labeledField(
    label: 'DATE/TIME',
    child: GestureDetector(
      onTap: _pickDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatDateTime(_selectedDateTime),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: navy),
              ),
            ),
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    ),
  );

  // ── Status Field ──────────────────────────────────────────────────────────
  Widget _buildStatusField() => _labeledField(
    label: 'CURRENT STATUS',
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _statusLabel(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _statusColor(),
              ),
            ),
          ),
          Icon(_statusIcon(), size: 18, color: _statusColor()),
        ],
      ),
    ),
  );

  // ── Submit Button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _submit,
      icon: _isSubmitting
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
            color: Colors.white, strokeWidth: 2),
      )
          : const Icon(Icons.check_circle_outline,
          color: Colors.white, size: 20),
      label: Text(
        _isSubmitting ? 'SUBMITTING...' : 'SUBMIT',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: navy,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _labeledField({required String label, required Widget child}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          child,
        ],
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: borderGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: borderGrey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: navy, width: 1.5),
    ),
  );
}
