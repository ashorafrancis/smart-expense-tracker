import 'package:flutter/material.dart';

import '../services/api_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Map expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleController;

  late TextEditingController amountController;

  late String selectedCategory;

  late String selectedCurrency;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.expense['title']);

    amountController = TextEditingController(
      text: widget.expense['amount'].toString(),
    );

    selectedCategory = widget.expense['category'];

    selectedCurrency = widget.expense['currency'] ?? "₹";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Edit Expense"),
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

              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: amountController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Amount",
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

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedCurrency,

              items: const [
                DropdownMenuItem(value: "₹", child: Text("₹ INR")),

                DropdownMenuItem(value: "\$", child: Text("\$ USD")),

                DropdownMenuItem(value: "€", child: Text("€ EUR")),

                DropdownMenuItem(value: "£", child: Text("£ GBP")),
              ],

              onChanged: (value) {
                setState(() {
                  selectedCurrency = value!;
                });
              },

              decoration: const InputDecoration(
                labelText: "Currency",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                onPressed: () async {
                  await ApiService.updateExpense(
                    id: widget.expense['_id'],

                    title: titleController.text,

                    amount: amountController.text,

                    category: selectedCategory,

                    currency: selectedCurrency,
                  );

                  Navigator.pop(context);
                },

                child: const Text(
                  "Update Expense",

                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
