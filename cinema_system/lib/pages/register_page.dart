import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {

  final usernameController = TextEditingController();
  final idController = TextEditingController();
  final phoneController = TextEditingController();
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  late AnimationController floatController;
  late Animation<double> floatAnim;

  late AnimationController glowController;
  late Animation<double> glowAnim;

  bool loading = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    floatAnim = Tween(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: floatController, curve: Curves.easeInOut),
    );

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnim = Tween(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    floatController.dispose();
    glowController.dispose();
    super.dispose();
  }

  void register() async {
  if (usernameController.text.isEmpty ||
      idController.text.isEmpty ||
      phoneController.text.isEmpty ||
      nicknameController.text.isEmpty ||
      passwordController.text.isEmpty ||
      confirmController.text.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  if (passwordController.text != confirmController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  setState(() => loading = true);

  try {
    print("Sending request...");

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8080/api/users/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "userId": idController.text,
        "phone": phoneController.text,
        "nickname": nicknameController.text,
        "password": passwordController.text,
      }),
    );

    setState(() => loading = false);

    print("Register Response: ${response.body}");

    if (response.statusCode == 200 &&
        response.body.contains("success")) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Register Success!")),
      );

      Navigator.pop(context); // 返回登录页

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }

  } catch (e) {
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Connection failed")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// 🌌 背景
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0F1A),
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 💜 光晕
          Positioned(top: -120, left: -120, child: _glowCircle(300)),
          Positioned(bottom: -150, right: -100, child: _glowCircle(350)),

          /// 🧊 注册卡片
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),

                child: AnimatedBuilder(
                  animation: floatAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, floatAnim.value),
                      child: child,
                    );
                  },
                  child: _registerCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6C63FF).withOpacity(0.2),
      ),
    );
  }

  Widget _registerCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Icon(
              Icons.app_registration,
              size: 60,
              color: Color(0xFF6C63FF),
            ),

            const SizedBox(height: 10),

            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _inputField(usernameController, "Username", Icons.person),
            const SizedBox(height: 15),

            _inputField(idController, "ID", Icons.badge),
            const SizedBox(height: 15),

            _inputField(phoneController, "Phone", Icons.phone),
            const SizedBox(height: 15),

            _inputField(nicknameController, "Nickname", Icons.face),
            const SizedBox(height: 15),

            _inputField(passwordController, "Password", Icons.lock, true),
            const SizedBox(height: 15),

            _inputField(confirmController, "Confirm Password", Icons.lock, true),

            const SizedBox(height: 25),

            GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) {
                setState(() => _pressed = false);
                if (!loading) register();
              },
              onTapCancel: () => setState(() => _pressed = false),

              child: AnimatedScale(
                scale: _pressed ? 0.95 : 1,
                duration: const Duration(milliseconds: 100),

                child: AnimatedBuilder(
                  animation: glowAnim,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF9A8CFF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF)
                                .withOpacity(glowAnim.value),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Center(
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            "REGISTER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Login",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint,
    IconData icon,
    [bool obscure = false]
  ) {
    return Focus(
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: focused
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: Icon(icon, color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          );
        },
      ),
    );
  }
}