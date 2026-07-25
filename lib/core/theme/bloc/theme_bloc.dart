import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeReady(ThemeMode.system)) {
    on<SetTheme>(_onSetTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  void _onSetTheme(SetTheme event, Emitter<ThemeState> emit) {
    emit(ThemeReady(event.mode));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    final current = state.mode;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeReady(next));
  }
}
