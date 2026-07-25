part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class SetTheme extends ThemeEvent {
  final ThemeMode mode;
  const SetTheme(this.mode);

  @override
  List<Object> get props => [mode];
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
  @override
  List<Object> get props => [];
}
