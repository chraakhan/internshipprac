import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  // 👆 starts at 0

  void increment() => emit(state + 1);
  // 👆 adds 1

  void decrement() => emit(state - 1);
  // 👆 removes 1
}
