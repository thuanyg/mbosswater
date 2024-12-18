import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mbosswater/features/recovery/data/datasource/recovery_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class RecoveryDatasourceImpl extends RecoveryDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<void> sendOTP(String email) async {
    EmailOTP.config(
      appName: "MbossWater",
      otpType: OTPType.numeric,
      expiry: 600000,
      emailTheme: EmailTheme.v1,
      appEmail: 'mbosswater@hamsa.com',
      otpLength: 4,
    );

    EmailOTP.sendOTP(email: email);
  }

  @override
  Future<bool> verifyEmail(String email) async {
    try {
      final docs = await _firebaseFirestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      return docs.docs.isNotEmpty;
    } on Exception catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> changePassword(String email, String newPassword) async {
    try {
      // Get user
      final docs = await _firebaseFirestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();
      final userDoc = docs.docs.first;
      if (userDoc.exists) {
        final userJsonData = userDoc.data();
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userJsonData["email"],
          password: userJsonData["password"],
        );

        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Update password
          await currentUser.updatePassword(newPassword);
          // Cập nhật mật khẩu trong Firestore
          await _firebaseFirestore
              .collection("users")
              .doc(currentUser.uid)
              .update({"password": newPassword});

          final userModel = UserModel.fromJson(userJsonData);
          return userModel;
        } else {
          throw Exception("Người dùng với email $email không tồn tại.");
        }
      } else {
        throw Exception("Người dùng với email $email không tồn tại.");
      }
    } catch (e) {
      throw Exception("Có lỗi xảy ra: $e");
    }
  }
}
