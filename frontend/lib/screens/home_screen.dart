import 'package:flutter/material.dart';

import 'add_expense_screen.dart';
import '../services/api_service.dart';
import 'edit_expense_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = "";

  String selectedFilter = "All";
  String currency = "₹";

  @override
  void initState() {
    super.initState();
    loadCurrency();
  }

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString("currency") ?? "₹ INR";

    setState(() {
      currency = saved.split(" ")[0];
    });
  }

  Future<List<dynamic>> fetchExpenses() async {
    return await ApiService.getExpenses();
  }

  Widget buildFilterChip(String category) {
    final isSelected = selectedFilter == category;

    return Padding(
      padding: const EdgeInsets.only(right: 10),

      child: ChoiceChip(
        label: Text(category),

        selected: isSelected,

        selectedColor: Colors.green,

        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),

        onSelected: (value) {
          setState(() {
            selectedFilter = category;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green, title: const Text("Home")),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),

            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: "Search expenses",

                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // CATEGORY FILTERS
          SizedBox(
            height: 45,

            child: ListView(
              scrollDirection: Axis.horizontal,

              children: [
                const SizedBox(width: 10),

                buildFilterChip("All"),
                buildFilterChip("Food"),
                buildFilterChip("Travel"),
                buildFilterChip("Shopping"),
                buildFilterChip("Bills"),
                buildFilterChip("Entertainment"),
                buildFilterChip("Health"),
                buildFilterChip("Others"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ADD BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

            onPressed: () async {
              await Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );

              setState(() {});
            },

            child: const Text(
              "Add Expense",

              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchExpenses(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final expenses = snapshot.data!;

                final filteredExpenses = expenses.where((expense) {
                  final title = expense['title'].toString().toLowerCase();

                  final category = expense['category'].toString().toLowerCase();

                  final matchesSearch = title.contains(searchText);

                  final matchesCategory =
                      selectedFilter == "All" ||
                      category == selectedFilter.toLowerCase();

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredExpenses.isEmpty) {
                  return const Center(child: Text("No Expenses Found"));
                }

                return ListView.builder(
                  itemCount: filteredExpenses.length,

                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      child: ListTile(
                        title: Text(expense['title']),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(expense['category']),

                            Text(
                              "${expense['currency'] ?? '₹'} ${expense['amount']}",

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        trailing: PopupMenuButton(
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

                          onSelected: (value) async {
                            if (value == "edit") {
                              await Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditExpenseScreen(expense: expense),
                                ),
                              );

                              setState(() {});
                            }

                            if (value == "delete") {
                              await ApiService.deleteExpense(expense['_id']);

                              setState(() {});
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
