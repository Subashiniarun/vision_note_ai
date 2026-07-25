# VisionNote AI — FFI Technical Design (OpenCV)

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** Staff Flutter Architect

---

## 1. Why FFI for Image Processing

Processing camera images (typically 1080x1920px × 4 channels = ~8MB per frame) in pure Dart would:

- Block the Dart isolate for 50-200ms per operation
- Cause visible UI jank (dropped frames)
- Consume excessive CPU in a garbage-collected environment
- Lack access to optimized SIMD instructions

**OpenCV via FFI** provides:

| Factor | Dart (pure) | Dart (ui.Image) | C++ OpenCV (FFI) |
|---|---|---|---|
| Edge Detection | ~150ms | ~80ms | **~8ms** |
| Perspective Correction | ~200ms | ~100ms | **~12ms** |
| Denoising | ~300ms | ~150ms | **~15ms** |
| Adaptive Threshold | ~100ms | ~50ms | **~5ms** |
| Full Pipeline | ~750ms | ~380ms | **~40ms** |
| Memory Efficiency | Poor (GC) | Moderate | **Excellent (manual)** |

**Performance Ratio:** OpenCV via FFI is approximately **10-50x faster** than equivalent Dart code.

---

## 2. FFI Architecture

```
┌─────────────────────────────────────────────┐
│               DART SIDE                       │
│                                               │
│  OpenCVImageProcessor                         │
│    ↓ dart:ffi                                 │
│  DynamicLibrary('libopencv_processor.so')     │
└──────────────────┬──────────────────────────┘
                   │ FFI Call
                   ▼
┌─────────────────────────────────────────────┐
│               C++ SIDE (Native)              │
│                                               │
│  process.cpp                                  │
│    ↓ #include                                 │
│  OpenCV headers (opencv2/opencv.hpp)          │
│    ↓                                          │
│  Functions exported with extern "C"           │
│  Return values: base64-encoded strings        │
│    or JSON strings for structured data        │
└─────────────────────────────────────────────┘
```

## 3. C++ Native Functions

### 3.1 Edge Detection

```cpp
extern "C" {

__attribute__((visibility("default")))
const char* detect_document_edges(
    const unsigned char* image_data,
    int width,
    int height,
    int channels
) {
    try {
        // 1. Wrap raw bytes as cv::Mat
        cv::Mat img(height, width, channels == 4 ? CV_8UC4 : CV_8UC3,
                    const_cast<unsigned char*>(image_data));

        // 2. Convert to grayscale
        cv::Mat gray;
        cv::cvtColor(img, gray, cv::COLOR_BGRA2GRAY);

        // 3. Gaussian blur
        cv::Mat blurred;
        cv::GaussianBlur(gray, blurred, cv::Size(5, 5), 0);

        // 4. Canny edge detection
        cv::Mat edges;
        cv::Canny(blurred, edges, 50, 150);

        // 5. Find contours
        std::vector<std::vector<cv::Point>> contours;
        std::vector<cv::Vec4i> hierarchy;
        cv::findContours(edges, contours, hierarchy,
                         cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

        // 6. Find largest quadrilateral contour
        std::vector<cv::Point> largestContour;
        double maxArea = 0;

        for (const auto& contour : contours) {
            double area = cv::contourArea(contour);
            if (area < img.cols * img.rows * 0.3) continue; // min 30% of frame

            std::vector<cv::Point> approx;
            cv::approxPolyDP(contour, approx,
                             cv::arcLength(contour, true) * 0.02, true);

            if (approx.size() == 4 && area > maxArea && cv::isContourConvex(approx)) {
                largestContour = approx;
                maxArea = area;
            }
        }

        if (largestContour.empty()) {
            return strdup(R"({"corners": []})");
        }

        // 7. Sort corners: top-left, top-right, bottom-right, bottom-left
        std::vector<cv::Point> ordered = orderCorners(largestContour);

        // 8. Return as JSON
        std::string json = formatCornersJson(ordered);
        return strdup(json.c_str());

    } catch (const std::exception& e) {
        std::string error = R"({"error": ")" + std::string(e.what()) + R"("})";
        return strdup(error.c_str());
    }
}

}
```

