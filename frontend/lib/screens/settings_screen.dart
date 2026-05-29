import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SettingsScreen({super.key, required this.toggleTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = "User";

  String email = "user@email.com";

  String avatar = "";

  String selectedCurrency = "₹ INR";

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString("name") ?? "User";

      email = prefs.getString("email") ?? "user@email.com";

      avatar = prefs.getString("avatar") ?? "";

      selectedCurrency = prefs.getString("currency") ?? "₹ INR";

      isDarkMode = prefs.getBool("darkMode") ?? false;
    });
  }

  Future<void> saveAvatar(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("avatar", value);

    loadUserData();
  }

  Future<void> saveCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("currency", value);

    loadUserData();
  }

  void openAvatarPicker() {
    final avatars = ["🙂", "😎", "🧑‍💻", "👨", "👩", "🐼", "🦊"];

    showModalBottomSheet(
      context: context,

      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            itemCount: avatars.length,

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),

            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  saveAvatar(avatars[index]);

                  Navigator.pop(context);
                },

                child: Center(
                  child: Text(
                    avatars[index],
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              );
            },
          ),

          TextButton(
            onPressed: () {
              saveAvatar("");

              Navigator.pop(context);
            },

            child: const Text(
              "Remove Avatar",

              style: TextStyle(color: Colors.red),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Settings",

                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),
              GestureDetector(
                onTap: openAvatarPicker,

                child: CircleAvatar(
                  radius: 45,

                  backgroundColor: avatar.isEmpty
                      ? Colors.green
                      : Colors.transparent,

                  child: avatar.isEmpty
                      ? Text(
                          userName.substring(0, 1).toUpperCase(),

                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(avatar, style: const TextStyle(fontSize: 48)),
                ),
              ),

              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(email),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text("Edit Profile"),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );

                  loadUserData();
                },
              ),

              ListTile(
                leading: const Icon(Icons.currency_rupee, color: Colors.green),
                title: const Text("Currency"),
                trailing: DropdownButton<String>(
                  value: selectedCurrency,
                  underline: const SizedBox(),
                  items: ["₹ INR", "\$ USD", "€ EUR", "£ GBP"].map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      saveCurrency(value);
                    }
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.green),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (_) async {
                    widget.toggleTheme();

                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: logout,
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
