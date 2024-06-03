import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum RegistrationStatus { initial, success, error }

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  bool isLoading = false;
  RegistrationStatus registrationStatus = RegistrationStatus.initial;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool validateEmail(String email) {
    String emailRegex = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$';
    return RegExp(emailRegex).hasMatch(email);
  }

  bool isStrongPassword(String password) {
    // Pemeriksaan minimal 8 karakter
    if (password.length < 8) {
      return false;
    }

    // Pemeriksaan mengandung huruf besar, huruf kecil, dan angka
    bool hasUpperCase = false;
    bool hasLowerCase = false;
    bool hasDigit = false;

    for (int i = 0; i < password.length; i++) {
      if (RegExp(r'[A-Z]').hasMatch(password[i])) {
        hasUpperCase = true;
      } else if (RegExp(r'[a-z]').hasMatch(password[i])) {
        hasLowerCase = true;
      } else if (RegExp(r'[0-9]').hasMatch(password[i])) {
        hasDigit = true;
      }

      // Jika sudah ditemukan ketiganya, keluar dari loop
      if (hasUpperCase && hasLowerCase && hasDigit) {
        break;
      }
    }

    // Kata sandi dianggap kuat jika mengandung huruf besar, huruf kecil, dan angka
    return hasUpperCase && hasLowerCase && hasDigit;
  }

  void showErrorMessage(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: color ?? Colors.white),
            SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color ?? Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getAvatarUrl() {
    return 'https://firebasestorage.googleapis.com/v0/b/masakan-7a664.appspot.com/o/profile_images%2FS70wBQ9ThtNO5MGLEyqJv63WQrZ2-1702707336895.jpg?alt=media&token=5c155e36-a98c-4169-a632-eb345b03d200';
  }

  Future<void> registerUser(
      String username, String email, String password) async {
    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'uid': uid,
        'profileImageUrl': _getAvatarUrl(),
      });

      setState(() {
        registrationStatus = RegistrationStatus.success;
      });
    } on FirebaseAuthException catch (error) {
      print('Error: $error');
      String errorMessage = 'Registrasi gagal. Silakan cek kembali data Anda.';

      if (error.code == 'email-already-in-use') {
        errorMessage = 'Email sudah terdaftar.';
      } else {
        errorMessage = 'Terjadi kesalahan saat mendaftar. Silakan coba lagi.';
      }

      setState(() {
        registrationStatus = RegistrationStatus.error;
      });

      showErrorMessage(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _checkInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        toolbarHeight: 75.0,
        elevation: 6,
        automaticallyImplyLeading: false,
        title: Text(
          'Daftar',
          style: TextStyle(
            fontSize: 28.0,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFAF1E4),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(45.0, 65.0, 45.0,
                0.0), // Sesuaikan nilai padding sesuai kebutuhan
            child: Column(
              children: [
                Container(
                  width: 153,
                  height: 152,
                  margin: EdgeInsets.only(top: 10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/log.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(height: 19.0),
                buildInputContainer(
                  hintText: 'Nama pengguna',
                  controller: usernameController,
                  icon: Icons.person,
                  isPassword: false,
                ),
                buildInputContainer(
                  hintText: 'Email',
                  controller: emailController,
                  icon: Icons.email,
                  isPassword: false,
                ),
                buildInputContainer(
                  hintText: 'Kata Sandi',
                  controller: passwordController,
                  icon: null,
                  isPassword: true,
                  isVisible: passwordVisible,
                  toggleVisibility: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
                buildInputContainer(
                  hintText: 'Konfirm sandi',
                  controller: confirmPasswordController,
                  icon: null,
                  isPassword: true,
                  isVisible: confirmPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      confirmPasswordVisible = !confirmPasswordVisible;
                    });
                  },
                ),
                SizedBox(height: 2.0),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          bool isConnected = await _checkInternetConnection();

                          if (!isConnected) {
                            showErrorMessage(
                                'Koneksi internet anda tidak stabil.');
                            return;
                          }

                          // Lanjut dengan pendaftaran jika ada koneksi internet
                          String username = usernameController.text;
                          String email = emailController.text;
                          String password = passwordController.text;
                          String confirmPassword =
                              confirmPasswordController.text;

                          if (username.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty) {
                            showErrorMessage('Silakan isi semua kolom');
                          } else if (!validateEmail(email)) {
                            showErrorMessage('Format email tidak valid');
                          } else if (!isStrongPassword(password)) {
                            showErrorMessage(
                                'Kata sandi harus minimal 8 karakter \ndan mengandung huruf besar, \nhuruf kecil, dan angka');
                          } else if (password != confirmPassword) {
                            showErrorMessage('Password tidak cocok');
                          } else {
                            registerUser(username, email, password).then((_) {
                              if (registrationStatus ==
                                  RegistrationStatus.success) {
                                showErrorMessage(
                                  'Registrasi berhasil. Selamat datang!',
                                  color: Colors.green,
                                );
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                );
                              } else {
                                showErrorMessage(
                                  'Registrasi gagal.',
                                );
                              }
                            });
                          }
                        },
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9EB384),
                    fixedSize: Size(130, 41),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 13.0),
                TextButton(
                  onPressed: () {
                    // Navigasi ke halaman login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? Silakan ',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'masuk',
                          style: TextStyle(
                            color: Colors
                                .blue, // Mengubah warna teks "masuk" menjadi biru
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputContainer({
    required String hintText,
    required TextEditingController controller,
    required IconData? icon,
    required bool isPassword,
    bool isVisible = true,
    VoidCallback? toggleVisibility,
  }) {
    return Container(
      width: 300.0,
      height: 53.0,
      margin: EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.0),
        color: Color(0xFFCEDEBD),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.9),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10.0, bottom: 6.0),
              ),
              obscureText: isPassword && isVisible,
            ),
          ),
          if (icon != null)
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                icon,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
          if (isPassword)
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black.withOpacity(0.9),
              ),
              onPressed: toggleVisibility,
            ),
        ],
      ),
    );
  }
}
