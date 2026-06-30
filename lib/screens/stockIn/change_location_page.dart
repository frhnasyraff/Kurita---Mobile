import 'package:flutter/material.dart';
import '../QualityControl/dashboard_page.dart';
import '../preproduct/material_verification_page.dart';
import '../preproduct/pre_production_page.dart';
import '../widgets/bottom_nav_bar.dart';

class ChangeLocationPage extends StatefulWidget {
  final String? initialItem;
  final String? currentLocation;

  const ChangeLocationPage({
    super.key,
    this.initialItem,
    this.currentLocation,
  });

  @override
  State<ChangeLocationPage> createState() => _ChangeLocationPageState();
}

class _ChangeLocationPageState extends State<ChangeLocationPage> {
  final TextEditingController _newLocationController = TextEditingController();
  final int _selectedNavBar = 1;
  bool _tagScanned = false;
  bool _locationScanned = false;

  String get _materialName => widget.initialItem ?? 'Industrial Disinfectant X1';
  String get _currentLocation => widget.currentLocation ?? 'Lane 04 - Sector B';

  @override
  void dispose() {
    _newLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _tagScanned && _locationScanned;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      bottomNavigationBar: BottomNavBar(
        items: [
          (Icons.verified_outlined, 'Quality', _selectedNavBar == 0),
          (Icons.inventory_2_outlined, 'Inventory', _selectedNavBar == 1),
          (Icons.precision_manufacturing_outlined, 'Production', _selectedNavBar == 2),
          (Icons.local_shipping_outlined, 'Delivery', _selectedNavBar == 3),
          (Icons.more_horiz, 'Others', _selectedNavBar == 4),
        ],
        onItemTapped: _navigateTo,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const Text(
                'CHANGE LOCATION',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Transfer stock between warehouse locations.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 22),
              _buildStepCard(
                step: 'STEP 01',
                title: 'SCAN UHF TAG',
                icon: Icons.sensors_outlined,
                enabled: true,
                complete: _tagScanned,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tagScanned) ...[
                      _buildDetailRow('MATERIAL NAME', _materialName),
                      _buildDetailRow('CURRENT LOCATION', _currentLocation),
                      const SizedBox(height: 12),
                    ],
                    _buildPrimaryButton(
                      icon: Icons.sensors_outlined,
                      label: _tagScanned ? 'UHF TAG SCANNED' : 'INITIATE UHF SCAN',
                      onTap: () => setState(() => _tagScanned = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                step: 'STEP 02',
                title: 'NEW LOCATION',
                icon: Icons.location_on_outlined,
                enabled: _tagScanned,
                complete: _locationScanned,
                child: Column(
                  children: [
                    TextField(
                      controller: _newLocationController,
                      enabled: _tagScanned,
                      onChanged: (value) {
                        setState(() => _locationScanned = value.trim().isNotEmpty);
                      },
                      decoration: InputDecoration(
                        hintText: 'Scan new location QR code',
                        prefixIcon: const Icon(Icons.qr_code_scanner_outlined),
                        filled: true,
                        fillColor: _tagScanned ? Colors.white : const Color(0xFFF1F3F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildOutlineButton(
                      icon: Icons.qr_code_2_outlined,
                      label: 'SCAN NEW LOCATION QR CODE',
                      enabled: _tagScanned,
                      onTap: () {
                        _newLocationController.text = 'Lane 07 - Sector C';
                        setState(() => _locationScanned = true);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                step: 'STEP 03',
                title: 'MOVEMENT DETAILS',
                icon: Icons.receipt_long_outlined,
                enabled: canSubmit,
                complete: false,
                child: Column(
                  children: [
                    _buildDetailRow('MATERIAL NAME', _tagScanned ? _materialName : '-'),
                    _buildDetailRow('LOT NUMBER', _tagScanned ? 'CHM-24-012-A' : '-'),
                    _buildDetailRow(
                      'DESTINATION',
                      _locationScanned ? _newLocationController.text : '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: canSubmit ? _submitTransfer : null,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text(
                    'SUBMIT TRANSFER',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF17335C),
                    disabledBackgroundColor: const Color(0xFFE3E5E8),
                    disabledForegroundColor: const Color(0xFF8A8F98),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF17335C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Workwise',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF17335C),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required IconData icon,
    required bool enabled,
    required bool complete,
    required Widget child,
  }) {
    final color = enabled ? const Color(0xFF17335C) : const Color(0xFFB7BFCC);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.54,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: enabled ? const Color(0xFFEEF2FF) : const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    step,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(complete ? Icons.check_circle : icon, size: 17, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF17335C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 17),
        label: FittedBox(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF17335C),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8A99AD),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF17335C),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitTransfer() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transfer submitted to ${_newLocationController.text}')),
    );
  }

  void _navigateTo(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const MaterialVerificationPage(jobId: 'JOB-001');
        break;
      case 1:
        return;
      case 2:
        page = const PreProductionPage();
        break;
      case 3:
        page = const DashboardPage();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }
}
