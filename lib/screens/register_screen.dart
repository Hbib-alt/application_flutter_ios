import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _nameController =
      TextEditingController();

  final _phoneController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool loading = false;

  Future<void> register() async {

    try {

      setState(() {
        loading = true;
      });

      // =========================
      // CREATE AUTH ACCOUNT
      // =========================

      final credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(

        email:
            _emailController.text.trim(),

        password:
            _passwordController.text.trim(),
      );

      final uid =
          credential.user!.uid;

      // =========================
      // CREATE USER DOCUMENT
      // =========================

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set({

        "name":
            _nameController.text.trim(),

        "phone":
            _phoneController.text.trim(),

        "email":
            _emailController.text.trim(),

        "role":
            "collector",

        "createdAt":
            Timestamp.now(),
      });

      // =========================
      // SUCCESS
      // =========================

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content:
                Text("✅ Compte créé"),
          ),
        );

        Navigator.pop(context);
      }

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text(e.message ?? "Erreur"),
        ),
      );

    } finally {

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Créer un compte"),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: ListView(

          children: [

            TextField(

              controller:
                  _nameController,

              decoration:
                  const InputDecoration(
                labelText: "Nom",
              ),
            ),

            const SizedBox(height: 16),

            TextField(

              controller:
                  _phoneController,

              decoration:
                  const InputDecoration(
                labelText: "Téléphone",
              ),
            ),

            const SizedBox(height: 16),

            TextField(

              controller:
                  _emailController,

              decoration:
                  const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 16),

            TextField(

              controller:
                  _passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(
                labelText: "Mot de passe",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              onPressed:
                  loading
                      ? null
                      : register,

              child:
                  loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Créer compte",
                        ),
            ),
          ],
        ),
      ),
    );
  }
}