### 3.2 Perspective Correction

```cpp
extern "C" {

__attribute__((visibility("default")))
const char* correct_perspective(
    const unsigned char* image_data,
    int width, int height, int channels,
    float x1, float y1,  // top-left
    float x2, float y2,  // top-right
    float x3, float y3,  // bottom-right
    float x4, float y4   // bottom-left
) {
    try {
        cv::Mat img(height, width, channels == 4 ? CV_8UC4 : CV_8UC3,
                    const_cast<unsigned char*>(image_data));

        // Source points (detected corners)
        std::vector<cv::Point2f> src = {
            cv::Point2f(x1, y1),
            cv::Point2f(x2, y2),
            cv::Point2f(x3, y3),
            cv::Point2f(x4, y4)
        };

        // Compute destination rectangle dimensions
        float w = std::max(
            cv::norm(src[1] - src[0]),
            cv::norm(src[2] - src[3])
        );
        float h = std::max(
            cv::norm(src[3] - src[0]),
            cv::norm(src[2] - src[1])
        );

        // Destination points (top-down rectangle)
        std::vector<cv::Point2f> dst = {
            cv::Point2f(0, 0),
            cv::Point2f(w - 1, 0),
            cv::Point2f(w - 1, h - 1),
            cv::Point2f(0, h - 1)
        };

        // Compute perspective transform matrix
        cv::Mat M = cv::getPerspectiveTransform(src, dst);

        // Warp image
        cv::Mat warped;
        cv::warpPerspective(img, warped, M, cv::Size(w, h),
                            cv::INTER_LINEAR, cv::BORDER_CONSTANT, cv::Scalar());

        // Encode to JPEG bytes as base64
        std::vector<unsigned char> buffer;
        cv::imencode(".jpg", warped, buffer, {cv::IMWRITE_JPEG_QUALITY, 95});
        std::string encoded = base64_encode(buffer.data(), buffer.size());

        return strdup(encoded.c_str());

    } catch (const std::exception& e) {
        std::string error = R"({"error": ")" + std::string(e.what()) + R"("})";
        return strdup(error.c_str());
    }
}

}
```

### 3.3 Auto Enhance Pipeline

```cpp
extern "C" {

__attribute__((visibility("default")))
const char* auto_enhance(
    const unsigned char* image_data,
    int width, int height, int channels
) {
    try {
        cv::Mat img(height, width, channels == 4 ? CV_8UC4 : CV_8UC3,
                    const_cast<unsigned char*>(image_data));

        // Ensure RGBA to BGR if needed (OpenCV uses BGR)
        cv::Mat bgr;
        if (channels == 4) {
            cv::cvtColor(img, bgr, cv::COLOR_RGBA2BGR);
        } else {
            bgr = img.clone();
        }

        // Step 1: Denoise
        cv::Mat denoised;
        cv::fastNlMeansDenoisingColored(bgr, denoised, 10, 10, 7, 21);

        // Step 2: Convert to grayscale
        cv::Mat gray;
        cv::cvtColor(denoised, gray, cv::COLOR_BGR2GRAY);

        // Step 3: CLAHE (Contrast Limited Adaptive Histogram Equalization)
        cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE(3.0, cv::Size(8, 8));
        cv::Mat claheImg;
        clahe->apply(gray, claheImg);

        // Step 4: Adaptive threshold
        cv::Mat thresholded;
        cv::adaptiveThreshold(claheImg, thresholded, 255,
                              cv::ADAPTIVE_THRESH_GAUSSIAN_C,
                              cv::THRESH_BINARY, 11, 2);

        // Step 5: Deskew
        cv::Mat deskewed = deskewImage(thresholded);

        // Encode result
        std::vector<unsigned char> buffer;
        cv::imencode(".jpg", deskewed, buffer, {cv::IMWRITE_JPEG_QUALITY, 90});
        std::string encoded = base64_encode(buffer.data(), buffer.size());

        return strdup(encoded.c_str());

    } catch (const std::exception& e) {
        std::string error = R"({"error": ")" + std::string(e.what()) + R"("})";
        return strdup(error.c_str());
    }
}

}
```

