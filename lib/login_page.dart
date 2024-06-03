import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lupa_password.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: ThemeData(
        primaryColor: Color(0xFF92A584).withOpacity(0.8),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPasswordVisible = false;
  bool isLoading = false;

  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void handleLogin() async {
  if (validateInputs()) {
    bool isConnected = await _checkInternetConnection();

    if (!isConnected) {
      _showNoInternetNotification();
      return;
    }
      setState(() {
        isLoading = true;
      });

      try {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (userCredential.user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Handle other scenarios if needed
          // ...
        }
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Error: $e');
        String errorMessage =
            'Login gagal. Cek kembali email dan password Anda.';
        if (e.code == 'user-not-found') {
          errorMessage =
              'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Password yang dimasukkan salah.';
        }
        showErrorMessage(errorMessage);
      } catch (e) {
        print('Error: $e');
        showErrorMessage('Login gagal. Cek kembali email dan password Anda.');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool validateInputs() {
    final emailRegex = RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(emailController.text)) {
      showErrorMessage('Format email tidak valid');
      return false;
    }

    if (passwordController.text.isEmpty) {
      showErrorMessage('Password tidak boleh kosong');
      return false;
    }

    return true;
  }

 Future<bool> _checkInternetConnection() async {
  return await InternetConnectionChecker().hasConnection;
}

void _showNoInternetNotification() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Jaringan Anda tidak stabi!'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        toolbarHeight: 75.0,
        elevation: 6,
        title: Text(
          'Masuk',
          style: TextStyle(
            fontSize: 28.0,
            color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFAF1E4),
automaticallyImplyLeading: false, // Tambahkan ini agar tombol back muncul otomatis
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(45.0, 100.0, 45.0, 45.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 154,
                  height: 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/log.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(height: 25.0),
                Container(
                  width: 430.0,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13.0),
                    color: Color(0xFFCEDEBD),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            onChanged: (value) {
                              // Handle changes and validation
                            },
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.9),
                              ),
                              border: InputBorder.none,
                            ),
                            cursorColor: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.email,
                            color: Colors.black.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 17.0),
                Container(
                  width: 430.0,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13.0),
                    color: Color(0xFFCEDEBD),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: passwordController,
                            onChanged: (value) {
                              // Handle changes and validation
                            },
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Kata sandi',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.9),
                              ),
                              border: InputBorder.none,
                            ),
                            cursorColor: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black.withOpacity(0.9),
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen()));
                  },
                  child: Text(
                    'Lupa sandi?',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    child: Text(
                      'Masuk',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Color(0xFF9EB384),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      ),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(fontSize: 15,

                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Daftar sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
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
}
