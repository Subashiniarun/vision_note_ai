part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeMode mode;
  const ThemeState(this.mode);

  ThemeData get lightTheme => _buildLightTheme();
  ThemeData get darkTheme => _buildDarkTheme();

  @override
  List<Object> get props => [mode];

  ThemeData _buildLightTheme() => AppTheme.lightTheme;
  ThemeData _buildDarkTheme() => AppTheme.darkTheme;
}

class ThemeReady extends ThemeState {
  const ThemeReady(super.mode);
}
