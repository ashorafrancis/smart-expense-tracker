import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://smart-expense-tracker-api-gtcg.onrender.com/api';

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // REGISTER USER
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    print("REGISTER STATUS: ${response.statusCode}");
    print("REGISTER BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  // LOGIN USER
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  // ADD EXPENSE
  static Future<Map<String, dynamic>> addExpense({
    required String title,
    required String amount,
    required String category,
    required String currency,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'currency': currency,
      }),
    );

    return jsonDecode(response.body);
  }

  // GET EXPENSES
  static Future<List<dynamic>> getExpenses() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }

  // DELETE EXPENSE
  static Future<Map<String, dynamic>> deleteExpense(String id) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$id'),

      headers: {'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }

  // UPDATE EXPENSE
  static Future<Map<String, dynamic>> updateExpense({
    required String id,
    required String title,
    required String amount,
    required String category,
    required String currency,
  }) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$id'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'currency': currency,
      }),
    );

    return jsonDecode(response.body);
  }

  static double convertCurrency(double amount, String from, String to) {
    Map<String, double> rates = {"₹": 1.0, "\$": 83.0, "€": 90.0, "£": 105.0};

    double inInr = amount * (rates[from] ?? 1.0);

    return inInr / (rates[to] ?? 1.0);
  }

  static Future<double> getTotalExpense() async {
    final expenses = await getExpenses();

    final prefs = await SharedPreferences.getInstance();

    String selectedCurrency = (prefs.getString("currency") ?? "₹ INR").split(
      " ",
    )[0];

    double total = 0;

    for (var expense in expenses) {
      double amount = double.parse(expense['amount'].toString());

      String expenseCurrency = expense['currency'] ?? "₹";

      total += convertCurrency(amount, expenseCurrency, selectedCurrency);
    }

    return total;
  }

  static Future<Map<String, double>> getMonthlyTotals() async {
    final expenses = await getExpenses();

    final prefs = await SharedPreferences.getInstance();

    String selectedCurrency = (prefs.getString("currency") ?? "₹ INR").split(
      " ",
    )[0];

    Map<String, double> monthlyTotals = {};

    for (var expense in expenses) {
      if (expense['createdAt'] == null) {
        continue;
      }

      DateTime date = DateTime.parse(expense['createdAt']);

      String monthYear = "${date.month}-${date.year}";

      double amount = double.parse(expense['amount'].toString());

      String expenseCurrency = expense['currency'] ?? "₹";

      amount = convertCurrency(amount, expenseCurrency, selectedCurrency);

      monthlyTotals[monthYear] = (monthlyTotals[monthYear] ?? 0) + amount;
    }

    return monthlyTotals;
  }

  static Future<Map<String, double>> getCategoryTotals() async {
    final expenses = await getExpenses();

    final prefs = await SharedPreferences.getInstance();

    String selectedCurrency = (prefs.getString("currency") ?? "₹ INR").split(
      " ",
    )[0];

    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      String category = expense['category'];

      double amount = double.parse(expense['amount'].toString());

      String expenseCurrency = expense['currency'] ?? "₹";

      amount = convertCurrency(amount, expenseCurrency, selectedCurrency);

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'email': email}),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE BODY: ${response.body}");

    return jsonDecode(response.body);
  }
}
