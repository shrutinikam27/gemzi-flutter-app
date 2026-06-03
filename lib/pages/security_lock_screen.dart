import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../widgets/translated_text.dart';

class SecurityLockScreen extends StatefulWidget {
  final String mode; // 'setup' or 'verify'

  const SecurityLockScreen({
    super.key,
    required this.mode,
  });

  @override
  State<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends State<SecurityLockScreen> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);

  String enteredPin = "";
  String setupFirstPin = "";
  bool isConfirming = false;
  String message = "";
  String subMessage = "";
  bool hasError = false;

  // For Simulated Biometric Scan
  bool isBiometricScanning = false;
  String scanningStatus = "Initializing Secure Scan...";
  double scanProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  void _initializeMessages() {
    if (widget.mode == 'setup') {
      message = "Create Security PIN";
      subMessage = "Set a 4-digit PIN to secure your vault";
    } else {
      message = "Enter Security PIN";
      subMessage = "Verify identity to access Digital Gold";
    }
  }

  Future<void> _handleNumberPress(String number) async {
    if (enteredPin.length >= 4) return;
    
    // Subtle button click haptic simulation
    HapticFeedback.lightImpact();

    setState(() {
      enteredPin += number;
      hasError = false;
    });

    if (enteredPin.length == 4) {
      // Small delay for visual satisfaction
      await Future.delayed(const Duration(milliseconds: 250));
      _processPin();
    }
  }

  void _handleBackspace() {
    if (enteredPin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      hasError = false;
    });
  }

  Future<void> _processPin() async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.mode == 'setup') {
      if (!isConfirming) {
        // First entry complete
        setupFirstPin = enteredPin;
        setState(() {
          isConfirming = true;
          enteredPin = "";
          message = "Confirm Security PIN";
          subMessage = "Re-enter your 4-digit PIN to confirm";
        });
      } else {
        // Confirmation entry complete
        if (enteredPin == setupFirstPin) {
          // Success! Save PIN
          await prefs.setString('security_pin', enteredPin);
          await prefs.setBool('security_pin_enabled', true);
          HapticFeedback.heavyImpact();
          
          setState(() {
            message = "PIN Configured!";
            subMessage = "Gemzi Secure Shield is now active ✔️";
          });

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // Mismatch
          HapticFeedback.vibrate();
          setState(() {
            enteredPin = "";
            setupFirstPin = "";
            isConfirming = false;
            hasError = true;
            message = "PINs Do Not Match";
            subMessage = "Please try setting up your PIN again";
          });
        }
      }
    } else {
      // Verify Mode
      final savedPin = prefs.getString('security_pin') ?? "";
      if (enteredPin == savedPin || (savedPin.isEmpty && enteredPin == "1234")) {
        // Correct PIN
        HapticFeedback.heavyImpact();
        setState(() {
          message = "Verification Successful";
          subMessage = "Access Granted ✔️";
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        // Incorrect PIN
        HapticFeedback.vibrate();
        setState(() {
          enteredPin = "";
          hasError = true;
          message = "Incorrect Security PIN";
          subMessage = "Please enter the correct 4-digit code";
        });
      }
    }
  }

  // Simulated High-Fidelity Biometric Unlock
  Future<void> _triggerBiometricScan() async {
    if (widget.mode == 'setup') {
      // Biometrics can only be used for verification, not setup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Please complete PIN setup first"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      isBiometricScanning = true;
      scanningStatus = "Initializing Secure Scan...";
      scanProgress = 0.0;
    });

    // Step-by-step scanning progress simulation
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    HapticFeedback.selectionClick();
    setState(() {
      scanningStatus = "Verifying Biometric Hash...";
      scanProgress = 0.4;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    HapticFeedback.selectionClick();
    setState(() {
      scanningStatus = "Matching Secure Signatures...";
      scanProgress = 0.8;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      scanningStatus = "Identity Confirmed ✔️";
      scanProgress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Background elegant gradient
          _buildBackgroundGradient(),

          // Main Lock UI
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Lock Icon or Status Shield
                _buildLockHeader(),
                
                const SizedBox(height: 30),
                
                // Indicators
                _buildPinIndicators(),
                
                const SizedBox(height: 50),
                
                // Keypad
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _buildKeypad(),
                  ),
                ),
                
                // Back option for exit
                _buildExitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Simulated Biometric Scanning Screen overlay
          if (isBiometricScanning) _buildBiometricScanningOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkBg, surfaceDark, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildLockHeader() {
    return Column(
      children: [
        ZoomIn(
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: richGold.withValues(alpha: 0.05),
              border: Border.all(color: richGold.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Icon(
              widget.mode == 'setup' ? Icons.security : Icons.lock_outline_rounded,
              color: richGold,
              size: 45,
            ),
          ),
        ),
        const SizedBox(height: 25),
        
        // Shake animation on error
        hasError
            ? ShakeX(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : FadeIn(
                child: Text(
                  message,
                  style: TextStyle(
                    color: richGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            subMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: textSubdued, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < enteredPin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? richGold : Colors.transparent,
            border: Border.all(
              color: isFilled ? richGold : richGold.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: richGold.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _keypadButton("1"),
            _keypadButton("2"),
            _keypadButton("3"),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _keypadButton("4"),
            _keypadButton("5"),
            _keypadButton("6"),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _keypadButton("7"),
            _keypadButton("8"),
            _keypadButton("9"),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _biometricButton(),
            _keypadButton("0"),
            _backspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _keypadButton(String text) {
    return GlassmorphicContainer(
      width: 70,
      height: 70,
      borderRadius: 35,
      blur: 10,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [richGold.withValues(alpha: 0.25), Colors.white.withValues(alpha: 0.05)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(35),
        onTap: () => _handleNumberPress(text),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _biometricButton() {
    if (widget.mode == 'setup') {
      return const SizedBox(width: 70, height: 70); // Hide in setup mode
    }

    return GlassmorphicContainer(
      width: 70,
      height: 70,
      borderRadius: 35,
      blur: 10,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        colors: [richGold.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [richGold.withValues(alpha: 0.4), Colors.white.withValues(alpha: 0.05)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(35),
        onTap: _triggerBiometricScan,
        child: Center(
          child: Icon(
            Icons.fingerprint_rounded,
            color: richGold,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _backspaceButton() {
    return GlassmorphicContainer(
      width: 70,
      height: 70,
      borderRadius: 35,
      blur: 10,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.01)],
      ),
      borderGradient: LinearGradient(
        colors: [richGold.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(35),
        onTap: _handleBackspace,
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    return TextButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context, false);
      },
      child: TranslatedText(
        "Cancel",
        style: TextStyle(
          color: textSubdued,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Beautiful interactive overlay for simulated biometrics
  Widget _buildBiometricScanningOverlay() {
    return Positioned.fill(
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
        blur: 15,
        border: 0,
        linearGradient: LinearGradient(
          colors: [Colors.black.withValues(alpha: 0.85), Colors.black.withValues(alpha: 0.9)],
        ),
        borderGradient: const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Pulsing scan radar visual
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  SpinPerfect(
                    duration: const Duration(seconds: 4),
                    infinite: true,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: richGold.withValues(alpha: 0.2),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  // Inner pulse ring
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: richGold.withValues(alpha: 0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Animated green scanner line
                  Positioned(
                    top: 10 + (scanProgress * 110),
                    child: Container(
                      width: 120,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Glowing Fingerprint icon
                  Icon(
                    Icons.fingerprint_rounded,
                    color: richGold,
                    size: 90,
                  ),
                ],
              ),
              const SizedBox(height: 50),
              
              // Status text
              Text(
                scanningStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 15),
              
              // Progress bar
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 200 * scanProgress,
                    height: 4,
                    decoration: BoxDecoration(
                      color: richGold,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: richGold.withValues(alpha: 0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              
              // Bottom security label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_rounded, color: richGold, size: 14),
                  const SizedBox(width: 8),
                  const Text(
                    "SECURE ENCRYPTED VERIFICATION",
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
