import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PricingManagePage extends StatefulWidget {
  const PricingManagePage({super.key});

  @override
  State<PricingManagePage> createState() => _PricingManagePageState();
}

class _PricingManagePageState extends State<PricingManagePage> {
  List rules = [];

  @override
  void initState() {
    super.initState();
    loadRules();
  }

  Future<void> loadRules() async {
    final res = await http.get(
      Uri.parse("https://cinema-backend-x2gl.onrender.com/api/rules"),
    );

    if (res.statusCode == 200) {
      setState(() {
        rules = json.decode(res.body);
      });
    }
  }

  Future<void> updateRule(Map rule) async {
    await http.put(
      Uri.parse("https://cinema-backend-x2gl.onrender.com/api/rules/${rule["id"]}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(rule),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("Pricing Rules"),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: rules.length,
        itemBuilder: (_, i) {
          final rule = rules[i];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _glassCard(rule),
          );
        },
      ),
    );
  }

  Widget _glassCard(Map rule) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [

              /// 左侧
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule["ruleName"],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      rule["ruleType"],
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),

              /// 数值调节
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: rule["value"].toString(),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) {
                    rule["value"] = double.parse(v);
                  },
                ),
              ),

              const SizedBox(width: 10),

              /// 开关
              Switch(
                value: rule["enabled"],
                onChanged: (v) {
                  setState(() {
                    rule["enabled"] = v;
                  });
                  updateRule(rule);
                },
              ),

              /// 保存按钮
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: () {
                  updateRule(rule);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}