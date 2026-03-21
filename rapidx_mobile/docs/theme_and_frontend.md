# Theme and Frontend Guidelines

This document outlines the visual style and frontend architecture of the RapidX mobile application.

## 1. Color Palette

The application uses a specific color scheme defined primarily in hex codes throughout the codebase.

| Name               | Hex Code      | Usage                               |
| :----------------- | :------------ | :---------------------------------- |
| **Primary Blue**   | `#234C6A`     | Primary Brand Color, Buttons, Icons |
| **Active Teal**    | `#56A3A6`     | Accents, Highlights                 |
| **Warning Orange** | `#DE9325`     | Notifications, alerts, status       |
| **Background**     | `#FFFFFF`     | Primary Background (White)          |
| **Light Grey**     | `#F2F2F2`     | Secondary Backgrounds, Sections     |
| **Grey Text**      | `Colors.grey` | Placeholder text, secondary details |

---

## 2. Typography

The application uses **Google Fonts** via the `google_fonts` package.
The primary typeface is **Baloo 2**.

To use the font:
```dart
import 'package:google_fonts/google_fonts.dart';

Text(
  "Hello World",
  style: GoogleFonts.baloo2(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: const Color(0xff234C6A),
  ),
);
```

---

## 3. Responsive Design (`flutter_screenutil`)

The application is built using `flutter_screenutil` to ensure UI consistency across different screen sizes.

### Usage
-   **Initialize**: In `main.dart`, wrap the app with `ScreenUtilInit`.
    ```dart
    ScreenUtilInit(
      designSize: const Size(360, 690), // Based on design comp
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(...);
      },
    );
    ```

-   **Apply Dimensions**:
    -   Use `.w` for width-based scaling.
    -   Use `.h` for height-based scaling.
    -   Use `.sp` for scalable font sizes.
    -   Use `.sw` and `.sh` for percentages of screen width/height (e.g., `0.5.sw` = half screen width).

### Example
```dart
Container(
  width: 200.w,      // 200 logical pixels wide, scaled
  height: 50.h,      // 50 logical pixels high, scaled
  margin: EdgeInsets.symmetric(horizontal: 20.w),
  child: Text(
    "Responsive Text",
    style: TextStyle(fontSize: 18.sp), // 18sp font size
  ),
);
```

---

## 4. UI Components

### Custom Buttons
Buttons often follow a specific style:
-   **Background Color**: `#234C6A` (Primary Blue) or White with Blue Border.
-   **Border Radius**: `10.r` or `12.r`.
-   **Elevation**: Minimal or flat.

Example Button Implementation:
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xff234C6A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
    ),
  ),
  onPressed: () {},
  child: Text("Action"),
);
```

### Layout Structure
-   **SafeArea**: Most screens wrap content in `SafeArea` to avoid system UI overlap.
-   **Padding**: Standard horizontal padding is often `20.w` or `30.w`.
-   **Icons**: Material Icons are used, typically sized with `.sp` or `.r`.
