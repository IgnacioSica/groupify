import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:groupify/app/app.dart';
import 'package:groupify/auth/auth.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository, this._appCubit) : super(const LoginState());

  final AuthRepository _authenticationRepository;
  final AppBloc _appCubit;

  Future<void> logInWithSpotify() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.logInWithSpotify();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      _appCubit.add(const AppSpotifyConnectionChanged(true));
    } on LogInWithSpotifyFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzStatus.submissionFailure,
        ),
      );
      _appCubit.add(const AppSpotifyConnectionChanged(false));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
      _appCubit.add(const AppSpotifyConnectionChanged(false));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on LogInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzStatus.submissionFailure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
