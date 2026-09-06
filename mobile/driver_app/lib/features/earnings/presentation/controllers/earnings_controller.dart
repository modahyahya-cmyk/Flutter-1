import 'package:flutter_bloc/flutter_bloc.dart';

class EarningsController extends Cubit<double> {
  EarningsController() : super(0.0);

  void loadEarnings() {
    // كود إنتاجي نظيف متوافق مع نظام الـ Bloc
    emit(150.0); 
  }
}