import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'tank_cleaning_confirmation.dart';

// Data model
class JobSheet {
  final String id;
  final String date;
  final String title;
  final String description;
  final String status;
  final String lane;

  const JobSheet({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.status,
    required this.lane,
  });

  factory JobSheet.fromMap(String id, Map<dynamic, dynamic> map) {
    return JobSheet(
      id: id,
      date: map['date'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      lane: map['lane'] ?? 'ASSEMBLY_LN_04B',
    );
  }
}

class PreProductionPage extends StatefulWidget {
  const PreProductionPage({super.key});

  @override
  State<PreProductionPage> createState() => _PreProductionPageState();
}

class _PreProductionPageState extends State<PreProductionPage> {
  DateTime? _selectedDate;
  String _selectedStatus = "All";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<JobSheet> _allJobSheets = [];
  bool _isLoading = true;

  final List<String> _statusOptions = ["All", "NEW", "IN PROGRESS", "COMPLETED"];

  @override
  void initState() {
    super.initState();
    _loadJobSheets();
  }

  void _loadJobSheets() {
    final ref = FirebaseDatabase.instance.ref('job_sheets');
    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final List<JobSheet> loaded = [];
        data.forEach((key, value) {
          if (value is Map) {
            loaded.add(JobSheet.fromMap(key.toString(), value));
          }
        });
        setState(() {
          _allJobSheets = loaded;
          _isLoading = false;
        });
      } else {
        setState(() {
          _allJobSheets = [];
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() => _isLoading = false);
    });
  }

  List<JobSheet> get _filteredJobSheets {
    return _allJobSheets.where((job) {
      if (_selectedDate != null) {
        const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
        final formatted = "${months[_selectedDate!.month - 1]} ${_selectedDate!.day}, ${_selectedDate!.year}";
        if (!job.date.contains(formatted)) return false;
      }
      if (_selectedStatus != "All" && job.status != _selectedStatus) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!job.id.toLowerCase().contains(q) &&
            !job.title.toLowerCase().contains(q) &&
            !job.description.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  Color _badgeColor(String status) {
    switch (status) {
      case "NEW":          return const Color(0xFFEEDCFF);
      case "IN PROGRESS":  return const Color(0xFFDDEBFF);
      case "COMPLETED":    return const Color(0xFFD8F3E8);
      default:             return const Color(0xFFE5E7EB);
    }
  }

  String _formatDate(DateTime date) {
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2023, 10, 24),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF17335C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF17335C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _clearDate() => setState(() => _selectedDate = null);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredJobSheets;
    final total = _allJobSheets.length;
    final newCount = _allJobSheets.where((j) => j.status == "NEW").length;
    final inProgressCount = _allJobSheets.where((j) => j.status == "IN PROGRESS").length;
    final completedCount = _allJobSheets.where((j) => j.status == "COMPLETED").length;

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
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'All'),
          BottomNavigationBarItem(icon: Icon(Icons.new_releases_outlined), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Active'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Done'),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF17335C)))
            : SingleChildScrollView(
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
                    child: const Icon(Icons.inventory_2_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text("Workwise",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17335C))),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined)),
                ],
              ),
              const SizedBox(height: 24),
              const Text("PRE-PRODUCTION",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17335C))),
              const SizedBox(height: 6),
              const Text("Select job sheet to begin inspection.",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedDate != null
                                ? const Color(0xFF17335C)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? _formatDate(_selectedDate!)
                                    : "Pick Date",
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedDate != null)
                              GestureDetector(
                                onTap: _clearDate,
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedStatus != "All"
                              ? const Color(0xFF17335C)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          items: _statusOptions
                              .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search Job Sheets...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF17335C))),
                ),
              ),
              const SizedBox(height: 20),

              // Job Cards
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text("No job sheets found",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                ...filtered.map((job) => _jobCard(
                  id: job.id,
                  date: job.date,
                  title: job.title,
                  description: job.description,
                  badge: job.status,
                  badgeColor: _badgeColor(job.status),
                  lane: job.lane,
                )),

              const SizedBox(height: 24),

              // Summary
              const Text("SUMMARY",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17335C))),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _SummaryCard(
                      title: "ALL",
                      count: "$total",
                      color: Colors.white),
                  _SummaryCard(
                      title: "NEW",
                      count: "$newCount",
                      color: const Color(0xFF17335C),
                      whiteText: true),
                  _SummaryCard(
                      title: "IN PROGRESS",
                      count: "$inProgressCount",
                      color: const Color(0xFFDDEBFF)),
                  _SummaryCard(
                      title: "COMPLETED",
                      count: "$completedCount",
                      color: const Color(0xFFD8F3E8)),
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
    required String lane,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Tank Cleaning Confirmation first
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TankCleaningConfirmation(
              jobId: id,
              productName: title,
              laneNumber: lane,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("$id • $date",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(badge,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
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
          color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: whiteText ? Colors.white70 : Colors.grey,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(count,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: whiteText
                      ? Colors.white
                      : const Color(0xFF17335C))),
        ],
      ),
    );
  }
}