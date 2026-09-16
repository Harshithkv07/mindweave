import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'caretaker_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController(text: 'Margaret');
  final TextEditingController patientEmailController =
      TextEditingController(text: 'patient@mindweave.com');
  final TextEditingController patientPasswordController =
      TextEditingController(text: 'patient123');
  final TextEditingController caretakerEmailController =
      TextEditingController(text: 'caregiver@example.com');
  final TextEditingController caretakerPasswordController =
      TextEditingController(text: 'password123');

  String selectedLanguage = 'English';
  bool isCaretakerTab = false;
  bool obscurePassword = true;
  bool obscurePatientPassword = true;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    patientEmailController.dispose();
    patientPasswordController.dispose();
    caretakerEmailController.dispose();
    caretakerPasswordController.dispose();
    super.dispose();
  }

  void continueToHome() {
    final name = nameController.text.trim();
    final email = patientEmailController.text.trim();
    final password = patientPasswordController.text;

    setState(() {
      errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your patient email address';
      });
      return;
    }

    if (password.length < 4) {
      setState(() {
        errorMessage = 'Patient password must be at least 4 characters';
      });
      return;
    }

    final displayName = name.isNotEmpty ? name : (email.contains('@') ? email.split('@').first : 'Patient');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome, $displayName! Signed into Patient Portal.'),
        backgroundColor: Colors.indigo.shade700,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          name: displayName,
          language: selectedLanguage,
        ),
      ),
    );
  }

  void loginCaretaker() {
    final email = caretakerEmailController.text.trim();
    final password = caretakerPasswordController.text;

    setState(() {
      errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Please enter caretaker email address';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    // Authenticated Caretaker navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome Caretaker ($email)! Access granted.'),
        backgroundColor: Colors.green.shade700,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CaretakerDashboardScreen(
          patientName: 'Margaret',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Column(
                children: [
                  const Text(
                    '🧠',
                    style: TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MindWeave',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCaretakerTab
                        ? 'Caretaker & Family Management Portal'
                        : 'Personalized Memory & Cognitive Companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Portal Toggle Switch
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              isCaretakerTab = false;
                              errorMessage = null;
                            }),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isCaretakerTab
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: !isCaretakerTab
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '👤 Patient Portal',
                                  style: TextStyle(
                                    fontWeight: !isCaretakerTab
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: !isCaretakerTab
                                        ? Colors.indigo
                                        : Colors.grey.shade700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              isCaretakerTab = true;
                              errorMessage = null;
                            }),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isCaretakerTab
                                    ? Colors.indigo
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isCaretakerTab
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '🛡️ Caretaker Login',
                                  style: TextStyle(
                                    fontWeight: isCaretakerTab
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCaretakerTab
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!isCaretakerTab) ...[
                    // PATIENT PORTAL WITH CREDENTIALS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_person_outlined, color: Colors.indigo.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Patient credentials required for customized voice reminders and memory routines.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Patient Name',
                        hintText: 'Enter your name (e.g., Margaret)',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          size: 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: patientEmailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Patient Email Address',
                        hintText: 'patient@mindweave.com',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: patientPasswordController,
                      obscureText: obscurePatientPassword,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Patient Password',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          size: 24,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePatientPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePatientPassword = !obscurePatientPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.key, size: 16, color: Colors.indigo),
                        label: const Text(
                          'Demo: patient@mindweave.com / patient123',
                          style: TextStyle(fontSize: 12, color: Colors.indigo),
                        ),
                        onPressed: () {
                          setState(() {
                            nameController.text = 'Margaret';
                            patientEmailController.text = 'patient@mindweave.com';
                            patientPasswordController.text = 'patient123';
                            errorMessage = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedLanguage,
                      decoration: InputDecoration(
                        labelText: 'Preferred Language for Voice Alerts',
                        prefixIcon: const Icon(
                          Icons.language,
                          size: 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English (US)'),
                        ),
                        DropdownMenuItem(
                          value: 'Tamil',
                          child: Text('தமிழ் (Tamil)'),
                        ),
                        DropdownMenuItem(
                          value: 'Hindi',
                          child: Text('हिन्दी (Hindi)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: continueToHome,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'Sign In to Patient Portal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // CARETAKER LOGIN WITH PASSWORD CREDENTIALS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Password credentials required to access patient care plans & diagnostics.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: caretakerEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Caretaker Email Address',
                        hintText: 'caregiver@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: caretakerPasswordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password Credentials',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Quick Demo credentials button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.key, size: 16),
                        label: const Text(
                          'Use Demo: caregiver@example.com / password123',
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            caretakerEmailController.text =
                                'caregiver@example.com';
                            caretakerPasswordController.text = 'password123';
                            errorMessage = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: loginCaretaker,
                        icon: const Icon(Icons.shield_outlined),
                        label: const Text(
                          'Sign In as Caretaker',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

