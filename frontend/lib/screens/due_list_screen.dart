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

    return Stack(
      children: [
        dues.isEmpty
            ? const Center(child: Text("No dues added yet"))
            : ListView.builder(
                itemCount: dues.length,
                itemBuilder: (context, index) {
                  final due = dues[index];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: Icon(
                        due["paid"] ? Icons.check_circle : Icons.schedule,
                        color: due["paid"] ? Colors.green : Colors.orange,
                      ),
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
                          const PopupMenuItem(
                            value: "edit",
                            child: Text("Edit"),
                          ),

                          const PopupMenuItem(
                            value: "delete",
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
