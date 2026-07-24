import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/logging/app_logger.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/login_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/register_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  static const _logTag = 'AuthBloc';

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _emitState(emit, const AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user == null) {
        _emitState(emit, const Unauthenticated());
        return;
      }
      _emitState(emit, Authenticated(user));
    } on Failure catch (failure) {
      _emitState(emit, AuthError(failure.message));
    } catch (_) {
      _emitState(
        emit,
        const AuthError('Something went wrong. Please try again.'),
      );
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    _emitState(emit, const AuthLoading());
    try {
      final user = await _loginUseCase(
        email: event.email,
        password: event.password,
      );
      _emitState(emit, Authenticated(user));
    } on Failure catch (failure) {
      _emitState(emit, AuthError(failure.message));
    } catch (_) {
      _emitState(
        emit,
        const AuthError('Something went wrong. Please try again.'),
      );
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    _emitState(emit, const AuthLoading());
    try {
      final user = await _registerUseCase(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
      );
      _emitState(emit, Authenticated(user));
    } on Failure catch (failure) {
      _emitState(emit, AuthError(failure.message));
    } catch (_) {
      _emitState(
        emit,
        const AuthError('Something went wrong. Please try again.'),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _emitState(emit, const AuthLoading());
    try {
      await _logoutUseCase();
      _emitState(emit, const Unauthenticated());
    } on Failure catch (failure) {
      _emitState(emit, AuthError(failure.message));
    } catch (_) {
      _emitState(
        emit,
        const AuthError('Something went wrong. Please try again.'),
      );
    }
  }

  void _emitState(Emitter<AuthState> emit, AuthState state) {
    AppLogger.debug('state → ${state.runtimeType}', tag: _logTag);
    emit(state);
  }
}
