import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeNicknamePage extends StatefulWidget {
  const ChangeNicknamePage({super.key});

  @override
  _ChangeNicknamePageState createState() => _ChangeNicknamePageState();
}

class _ChangeNicknamePageState extends State<ChangeNicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentNickname();
  }

  Future<void> _loadCurrentNickname() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _nicknameController.text = userData['nickName'] ?? '';
      });
    }
  }

  Future<void> _updateNickname() async {
    String newNickname = _nicknameController.text.trim();
    if (newNickname.isNotEmpty) {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update user's nickname in the users collection
        await _firestore.collection('users').doc(user.uid).update({
          'nickName': newNickname,
        });

        // Update nickname in all posts where the user is the author
        QuerySnapshot postSnapshot = await _firestore
            .collection('posts')
            .where('authorId', isEqualTo: user.uid)
            .get();

        for (var post in postSnapshot.docs) {
          await post.reference.update({
            'authorNickname': newNickname,
          });
        }

        // Update nickname in all comments written by the user across all posts
        QuerySnapshot allPostsSnapshot =
            await _firestore.collection('posts').get();

        for (var post in allPostsSnapshot.docs) {
          QuerySnapshot commentSnapshot = await post.reference
              .collection('comments')
              .where('authorId', isEqualTo: user.uid)
              .get();

          for (var comment in commentSnapshot.docs) {
            await comment.reference.update({
              'authorNickname': newNickname,
            });
          }
        }

        Navigator.pop(context, true); // Notify the user of the update
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '내 계정',
            style: TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 20,
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _updateNickname,
            child: const Text(
              '완료',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(23.0, 26, 0, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '닉네임 변경',
                style: TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 18,
                  fontFamily: 'Pretendard Variable',
                  fontWeight: FontWeight.w500,
                  height: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                hintText: _nicknameController.text.isEmpty
                    ? '닉네임을 입력하세요'
                    : _nicknameController.text,
                hintStyle: const TextStyle(
                  color: Color(0xFFA7A7A7),
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0XFFA8A8A8),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0XFFA8A8A8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0XFFA8A8A8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
