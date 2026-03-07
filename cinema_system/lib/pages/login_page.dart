import 'dart:ui';
import 'package:flutter/material.dart';
import 'movie_list_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> floatAnimation;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void login() async {

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter username and password")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      loading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MovieListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// 🌌 蓝紫渐变背景
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

          /// 💜 紫色光晕
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.25),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9A8CFF).withOpacity(0.25),
              ),
            ),
          ),

          /// 背景模糊
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          /// 登录卡片
          Center(
            child: AnimatedBuilder(
              animation: floatAnimation,

              builder: (context, child) {

                return Transform.translate(
                  offset: Offset(0, floatAnimation.value),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

                      child: Container(
                        width: 360,
                        padding: const EdgeInsets.all(30),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
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

                            /// Username
                            TextField(
                              controller: usernameController,
                              style: const TextStyle(color: Colors.white),

                              decoration: InputDecoration(
                                hintText: "Username",
                                hintStyle: const TextStyle(color: Colors.white60),

                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                ),

                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// Password
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),

                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: const TextStyle(color: Colors.white60),

                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.white70,
                                ),

                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// 渐变登录按钮
                            GestureDetector(
                              onTap: loading ? null : login,
                              child: Container(
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
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),

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

                            const SizedBox(height: 15),

                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Create Account",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}