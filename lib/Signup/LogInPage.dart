import 'package:baaby_log/Homepage/LookHomePage.dart';
import 'package:baaby_log/Homepage/ParentHomePage.dart';
import 'package:baaby_log/Homepage/PregnantHomePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navigationBar.dart';
import 'FindMyInfo.dart';
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    _idController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonActive =
          _idController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  Future<String?> _getEmailById(String id) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('ID', isEqualTo: id)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['email'] as String?;
      }
    } catch (e) {
      print("이메일 조회 실패: $e");
    }
    return null;
  }

  Future<void> _login() async {
    try {
      String? email = await _getEmailById(_idController.text.trim());
      if (email != null) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        // Navigate to the navigationBar and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const navigationBar()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아이디를 찾을 수 없습니다.'),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("로그인 실패: ${e.message}");
      _showCustomSnackbar("로그인 실패: ${e.message}");
    } catch (e) {
      debugPrint("로그인 실패: $e");
      _showCustomSnackbar("로그인 실패: ${e.toString()}");
    }
  }

  void _showCustomSnackbar(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final snackbar = SnackBar(
      content: Container(
        height: 25,
        width: double.infinity,
        color: Color(0XFFFFDCB2),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0XFFFFDCB2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      duration: Duration(seconds: 1),
    );
    scaffoldMessenger.showSnackBar(snackbar);
  }

  @override
  void dispose() {
    _idController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.orange[50]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100.0),
                Image.asset('assets/logo_word.png', width: 183, height: 75),
                const SizedBox(height: 99.0),
                const Padding(
                  padding: EdgeInsets.only(left: 43.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '아이디',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(43.0, 0, 43, 0),
                  child: Container(
                    width: 350,
                    height: 31,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Center(
                      child: TextField(
                        controller: _idController,
                        cursorColor: const Color(0XFFFFDCB2),
                        decoration: const InputDecoration(
                          hintText: '아이디',
                          hintStyle: TextStyle(
                            color: Color(0xFFA7A7A7),
                            fontSize: 13,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA8A8A8)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA7A7A7)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26.0),
                const Padding(
                  padding: EdgeInsets.only(left: 43.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '비밀번호',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(43.0, 0, 43, 0),
                  child: Container(
                    width: 350,
                    height: 31,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Center(
                      child: TextField(
                        controller: _passwordController,
                        cursorColor: const Color(0XFFFFDCB2),
                        decoration: const InputDecoration(
                          hintText: '영문, 숫자, 특수문자 포함 8자리 이상',
                          hintStyle: TextStyle(
                            color: Color(0xFFA7A7A7),
                            fontSize: 13,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA8A8A8)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA7A7A7)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FindMyInfoPage(),
                          ),
                        );
                      },
                      child: const Text(
                        '아이디 / 비밀번호 찾기',
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 13,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      )),
                ),
                const SizedBox(height: 232.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                  child: SizedBox(
                    width: 375,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isButtonActive ? _login : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonActive
                            ? const Color(0XFFFF9C27)
                            : const Color(0XFFFFBC6B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 15.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        elevation: _isButtonActive ? 8.0 : 0.0,
                      ),
                      child: Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w700,
                          color: _isButtonActive
                              ? Colors.white
                              : const Color(0xFFFFDFBB),
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 13,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        height: 0,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
