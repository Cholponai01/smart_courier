import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_courier/core/constants/app_constants.dart';
import 'package:smart_courier/core/network/dio_client.dart';
import 'package:smart_courier/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_courier/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/login_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/register_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_email_verification_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_password_reset_use_case.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:smart_courier/features/auth/presentation/cubit/resend_email_verification_cubit.dart';
import 'package:smart_courier/core/map/dgis_map_service.dart';
import 'package:smart_courier/core/map/map_picker_controller.dart';
import 'package:smart_courier/features/orders/data/map/dgis_map_picker_controller.dart';
import 'package:smart_courier/features/orders/data/repositories/order_repository_impl.dart';
import 'package:smart_courier/features/orders/domain/repositories/order_repository.dart';
import 'package:smart_courier/features/orders/domain/use_cases/create_order_use_case.dart';
import 'package:smart_courier/features/orders/domain/use_cases/watch_customer_orders_use_case.dart';
import 'package:smart_courier/features/orders/presentation/bloc/order_form_bloc.dart';
import 'package:smart_courier/features/orders/presentation/cubit/customer_orders_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<Dio>(createDioClient);
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  sl.registerLazySingleton<DgisMapService>(() => DgisMapService());
  sl.registerLazySingleton<MapPickerController>(
    () => DgisMapPickerController(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(firebaseAuth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => SendEmailVerificationUseCase(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => WatchCustomerOrdersUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );
  sl.registerFactory(() => ForgotPasswordCubit(sl()));
  sl.registerFactory(() => ResendEmailVerificationCubit(sl()));
  sl.registerFactory(() => OrderFormBloc(sl()));
  sl.registerFactory(() => CustomerOrdersCubit(sl()));
}
