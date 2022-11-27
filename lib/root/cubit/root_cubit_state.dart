part of 'root_cubit.dart';

class RootCubitState extends FormzBaseCubitState {
  RootCubitState.pure() : super.pure(basePropsMap);

  RootCubitState.dirty(super.status, super.propsMap) : super.dirty();

  static Map<String, Object> basePropsMap = {'room_id': 'yjlxz4nZphyWMH9BzDSQ'};

  @override
  RootCubitState propertyChanged(String key, dynamic value) {
    final newPropsMap = super.propertyChangedAux(key, value);

    return RootCubitState.dirty(Formz.validate(toValidationList(newPropsMap.values)), newPropsMap);
  }

  @override
  RootCubitState copyWithStatus(FormzStatus status) {
    return RootCubitState.dirty(status, propsMap);
  }

  RootCubitState copyWith({required FormzStatus status, required String errorMessage}) {
    return RootCubitState.dirty(status, propsMap);
  }
}
