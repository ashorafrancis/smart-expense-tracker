import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddDueScreen extends StatefulWidget {
  final Map? due;

  const AddDueScreen({super.key, this.due});

  @override
  State<AddDueScreen> createState() => _AddDueScreenState();
}

class _AddDueScreenState extends State<AddDueScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? selectedDate;

  int remindBefore = 1;

  @override
  void initState() {
    super.initState();

    if (widget.due != null) {
      titleController.text = widget.due!["title"] ?? "";

      amountController.text = widget.due!["amount"].toString();

      notesController.text = widget.due!["notes"] ?? "";

      selectedDate = DateTime.parse(widget.due!["dueDate"]);

      remindBefore = widget.due!["remindBefore"] ?? 1;
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveDue() async {
    if (selectedDate == null) return;

    final data = {
      'title': titleController.text,
      'amount': double.parse(amountController.text),
      'dueDate': selectedDate!.toIso8601String(),
      'notes': notesController.text,
      'remindBefore': remindBefore,
    };

    try {
      if (widget.due == null) {
        await ApiService.createDue(
          title: titleController.text,
          amount: double.parse(amountController.text),
          dueDate: selectedDate!.toIso8601String(),
          notes: notesController.text,
          remindBefore: remindBefore,
        );
      } else {
        await ApiService.updateDue(widget.due!["_id"], data);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.due == null ? "Add Due" : "Edit Due"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "Notes"),
            ),

            const SizedBox(height: 20),

            ListTile(
              title: Text(
                selectedDate == null
                    ? "Select Due Date"
                    : selectedDate.toString().split(" ")[0],
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: pickDate,
            ),

            const SizedBox(height: 20),

            DropdownButton<int>(
              value: remindBefore,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 1, child: Text("1 day before")),
                DropdownMenuItem(value: 3, child: Text("3 days before")),
                DropdownMenuItem(value: 7, child: Text("7 days before")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    remindBefore = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveDue,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  widget.due == null ? "Save Due" : "Update Due",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
