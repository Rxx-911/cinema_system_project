import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PricingRulePage extends StatefulWidget {
  const PricingRulePage({super.key});

  @override
  State<PricingRulePage> createState() => _PricingRulePageState();
}

class _PricingRulePageState extends State<PricingRulePage> {

  List rules = [];

  @override
  void initState() {
    super.initState();
    fetchRules();
  }

  Future<void> fetchRules() async {
    final res = await http.get(Uri.parse("https://cinema-backend-x2gl.onrender.com/api/rules"));
    setState(() {
      rules = json.decode(res.body);
    });
  }

  Future<void> updateRule(int id, double value) async {
    await http.put(
      Uri.parse("https://cinema-backend-x2gl.onrender.com/api/rules/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "value": value,
        "enabled": true,
      }),
    );

    fetchRules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(title: const Text("Pricing Rules")),
      body: ListView.builder(
        itemCount: rules.length,
        itemBuilder: (context, index) {
          final rule = rules[index];
          final controller =
              TextEditingController(text: rule["value"].toString());

          return ListTile(
            title: Text(
              rule["ruleName"],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Type: ${rule["ruleType"]}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: SizedBox(
              width: 120,
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (val) {
                  updateRule(rule["id"], double.parse(val));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}