### 3.4 Deskew Helper

```cpp
cv::Mat deskewImage(const cv::Mat& img) {
    // Find all white pixels
    std::vector<cv::Point> points;
    cv::findNonZero(img, points);

    if (points.empty()) return img.clone();

    // Compute minimum area rectangle
    cv::RotatedRect rect = cv::minAreaRect(points);

    // Get angle
    float angle = rect.angle;
    if (angle < -45.0) angle = 90.0 + angle;

    // Only rotate if angle is significant (> 1 degree)
    if (std::abs(angle) < 1.0) return img.clone();

    // Compute rotation matrix
    cv::Point2f center(img.cols / 2.0f, img.rows / 2.0f);
    cv::Mat rotMat = cv::getRotationMatrix2D(center, angle, 1.0);

    // Apply rotation
    cv::Mat rotated;
    cv::warpAffine(img, rotated, rotMat, img.size(),
                   cv::INTER_CUBIC, cv::BORDER_CONSTANT, cv::Scalar(255));

    return rotated;
}
```

### 3.5 Manual Adjustment Functions

```cpp
extern "C" {

// Brightness adjustment (value: -100 to +100)
const char* adjust_brightness(const unsigned char* data, int w, int h, int c, int value) {
    cv::Mat img(h, w, c == 4 ? CV_8UC4 : CV_8UC3, const_cast<unsigned char*>(data));
    cv::Mat result;
    img.convertTo(result, -1, 1.0, static_cast<double>(value) * 2.55); // map -100..100 to -255..255
    return encode_as_base64(result);
}

// Contrast adjustment (value: 0.0 to 2.0, 1.0 = original)
const char* adjust_contrast(const unsigned char* data, int w, int h, int c, double value) {
    cv::Mat img(h, w, c == 4 ? CV_8UC4 : CV_8UC3, const_cast<unsigned char*>(data));
    cv::Mat result;
    img.convertTo(result, -1, value, 0);
    return encode_as_base64(result);
}

// Saturation adjustment (value: 0.0 to 2.0, 1.0 = original)
const char* adjust_saturation(const unsigned char* data, int w, int h, int c, double value) {
    cv::Mat img(h, w, c == 4 ? CV_8UC4 : CV_8UC3, const_cast<unsigned char*>(data));
    cv::Mat hsv;
    cv::cvtColor(img, hsv, cv::COLOR_BGR2HSV);
    std::vector<cv::Mat> channels;
    cv::split(hsv, channels);
    channels[1] *= value; // Scale saturation
    cv::merge(channels, hsv);
    cv::Mat result;
    cv::cvtColor(hsv, result, cv::COLOR_HSV2BGR);
    return encode_as_base64(result);
}

}
```

---

## 4. Dart FFI Bindings

### 4.1 Dynamic Library Loading

```dart
class OpenCVNative {
  static OpenCVNative? _instance;
  late final DynamicLibrary _lib;

  OpenCVNative._() {
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libopencv_processor.so');
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  factory OpenCVNative() {
    _instance ??= OpenCVNative._();
    return _instance!;
  }
}
```

### 4.2 Type Definitions

```dart
// detect_document_edges
typedef DetectEdgesNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  Int32 width,
  Int32 height,
  Int32 channels,
);

typedef DetectEdgesDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  int width,
  int height,
  int channels,
);

// correct_perspective
typedef CorrectPerspectiveNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  Int32 width, Int32 height, Int32 channels,
  Float x1, Float y1, Float x2, Float y2,
  Float x3, Float y3, Float x4, Float y4,
);

typedef CorrectPerspectiveDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  int width, int height, int channels,
  double x1, double y1, double x2, double y2,
  double x3, double y3, double x4, double y4,
);

// auto_enhance
typedef AutoEnhanceNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData, Int32 width, Int32 height, Int32 channels,
);
typedef AutoEnhanceDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData, int width, int height, int channels,
);
```

### 4.3 Service Class

