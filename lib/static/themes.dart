import 'package:flutter/material.dart';

const primaryColor = Color.fromARGB(255, 7, 108, 239); //主色
const primaryColor1 = Color.fromARGB(255, 32, 44, 89);
const primaryColor2 = Color.fromARGB(255, 6, 22, 70);
const secondaryColor = Color.fromARGB(255, 243, 244, 248);
const buttonColor1 = Color.fromARGB(255, 255, 190, 82);
const buttonColor2 = Color.fromARGB(255, 32, 106, 235);
const buttonColor3 = Color.fromARGB(255, 53, 76, 167);
const buttonColor4 = Color.fromARGB(255, 63, 138, 152);
const buttonColor5 = Color.fromARGB(255, 151, 76, 137);
const buttonColor6 = Color.fromARGB(255, 67, 76, 144);
const buttonBorder1 = Color.fromARGB(255, 164, 164, 164);
const textColor1 = Colors.black;
const textColor2 = primaryColor;
const textColor3 = Color.fromARGB(255, 173, 186, 201);
const textColor4 = Color.fromARGB(255, 197, 145, 78);
const textColor5 = Color.fromARGB(255, 122, 145, 168);
const textColor6 = Color.fromARGB(255, 91, 101, 137);

class Themes {
  static ThemeData lightTheme() {
    return genericTheme(
      background: Colors.white,
      onBackground: Colors.grey.shade700,
      primary: Colors.grey.shade300,
      onPrimary: Colors.black,
      secondary: const Color.fromARGB(255, 16, 63, 92),
      tertiary: Colors.blue.shade900,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
      isDark: false,
    );
  }

  static ThemeData darkTheme() {
    return genericTheme(
      background: Colors.grey.shade900,
      onBackground: Colors.black,
      primary: Colors.grey.shade800,
      onPrimary: Colors.white,
      secondary: const Color.fromARGB(255, 16, 63, 92),
      tertiary: Colors.blue.shade900,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
      isDark: true,
    );
  }

  static ThemeData genericTheme({
    required Color background,
    required Color onBackground,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color tertiary,
    required Color inversePrimary,
    required bool isDark,
  }) {
    return ThemeData(
        dialogTheme: DialogTheme(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          titleTextStyle: TextStyle(
            color: onPrimary,
            fontSize: 20.0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all(secondary),
              textStyle: MaterialStateProperty.all(
                  const TextStyle(color: Colors.white))),
        ),
        switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all(Colors.white),
            trackColor: MaterialStateProperty.all(secondary),
            trackOutlineColor: MaterialStateProperty.all(secondary)),
        sliderTheme: SliderThemeData(
          activeTrackColor: tertiary,
          inactiveTrackColor: primary,
          thumbColor: secondary,
          overlayColor: tertiary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          fillColor: primary,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: secondary,
          selectionColor: tertiary,
          cursorColor: secondary,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: secondary,
        ),
        colorScheme: isDark
            ? ColorScheme.dark(
                background: background,
                onBackground: onBackground,
                primary: primary,
                onPrimary: onPrimary,
                secondary: secondary,
                tertiary: tertiary,
                inversePrimary: inversePrimary,
              )
            : ColorScheme.light(
                background: background,
                onBackground: onBackground,
                primary: primary,
                onPrimary: onPrimary,
                secondary: secondary,
                tertiary: tertiary,
                inversePrimary: inversePrimary,
              ),
        dividerTheme: const DividerThemeData(
          color: secondaryColor,
        ),
        listTileTheme:  const ListTileThemeData(
          iconColor: buttonBorder1,
        ),
        scaffoldBackgroundColor: secondaryColor);
  }
}
