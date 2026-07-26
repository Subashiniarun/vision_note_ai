import 'package:injectable/injectable.dart';

// Native OpenCV module - uncomment when libopencv_processor.so is available
// import '../../../native/ffi/opencv_bindings.dart';
// import '../../../native/ffi/opencv_service.dart';

@module
abstract class NativeModule {
  // Register these when the native OpenCV library (.so / .dylib) is built:
  // @lazySingleton
  // OpenCVBindings get openCVBindings => OpenCVBindings();
  //
  // @lazySingleton
  // OpenCVService get openCVService => OpenCVService(openCVBindings);
}
