import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

enum ActionType { update, create }

class GuaranteeDatasourceImpl extends GuaranteeDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<void> createGuarantee(
    Guarantee guarantee,
    Customer customer,
    ActionType actionType,
  ) async {
    final WriteBatch batch = _firebaseFirestore.batch();

    try {
      final customerRef =
          _firebaseFirestore.collection('customers').doc(customer.id);

      if (actionType == ActionType.create) {
        batch.set(customerRef, customer.toJson());
        print(actionType);
      } else if (actionType == ActionType.update) {
        // Update existing customer
        final querySnapshot = await _firebaseFirestore
            .collection('customers')
            .where('phoneNumber', isEqualTo: customer.phoneNumber)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Use the existing customer reference and update
          final existingCustomerRef = querySnapshot.docs.first.reference;
          batch.update(existingCustomerRef, customer.toJson());
        } else {
          throw Exception(
              'Customer with phone ${customer.phoneNumber} not found for update.');
        }
      }

      // Add the guarantee regardless of customer action
      final guaranteeRef =
          _firebaseFirestore.collection('guarantees').doc(guarantee.id);
      batch.set(guaranteeRef, guarantee.toJson());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create or update customer and guarantee: $e');
    }
  }

  @override
  Future<Customer?> getCustomerExisted(String phoneNumber) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('customers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return Customer.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Error fetching customer: $e');
      return null;
    }
  }
}