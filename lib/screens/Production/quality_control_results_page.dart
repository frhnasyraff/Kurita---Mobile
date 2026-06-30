import 'package:flutter/material.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _navy      = Color(0xFF17335C);
const _surface   = Color(0xFFF4F7FB);
const _border    = Color(0xFFE4EAF2);
const _textMuted = Color(0xFF8A99AD);
const _textDark  = Color(0xFF1A2A3A);
const _passGreen = Color(0xFF1A6B3C);
const _failRed   = Color(0xFFCC2936);
const _amber     = Color(0xFFF59E0B);

// ── Data Models ───────────────────────────────────────────────────────────────

enum SampleStatus { pass, fail, none }

class QCSample {
  final String dateTime;
  final String value;
  final SampleStatus status;

  const QCSample({
    required this.dateTime,
    required this.value,
    required this.status,
  });
}

class QCParameter {
  final String name;
  final String spec;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final List<QCSample?> samples;
  final String stageStatus;
  final bool isFail;

  const QCParameter({
    required this.name,
    required this.spec,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.samples,
    required this.stageStatus,
    this.isFail = false,
  });
}

// ── Default data ──────────────────────────────────────────────────────────────

const List<QCParameter> _defaultParameters = [
  QCParameter(
    name: 'Appearance',
    spec: 'Spec: Light Yellow to Yellow Liquid',
    icon: Icons.remove_red_eye_outlined,
    iconColor: Color(0xFFD97706),
    iconBg: Color(0xFFFEF3C7),
    stageStatus: '1st PASS',
    samples: [
      QCSample(dateTime: '05/29/2024\n10:15', value: 'Clear Yellow', status: SampleStatus.pass),
      null,
      null,
    ],
  ),
  QCParameter(
    name: 'pH Level',
    spec: 'Spec: 11.0 - 12.0',
    icon: Icons.science_outlined,
    iconColor: Color(0xFF3B82F6),
    iconBg: Color(0xFFEFF6FF),
    stageStatus: '2nd PASS',
    samples: [
      QCSample(dateTime: '05/29/2024\n10:15', value: '12.1', status: SampleStatus.pass),
      QCSample(dateTime: '05/29/2024\n10:30', value: '12.3', status: SampleStatus.pass),
      null,
    ],
  ),
  QCParameter(
    name: 'Viscosity (cP)',
    spec: 'Range: 1,000 - 1,650',
    icon: Icons.speed_outlined,
    iconColor: Color(0xFFDC2626),
    iconBg: Color(0xFFFEF2F2),
    stageStatus: '1st FAIL',
    isFail: true,
    samples: [
      QCSample(dateTime: '05/29/2024\n10:15', value: '1,080', status: SampleStatus.fail),
      null,
      null,
    ],
  ),
  QCParameter(
    name: 'Specific Gravity',
    spec: 'Spec: 1.03 - 1.07',
    icon: Icons.water_drop_outlined,
    iconColor: Color(0xFF3B82F6),
    iconBg: Color(0xFFEFF6FF),
    stageStatus: '2nd PASS',
    samples: [
      QCSample(dateTime: '05/29/2024\n10:15', value: '1.05', status: SampleStatus.pass),
      QCSample(dateTime: '05/29/2024\n10:30', value: '1.04', status: SampleStatus.pass),
      null,
    ],
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class QualityControlResultsPage extends StatefulWidget {
  final String jobSheetId;
  final String testedBy;
  final String updatedBy;
  final String currentStatus;
  final List<QCParameter> parameters;

  const QualityControlResultsPage({
    super.key,
    this.jobSheetId    = '#JOB-2024-815',
    this.testedBy      = 'Sarah Connor',
    this.updatedBy     = 'John Smith',
    this.currentStatus = 'Adjustment Require',
    this.parameters    = _defaultParameters,
  });

  @override
  State<QualityControlResultsPage> createState() =>
      _QualityControlResultsPageState();
}

class _QualityControlResultsPageState
    extends State<QualityControlResultsPage> {

  void _onCancel() => Navigator.pop(context);

  void _onUpdateResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Update Results tapped'),
        backgroundColor: _navy,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSaveQCDecision() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save QC Decision',
            style: TextStyle(color: _navy, fontWeight: FontWeight.w800)),
        content: Text('Save QC decision for ${widget.jobSheetId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(
                    color: _navy, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 12),
                    _buildPersonnelCard(),
                    const SizedBox(height: 16),
                    _buildQCTable(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _navy, size: 20),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.precision_manufacturing_outlined,
            color: _navy, size: 22),
        const SizedBox(width: 8),
        const Text('QUALITY CONTROL RESULTS',
            style: TextStyle(
                color: _navy,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2)),
      ],
    ),
  );

  // ── Status Card ───────────────────────────────────────────────────────────

  Widget _buildStatusCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(color: Color(0x0A18304D), blurRadius: 6,
            offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CURRENT STATUS',
                  style: TextStyle(
                      color: _textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(
                        color: _amber, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.currentStatus,
                      style: const TextStyle(
                          color: _textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _navy.withOpacity(0.3)),
          ),
          child: const Icon(Icons.info_outline, color: _navy, size: 18),
        ),
      ],
    ),
  );

  // ── Personnel Card ────────────────────────────────────────────────────────

  Widget _buildPersonnelCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(color: Color(0x0A18304D), blurRadius: 6,
            offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        Expanded(child: _personnelItem('TESTED BY', widget.testedBy)),
        Container(width: 1, height: 48, color: _border),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _personnelItem('UPDATED BY', widget.updatedBy),
          ),
        ),
      ],
    ),
  );

  Widget _personnelItem(String label, String name) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              color: _textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
      const SizedBox(height: 10),
      Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: _navy, size: 18),
          ),
          const SizedBox(width: 8),
          Text(name,
              style: const TextStyle(
                  color: _textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    ],
  );

  // ── QC Table ──────────────────────────────────────────────────────────────

  Widget _buildQCTable() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(color: Color(0x0A18304D), blurRadius: 6,
            offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      children: [
        _buildTableHeader(),
        const Divider(color: _border, height: 1),
        ...widget.parameters.asMap().entries.map((e) {
          final isLast = e.key == widget.parameters.length - 1;
          return Column(
            children: [
              _buildParameterRow(e.value),
              if (!isLast) const Divider(color: _border, height: 1),
            ],
          );
        }),
      ],
    ),
  );

  // ── Table uses fixed widths so nothing wraps ──────────────────────────────

  // Column widths (px):
  //   icon        : 44
  //   param info  : flexible (takes remaining space)
  //   each sample : 64  × 3
  //   stage status: 56

  static const double _sampleW = 64;
  static const double _stageW  = 58;
  static const double _iconW   = 44;

  Widget _buildTableHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // icon placeholder
        const SizedBox(width: _iconW),
        // param column
        const Expanded(
          child: Text('QC PARAMETER &\nSPECIFICATION',
              style: TextStyle(
                  color: _textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  height: 1.4)),
        ),
        // 3 sample headers
        ...['1ST SAMPLE', '2ND SAMPLE', '3RD SAMPLE'].map(
              (s) => SizedBox(
            width: _sampleW,
            child: Column(
              children: [
                Text(s,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _textMuted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2)),
                const Text('Date & Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 7,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        // stage status header
        const SizedBox(
          width: _stageW,
          child: Text('STAGE\nSTATUS',
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: _textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  height: 1.4)),
        ),
      ],
    ),
  );

  Widget _buildParameterRow(QCParameter param) => Container(
    color: param.isFail ? const Color(0xFFFFF5F5) : Colors.transparent,
    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Icon ──
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: param.iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(param.icon, color: param.iconColor, size: 18),
        ),
        const SizedBox(width: 8),

        // ── Name + spec ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(param.name,
                  style: const TextStyle(
                      color: _textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(param.spec,
                  style: const TextStyle(
                      color: _textMuted,
                      fontSize: 10,
                      height: 1.3)),
            ],
          ),
        ),

        // ── 3 sample cells ──
        ...List.generate(3, (i) {
          final sample =
          i < param.samples.length ? param.samples[i] : null;
          return SizedBox(
            width: _sampleW,
            child: sample == null
                ? const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('—',
                    style: TextStyle(
                        color: _textMuted, fontSize: 13)),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(sample.dateTime,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _textMuted,
                        fontSize: 9,
                        height: 1.4)),
                const SizedBox(height: 4),
                Text(sample.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                _statusBadge(sample.status),
              ],
            ),
          );
        }),

        // ── Stage status ──
        SizedBox(
          width: _stageW,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(param.stageStatus,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: param.isFail ? _failRed : _navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    ),
  );

  Widget _statusBadge(SampleStatus status) {
    final isPass = status == SampleStatus.pass;
    final color  = isPass ? _passGreen : _failRed;
    final bg     = isPass
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(isPass ? 'PASS' : 'FAIL',
          style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4)),
    );
  }

  // ── Bottom Actions ────────────────────────────────────────────────────────

  Widget _buildBottomActions() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _border)),
    ),
    child: Row(
      children: [
        // Cancel
        Expanded(
          child: OutlinedButton(
            onPressed: _onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel',
                style: TextStyle(
                    color: _textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        // Update Results
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _onUpdateResults,
            icon: const Icon(Icons.edit_outlined,
                color: _navy, size: 15),
            label: const Text('Update\nResults',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: _navy),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Save QC Decision
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _onSaveQCDecision,
            icon: const Icon(Icons.save_outlined,
                color: Colors.white, size: 15),
            label: const Text('Save QC\nDecision',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ),
      ],
    ),
  );
}