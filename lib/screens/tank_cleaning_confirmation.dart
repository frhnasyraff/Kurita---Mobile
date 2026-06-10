import 'package:flutter/material.dart';
import 'wash_tank_page.dart';
import 'material_verification_page.dart';

class TankCleaningConfirmation extends StatefulWidget {
  final String jobId;
  final String productName;
  final String laneNumber;

  const TankCleaningConfirmation({
    super.key,
    required this.jobId,
    required this.productName,
    required this.laneNumber,
  });

  @override
  State<TankCleaningConfirmation> createState() =>
      _TankCleaningConfirmationState();
}

class _TankCleaningConfirmationState extends State<TankCleaningConfirmation> {
  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color navy        = Color(0xFF17335C);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningBg   = Color(0xFFFFFBEB);
  static const Color warningBdr  = Color(0xFFFCD34D);
  static const Color dangerRed   = Color(0xFFDC2626);
  static const Color dangerBg    = Color(0xFFFEF2F2);
  static const Color purpleAccent = Color(0xFF7C3AED);

  bool _isVerified = false;

  void _onConfirm() {
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify the cleaning protocol first.'),
          backgroundColor: dangerRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to Wash Tank Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WashTankPage(
          jobSheetId: widget.jobId,
          productName: widget.productName,
          laneNumber: widget.laneNumber,
        ),
      ),
    );
  }

  void _onCancel() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Critical Safety Banner ──────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: warningAmber,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'CRITICAL SAFETY REQUIREMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──────────────────────────────────────────
                      const Text(
                        'Tank Cleaning\nConfirmation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: navy,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Job ID Badge ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: purpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: purpleAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: purpleAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text('W',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.jobId,
                              style: TextStyle(
                                color: purpleAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Question ───────────────────────────────────────
                      const Text(
                        'Has the tank been thoroughly cleaned and inspected for this batch?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: navy,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Warning Box ────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: dangerBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: dangerRed.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_rounded,
                                color: dangerRed, size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Warning: Improper cleaning leads to batch contamination and mechanical damage.',
                                style: TextStyle(
                                  color: dangerRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Checkbox ───────────────────────────────────────
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isVerified = !_isVerified),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isVerified
                                ? Colors.green.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isVerified
                                  ? Colors.green
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _isVerified
                                      ? Colors.green
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _isVerified
                                        ? Colors.green
                                        : const Color(0xFFD1D5DB),
                                  ),
                                ),
                                child: _isVerified
                                    ? const Icon(Icons.check,
                                    color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'I have verified the cleaning protocol and inspected the tank.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: navy,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Yes Confirmed Button ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isVerified ? _onConfirm : null,
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'Yes, Confirmed',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isVerified
                                ? Colors.green[700]
                                : Colors.grey[400],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Cancel Button ──────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _onCancel,
                          child: const Text(
                            'Cancel / Return',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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