import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../dashboard_page.dart';
import '../material_verification_page.dart';
import '../pre_production_page.dart';
import 'stockIn_page.dart';

class StockInConfirmationPage extends StatefulWidget {
  final String poNumber;
  final String supplier;

  const StockInConfirmationPage({
    super.key,
    required this.poNumber,
    required this.supplier,
  });

  @override
  State<StockInConfirmationPage> createState() =>
      _StockInConfirmationPageState();
}

class StockItem {
  final String name;
  final String description;
  String quantity;
  bool isApproved;

  StockItem({
    required this.name,
    required this.description,
    this.quantity = '',
    this.isApproved = false,
  });
}

class _StockInConfirmationPageState extends State<StockInConfirmationPage> {
  int _selectedNavBar = 1; // Inventory tab active
  late List<StockItem> items;

  @override
  void initState() {
    super.initState();
    items = [
      StockItem(
        name: 'Sodium Hypochlorite',
        description: 'INDUSTRIAL GRADE - 100DL MG',
      ),
      StockItem(
        name: 'Caustic Soda (Lye)',
        description: 'HIGH PURITY - 25KG SACKS',
      ),
      StockItem(
        name: 'Hydrochloric Acid',
        description: '35% CONCENTRATION - DRUMS',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17335C);
    const secondaryText = Color(0xFF6F8096);

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
        onItemTapped: (index) {
          _navigateTo(index);
        },
      ),


      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: primary),
                  ),
                  const Expanded(
                    child: Text(
                      'CONFIRM STOCK IN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outlined, color: secondaryText),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined, color: secondaryText),
                  ),
                ],
              ),
            ),

            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: _buildInfoRow('PURCHASE ORDER', widget.poNumber)),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: _buildInfoRow('SUPPLIER', widget.supplier)),
                        ),
                      ],
                    ),
                  ),

                    const SizedBox(height: 16),
                    ...items.asMap().entries.map((entry) {
                      int index = entry.key;
                      StockItem item = entry.value;
                      return _buildStockItemCard(item, index);
                    }),

                    
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Stock In submitted!')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'SUBMIT STOCK IN',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8A99AD),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF17335C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStockItemCard(StockItem item, int index) {
    const primary = Color(0xFF17335C);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header grey background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A99AD),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Content bawah kekal putih
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Scanning UHF tag for ${item.name}'),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_2, size: 18),
                    label: const Text(
                      'SCAN UHF TAG',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'UPDATE QUANTITY (KG)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8A99AD),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

              TextField(
                  onChanged: (value) {
                    setState(() => item.quantity = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Pending scan...',
                    hintStyle: const TextStyle(color: Color.fromARGB(255, 119, 119, 119)),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 246, 246, 246),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF17335C)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        item.isApproved = !item.isApproved;
                      });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          item.isApproved ? Colors.green : const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: item.isApproved
                            ? Colors.green
                            : const Color.fromARGB(255, 217, 214, 214), // 👈 border color
                              width: 1.5,
                      ),
                    ),

                    
                    child: Text(
                      item.isApproved ? 'APPROVED ✓' : 'APPROVE',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 23, 23, 23),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const MaterialVerificationPage(jobId: 'JOB-001');
        break;
      case 1:
        page = const StockInPage();
        break;
      case 2:
        page = const PreProductionPage();
        break;
      case 3:
        page = const DashboardPage();
        break;
      case 4:
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
