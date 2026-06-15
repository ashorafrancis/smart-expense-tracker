import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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

  Future<double> fetchTotal() async {
    return await ApiService.getTotalExpense();
  }

  Future<Map<String, double>> fetchCategoryTotals() async {
    return await ApiService.getCategoryTotals();
  }

  Future<Map<String, double>> fetchMonthlyTotals() async {
    return await ApiService.getMonthlyTotals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Analytics"),
      ),

      body: FutureBuilder<double>(
        future: fetchTotal(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final total = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),

            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: Colors.green,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Total Expenses",

                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "$currency ${total.toStringAsFixed(2)}",

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      "Category Breakdown",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  FutureBuilder<Map<String, double>>(
                    future: fetchCategoryTotals(),

                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      final categories = snapshot.data!;

                      return Column(
                        children: categories.entries.map((entry) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.category,
                                color: Colors.green,
                              ),

                              title: Text(entry.key),

                              trailing: Text(
                                "$currency ${entry.value.toStringAsFixed(2)}",
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      "Expense Chart",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  FutureBuilder<Map<String, double>>(
                    future: fetchCategoryTotals(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      final categories = snapshot.data!;

                      final maxAmount = categories.values.reduce(
                        (a, b) => a > b ? a : b,
                      );

                      return Column(
                        children: categories.entries.map((entry) {
                          final percentage = entry.value / maxAmount;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        minHeight: 14,
                                        borderRadius: BorderRadius.circular(10),
                                        backgroundColor: Colors.green.shade100,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.green,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Text(
                                      "$currency ${entry.value.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Dues Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  FutureBuilder<List<dynamic>>(
                    future: ApiService.getDues(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      final dues = snapshot.data!;

                      final pendingDues = dues
                          .where((due) => due["paid"] == false)
                          .toList();

                      final paidDues = dues
                          .where((due) => due["paid"] == true)
                          .toList();

                      double totalPending = 0;

                      for (var due in pendingDues) {
                        totalPending +=
                            double.tryParse(due["amount"].toString()) ?? 0;
                      }

                      return Column(
                        children: [
                          Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.pending_actions,
                                color: Colors.orange,
                              ),
                              title: const Text("Pending Dues"),
                              trailing: Text("${pendingDues.length}"),
                            ),
                          ),

                          Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              title: const Text("Paid Dues"),
                              trailing: Text("${paidDues.length}"),
                            ),
                          ),

                          Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.currency_rupee,
                                color: Colors.blue,
                              ),
                              title: const Text("Total Pending Amount"),
                              trailing: Text(
                                "$currency ${totalPending.toStringAsFixed(2)}",
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
