import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class AgencyRepository {
  // For Boss Agency
  Future<List<UserModel>> fetchUsersOfAgency(String agencyID);

  Future<List<UserModel>> fetchUsersOfAgencyByRole(
      String agencyID, String role);

  Future<void> updateStaff(UserModel userUpdate);

  Future<void> deleteStaff(String userID);
}
