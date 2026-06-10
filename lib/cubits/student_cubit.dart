import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── STATE ──────────────────────────────────────────
// this describes everything the student form needs
class StudentState {
  final int studentCount;
  final bool hasSubmitted;
  final String submittedName;
  final String submittedAge;
  final bool isLoading;

  const StudentState({
    this.studentCount = 0,
    this.hasSubmitted = false,
    this.submittedName = '',
    this.submittedAge = '',
    this.isLoading = false,
  });
  // 👆 all values start empty/zero/false by default

  StudentState copyWith({
    int? studentCount,
    bool? hasSubmitted,
    String? submittedName,
    String? submittedAge,
    bool? isLoading,
  }) {
    return StudentState(
      studentCount: studentCount ?? this.studentCount,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      submittedName: submittedName ?? this.submittedName,
      submittedAge: submittedAge ?? this.submittedAge,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // 👆 copyWith lets us change only ONE value
  //    and keep everything else the same
  //    example: copyWith(studentCount: 5)
  //    only changes studentCount, rest stays the same
}

// ── CUBIT ──────────────────────────────────────────
class StudentCubit extends Cubit<StudentState> {
  StudentCubit() : super(const StudentState());
  // 👆 start with empty state

  Future<void> submitStudent(String name, String age) async {
    emit(state.copyWith(isLoading: true));
    // 👆 show loading spinner

    await FirebaseFirestore.instance.collection('students').add({
      'name': name,
      'age': age,
      'time': DateTime.now().toString(),
    });
    // 👆 save to Firebase

    emit(
      state.copyWith(
        isLoading: false,
        hasSubmitted: true,
        submittedName: name,
        submittedAge: age,
        studentCount: state.studentCount + 1,
      ),
    );
    // 👆 update everything at once after Firebase saves
  }
}
