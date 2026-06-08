import 'package:flutter/material.dart';

class PreProductionPage extends StatelessWidget {
  const PreProductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF17335C),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF17335C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases_outlined),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Done',
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17335C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Workwise",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17335C),
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                "PRE-PRODUCTION",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17335C),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Select job sheet to begin inspection.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // Filters
              Row(
                children: [

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16),
                          SizedBox(width: 8),
                          Text("Oct 24, 2023"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text("All"),
                          Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: "Search Job Sheets...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Cards
              _jobCard(
                id: "JS-9012",
                date: "Oct 24, 2023",
                title: "Coolant Base Alpha - Lane",
                description:
                "Precision housing bracket production × 50 units.",
                badge: "NEW",
                badgeColor: const Color(0xFFEEDCFF),
              ),

              _jobCard(
                id: "JS-8845",
                date: "Oct 23, 2023",
                title: "Hydraulic Fluid X - Lane 2",
                description:
                "Standard calibration protocol for proximity arrays.",
                badge: "IN PROGRESS",
                badgeColor: const Color(0xFFDDEBFF),
              ),

              _jobCard(
                id: "JS-8721",
                date: "Oct 22, 2023",
                title: "Lubricant Batch B - Lane",
                description:
                "Custom M12 threading for aerospace fasteners.",
                badge: "COMPLETED",
                badgeColor: const Color(0xFFD8F3E8),
              ),

              _jobCard(
                id: "JS-8600",
                date: "Oct 22, 2023",
                title: "Synthetic Oil G - Lane 4",
                description:
                "Final inspection for shipment readiness.",
                badge: "IN PROGRESS",
                badgeColor: const Color(0xFFDDEBFF),
              ),

              const SizedBox(height: 24),

              const Text(
                "SUMMARY",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17335C),
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,

                children: const [

                  _SummaryCard(
                    title: "ALL",
                    count: "124",
                    color: Colors.white,
                  ),

                  _SummaryCard(
                    title: "NEW",
                    count: "18",
                    color: Color(0xFF17335C),
                    whiteText: true,
                  ),

                  _SummaryCard(
                    title: "IN PROGRESS",
                    count: "42",
                    color: Color(0xFFDDEBFF),
                  ),

                  _SummaryCard(
                    title: "COMPLETED",
                    count: "64",
                    color: Color(0xFFD8F3E8),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobCard({
    required String id,
    required String date,
    required String title,
    required String description,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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

              Text(
                "$id • $date",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final bool whiteText;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    this.whiteText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: TextStyle(
              color: whiteText ? Colors.white70 : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: whiteText
                  ? Colors.white
                  : const Color(0xFF17335C),
            ),
          ),
        ],
      ),
    );
  }
}