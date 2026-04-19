import 'dart:ui';
import 'package:flutter/material.dart';
import 'movie_list_page.dart';
import 'register_page.dart';
  import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Adminpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController floatController;
  late Animation<double> floatAnim;

  late AnimationController glowController;
  late Animation<double> glowAnim;

  bool loading = false;
  bool _pressed = false; // ⭐ 按压状态
  bool isMember = false; // ⭐ 新增


  Future<void> _showMemberDialog() async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Membership"),
        content: const Text("Are you a member?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );

  if (result != null) {
    isMember = result;
  }
}

  @override
void initState() {
  super.initState();

  floatController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  floatAnim = Tween<double>(begin: -10, end: 10).animate(
    CurvedAnimation(parent: floatController, curve: Curves.easeInOut),
  );

  glowController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  glowAnim = Tween<double>(begin: 0.2, end: 0.6).animate(
    CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
  );
}

  @override
  void dispose() {
    floatController.dispose();
    glowController.dispose();
    super.dispose();
  }



void login() async {
  if (usernameController.text.isEmpty ||
      passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter username and password")),
    );
    return;
  }

  setState(() => loading = true);

  await Future.delayed(const Duration(milliseconds: 800));

  setState(() => loading = false);

  /// ⭐⭐⭐ 假权限系统（加分）
  if (usernameController.text == "admin") {
    isMember = true;
  } else {
    await _showMemberDialog();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Welcome, ${usernameController.text}!"),
    ),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => MovieListPage(
        username: usernameController.text,
        isMember: isMember,
      ),
    ),
  );
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
          Positioned(
            top: -120,
            left: -120,
            child: _glowCircle(300),
          ),

          Positioned(
            bottom: -150,
            right: -100,
            child: _glowCircle(350),
          ),

          /// 🧊 登录卡片
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
                  child: _loginCard(),
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

  /// 🧊 登录卡片
  Widget _loginCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Icon(
            Icons.local_movies,
            size: 60,
            color: Color(0xFF6C63FF),
          ),

          const SizedBox(height: 10),

          const Text(
            "Cinema Booking",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          _inputField(
            controller: usernameController,
            hint: "UserId",
            icon: Icons.person,
          ),

          const SizedBox(height: 20),

          _inputField(
            controller: passwordController,
            hint: "Password",
            icon: Icons.lock,
            obscure: true,
          ),

          const SizedBox(height: 30),

          /// 🔥 修复后的按钮（关键）
          GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              if (!loading) login();
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
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );

              if (result != null) {
                usernameController.text = result;
              }
            },
            child: const Text(
              "Create Account",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 10),

          /// 👇 Admin入口
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPage(),
                  ),
                );
              },
              child: const Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
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