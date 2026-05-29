import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();

  final amountController = TextEditingController();

  String selectedCategory = "Food";

  String selectedCurrency = "₹ INR";

  @override
  void initState() {
    super.initState();
    loadCurrency();
  }

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedCurrency = prefs.getString("currency") ?? "₹ INR";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Add Expense"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),

        child: Column(
          children: [
            TextField(
              controller: titleController,

              decoration: InputDecoration(
                hintText: "Expense Title",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                hintText: "Amount",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedCurrency,

              items: const [
                DropdownMenuItem(value: "₹ INR", child: Text("₹ INR")),
                DropdownMenuItem(value: "\$ USD", child: Text("\$ USD")),
                DropdownMenuItem(value: "€ EUR", child: Text("€ EUR")),
                DropdownMenuItem(value: "£ GBP", child: Text("£ GBP")),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCurrency = value;
                  });
                }
              },

              decoration: const InputDecoration(
                labelText: "Currency",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedCategory,

              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Travel", child: Text("Travel")),
                DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                DropdownMenuItem(value: "Bills", child: Text("Bills")),
                DropdownMenuItem(
                  value: "Entertainment",
                  child: Text("Entertainment"),
                ),
                DropdownMenuItem(value: "Health", child: Text("Health")),
                DropdownMenuItem(value: "Others", child: Text("Others")),
              ],

              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },

              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                onPressed: () async {
                  try {
                    final response = await ApiService.addExpense(
                      title: titleController.text,
                      amount: amountController.text,
                      category: selectedCategory,
                      currency: selectedCurrency.split(" ")[0],
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'])),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },

                child: const Text(
                  "Save Expense",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
