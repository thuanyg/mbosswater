import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbosswater/core/services/firebase_cloud_message.dart';
import 'package:mbosswater/core/services/notification_service.dart';
import 'package:mbosswater/core/styles/app_theme.dart';
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/features/agency/presentation/bloc/fetch_agency_staff_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/additional_info_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/product_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_mboss_staff_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/change_password_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/go_router.dart';
import 'features/login/presentation/bloc/login_bloc.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  // Initialize NotificationService
  await NotificationService.init();

  // Initialize FirebaseCloudMessage
  final FirebaseCloudMessage fcm = FirebaseCloudMessage();

  await fcm.initialize();

  // Initialize Service Locator - GetIt Dependency Injection
  initServiceLocator();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Future<void> addMultipleUsers(List<UserModel> users) async {
  //   try {
  //     WriteBatch batch = FirebaseFirestore.instance.batch();
  //
  //     for (var user in users) {
  //       DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user.id);
  //       batch.set(docRef, user.toJson());
  //     }
  //
  //     await batch.commit();
  //   } catch (e) {
  //     print('Error adding multiple users: $e');
  //     rethrow;
  //   }
  // }
  //
  // final newUser = UserModel(
  //   id: '7fuLmrwukHddTWZvA4ixayphzEs2',
  //   fullName: 'PTN',
  //   email: 'phamthuynhi2906@gmail.com',
  //   address: 'Some address',
  //   dob: '1990-01-01',
  //   gender: 'male',
  //   password: '123456',
  //   role: 'mboss-technical',
  //   createdAt: Timestamp.now(),
  // );
  //
  // try {
  //   await addMultipleUsers([newUser]);
  //   print('User added successfully!');
  // } catch (e) {
  //   print('Error adding user: $e');
  // }

  // String data =
  //     '{"code":"mbosswater","product":{"id":"MLN1009","name":"Máy Lọc Nước Tạo Kiềm MBossWater","model":"Model09","seriDow":"SRD09","guaranteeDuration":"24 tháng"}}';
  //
  // String dataEncri = EncryptionHelper.encryptData("123456", dotenv.env["SECRET_KEY_QR_CODE"]!);
  //
  // print(dataEncri);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LoginBloc>()),
        BlocProvider(create: (_) => sl<UserInfoBloc>()),
        BlocProvider(create: (_) => sl<VerifyEmailBloc>()),
        BlocProvider(create: (_) => sl<VerifyOtpBloc>()),
        BlocProvider(create: (_) => sl<ChangePasswordBloc>()),
        BlocProvider(create: (_) => sl<ProvincesBloc>()),
        BlocProvider(create: (_) => sl<DistrictsBloc>()),
        BlocProvider(create: (_) => sl<CommunesBloc>()),
        BlocProvider(create: (_) => sl<ActiveGuaranteeBloc>()),
        BlocProvider(create: (_) => sl<CustomerSearchBloc>()),
        BlocProvider(create: (_) => sl<CustomerGuaranteeBloc>()),
        BlocProvider(create: (_) => sl<FetchCustomersBloc>()),
        BlocProvider(create: (_) => sl<FetchCustomerBloc>()),
        BlocProvider(create: (_) => sl<AgencyBloc>()),
        BlocProvider(create: (_) => sl<GuaranteeHistoryBloc>()),
        BlocProvider(create: (_) => sl<FetchMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<CreateMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<UpdateMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<DeleteMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<FetchAgencyStaffBloc>()),
        // For step handling
        BlocProvider(create: (_) => StepBloc(0)),
        BlocProvider(create: (_) => ProductBloc(null)),
        BlocProvider(create: (_) => CustomerBloc(null)),
        BlocProvider(create: (_) => AdditionalInfoBloc(null)),
      ],
      child: DevicePreview(
        // enabled: !kReleaseMode,
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // NotificationService.showInstantNotification(
    //   'Welcome to MBossWater',
    //   'This is an instant notification',
    // );
    return MaterialApp.router(
      title: 'MBossWater',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
