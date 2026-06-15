import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_due_screen.dart';

class DueListScreen extends StatefulWidget {
  const DueListScreen({super.key});

  @override
  State<DueListScreen> createState() => _DueListScreenState();
}

class _DueListScreenState extends State<DueListScreen> {
  List dues = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDues();
  }

  Future<void> loadDues() async {
    try {
      final data = await ApiService.getDues();

      setState(() {
        dues = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    return date.split("T")[0];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dues.isEmpty) {
      return const Center(child: Text("No dues added yet"));
    }

    final upcomingDues = dues.where((due) => due["paid"] != true).toList();

    final paidDues = dues.where((due) => due["paid"] == true).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100,
          ),
          children: [
            const Text(
              "Upcoming Dues",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (upcomingDues.isEmpty) const Text("No upcoming dues"),

            ...upcomingDues.map(
              (due) => Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,

                    onTap: () async {
                      await ApiService.toggleDuePaid(due["_id"]);

                      loadDues();
                    },

                    leading: const Icon(Icons.schedule, color: Colors.orange),

                    title: Text(due["title"]),

                    subtitle: Text(
                      "₹${due["amount"]} • Due ${formatDate(due["dueDate"])}",
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == "delete") {
                          await ApiService.deleteDue(due["_id"]);

                          loadDues();
                        }

                        if (value == "edit") {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddDueScreen(due: due),
                            ),
                          );

                          loadDues();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Paid Dues",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (paidDues.isEmpty) const Text("No paid dues"),

            ...paidDues.map(
              (due) => Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,

                    onTap: () async {
                      await ApiService.toggleDuePaid(due["_id"]);

                      loadDues();
                    },

                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),

                    title: Text(
                      due["title"],
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),

                    subtitle: Text(
                      "₹${due["amount"]} • Due ${formatDate(due["dueDate"])}",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == "delete") {
                          await ApiService.deleteDue(due["_id"]);

                          loadDues();
                        }

                        if (value == "edit") {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddDueScreen(due: due),
                            ),
                          );

                          loadDues();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Paid ✓",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),

        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDueScreen()),
              );

              loadDues();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