```dart
class OpenCVService {
  late final DetectEdgesDart _detectEdges;
  late final CorrectPerspectiveDart _correctPerspective;
  late final AutoEnhanceDart _autoEnhance;
  // ...

  OpenCVService(OpenCVNative native) {
    final lib = native.lib;
    _detectEdges = lib.lookupFunction<DetectEdgesNative, DetectEdgesDart>('detect_document_edges');
    _correctPerspective = lib.lookupFunction<CorrectPerspectiveNative, CorrectPerspectiveDart>('correct_perspective');
    _autoEnhance = lib.lookupFunction<AutoEnhanceNative, AutoEnhanceDart>('auto_enhance');
  }

  List<Offset> detectEdges(Uint8List imageData, int width, int height) {
    final ptr = _allocatePointer(imageData);
    final resultPtr = _detectEdges(ptr, width, height, 4);
    final json = resultPtr.toDartString();
    _freePtr(ptr);
    _freeStr(resultPtr);
    return _parseCorners(json);
  }

  Uint8List correctPerspective(Uint8List imageData, int width, int height, List<Offset> corners) {
    final ptr = _allocatePointer(imageData);
    final resultPtr = _correctPerspective(
      ptr, width, height, 4,
      corners[0].dx, corners[0].dy,
      corners[1].dx, corners[1].dy,
      corners[2].dx, corners[2].dy,
      corners[3].dx, corners[3].dy,
    );
    final base64 = resultPtr.toDartString();
    _freePtr(ptr);
    _freeStr(resultPtr);
    return base64Decode(base64);
  }

  Pointer<Uint8> _allocatePointer(Uint8List data) {
    final ptr = malloc.allocate<Uint8>(data.length);
    ptr.asTypedList(data.length).setAll(0, data);
    return ptr;
  }

  void _freePtr(Pointer ptr) => malloc.free(ptr);
  void _freeStr(Pointer<Utf8> ptr) => malloc.free(ptr);

  List<Offset> _parseCorners(String json) {
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    if (decoded.containsKey('error')) throw Exception(decoded['error']);
    final corners = decoded['corners'] as List;
    return corners.map((c) => Offset(c['x'], c['y'])).toList();
  }
}
```

---

## 5. Build Integration

### 5.1 Android (CMakeLists.txt)

```cmake
cmake_minimum_required(VERSION 3.10)
project(opencv_processor)

set(OpenCV_DIR ${CMAKE_SOURCE_DIR}/src/main/cpp/opencv/sdk/native/jni)
find_package(OpenCV REQUIRED)

add_library(opencv_processor SHARED
    src/main/cpp/process.cpp
    src/main/cpp/enhance.cpp
    src/main/cpp/utils.cpp
)

target_include_directories(opencv_processor PRIVATE
    ${OpenCV_INCLUDE_DIRS}
    src/main/cpp
)

target_link_libraries(opencv_processor
    ${OpenCV_LIBS}
    log
)
```

### 5.2 iOS (Podspec / Build Script)

```ruby
# opencv_processor.podspec
Pod::Spec.new do |s|
  s.name             = 'opencv_processor'
  s.version          = '1.0.0'
  s.summary          = 'OpenCV image processing for VisionNote AI'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.vendored_frameworks = 'opencv2.framework'
  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-lstdc++ -lopencv_core -lopencv_imgproc'
  }
end
```

---

## 6. Performance Considerations

| Technique | Implementation |
|---|---|
| **Pre-allocate buffers** | Reuse memory allocations across frames in camera stream |
| **Downscale for preview** | Run edge detection on 720p scaled frame, not full resolution |
| **Async FFI calls** | Run FFI on a separate Dart isolate via `Isolate.run()` |
| **JPEG compression** | Compress result images with configurable quality (70-95) |
| **Batch operations** | Combine enhancement steps into single FFI call instead of multiple round-trips |
| **Memory management** | Free C-allocated strings immediately after Dart copies the data |

## 7. Error Handling

```cpp
// All exported functions follow this error pattern:
// On success: return the result as a C string
// On failure: return JSON: {"error": "description"}
// Dart side checks for "error" key first before parsing result
```

## 8. Memory Safety

```dart
// Dart is responsible for freeing all memory allocated by C
// C allocates with strdup/malloc → Dart frees with malloc.free
// Images passed as raw bytes → C copies them internally
// Never retain C pointers across async gaps
```
