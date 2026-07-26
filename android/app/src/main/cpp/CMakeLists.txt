cmake_minimum_required(VERSION 3.22)

project("opencv_processor")

set(OpenCV_DIR "C:/OpenCV-android-sdk/sdk/native/jni")

find_package(OpenCV REQUIRED)

file(GLOB native_src "*.cpp")

add_library(
    opencv_processor
    SHARED
    ${native_src}
)

target_include_directories(
    opencv_processor
    PRIVATE
    ${OpenCV_INCLUDE_DIRS}
)

target_link_libraries(
    opencv_processor
    ${OpenCV_LIBS}
    jnigraphics
    log
)
