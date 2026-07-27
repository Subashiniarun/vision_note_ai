#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <cstring>
#include <string>
#include <vector>
#include <sstream>
#include <cstdlib>

#ifdef __cplusplus
extern "C" {
#endif

static std::string matToBase64(const cv::Mat& mat) {
    std::vector<unsigned char> buf;
    cv::imencode(".png", mat, buf);
    const char* base64_chars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789+/";
    std::string result;
    int i = 0;
    for (size_t j = 0; j < buf.size(); j++) {
        i = j % 3;
        if (i == 0) {
            result.push_back(base64_chars[(buf[j] >> 2) & 0x3F]);
            result.push_back(base64_chars[((buf[j] & 0x3) << 4)]);
        } else if (i == 1) {
            result.back() = base64_chars[((buf[j - 1] & 0xF) << 2) | ((buf[j] >> 6) & 0x3)];
            result.push_back(base64_chars[buf[j] & 0x3F]);
        } else {
            result.back() = base64_chars[((buf[j - 1] & 0x3) << 4) | ((buf[j] >> 2) & 0xF)];
            result.push_back(base64_chars[(buf[j] & 0x3) << 4]);
            result.back() = base64_chars[((buf[j] & 0x3) << 4)];
        }
    }
    while (result.size() % 4) result.push_back('=');
    return result;
}

static cv::Mat bufferToMat(unsigned char* data, int width, int height, int channels) {
    if (channels == 4) {
        cv::Mat rgba(height, width, CV_8UC4, data);
        cv::Mat bgra;
        cv::cvtColor(rgba, bgra, cv::COLOR_RGBA2BGRA);
        return bgra;
    }
    return cv::Mat(height, width, CV_8UC3, data);
}

static cv::Mat matToRGBA(const cv::Mat& bgra) {
    cv::Mat rgba;
    cv::cvtColor(bgra, rgba, cv::COLOR_BGRA2RGBA);
    return rgba;
}

char* detect_document_edges(unsigned char* imageData, int width, int height, int channels) {
    try {
        cv::Mat src = bufferToMat(imageData, width, height, channels);
        cv::Mat gray, blurred, edges;

        cv::cvtColor(src, gray, cv::COLOR_BGRA2GRAY);
        cv::GaussianBlur(gray, blurred, cv::Size(5, 5), 1.0);
        cv::Canny(blurred, edges, 40, 100);

        std::vector<std::vector<cv::Point>> contours;
        std::vector<cv::Vec4i> hierarchy;
        cv::findContours(edges, contours, hierarchy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

        double maxArea = 0;
        std::vector<cv::Point> largestContour;

        for (const auto& contour : contours) {
            double area = cv::contourArea(contour);
            if (area > maxArea) {
                maxArea = area;
                largestContour = contour;
            }
        }

        if (largestContour.empty()) {
            return strdup("{\"error\": \"no_contours_found\"}");
        }

        std::vector<cv::Point> approx;
        double peri = cv::arcLength(largestContour, true);
        cv::approxPolyDP(largestContour, approx, 0.02 * peri, true);

        std::stringstream ss;
        ss << "{\"corners\": [";
        for (size_t i = 0; i < approx.size() && i < 4; i++) {
            if (i > 0) ss << ",";
            ss << "{\"x\": " << approx[i].x << ", \"y\": " << approx[i].y << "}";
        }
        ss << "]}";

        return strdup(ss.str().c_str());
    } catch (const std::exception& e) {
        std::string err = "{\"error\": \"";
        err += e.what();
        err += "\"}";
        return strdup(err.c_str());
    }
}

char* correct_perspective(
    unsigned char* imageData, int width, int height, int channels,
    float x1, float y1, float x2, float y2,
    float x3, float y3, float x4, float y4
) {
    try {
        cv::Mat src = bufferToMat(imageData, width, height, channels);

        std::vector<cv::Point2f> srcPoints = {
            cv::Point2f(x1, y1),
            cv::Point2f(x2, y2),
            cv::Point2f(x3, y3),
            cv::Point2f(x4, y4)
        };

        float dstWidth = std::max(
            std::sqrt(std::pow(x2 - x1, 2) + std::pow(y2 - y1, 2)),
            std::sqrt(std::pow(x4 - x3, 2) + std::pow(y4 - y3, 2))
        );
        float dstHeight = std::max(
            std::sqrt(std::pow(x4 - x1, 2) + std::pow(y4 - y1, 2)),
            std::sqrt(std::pow(x3 - x2, 2) + std::pow(y3 - y2, 2))
        );

        std::vector<cv::Point2f> dstPoints = {
            cv::Point2f(0, 0),
            cv::Point2f(dstWidth - 1, 0),
            cv::Point2f(dstWidth - 1, dstHeight - 1),
            cv::Point2f(0, dstHeight - 1)
        };

        cv::Mat M = cv::getPerspectiveTransform(srcPoints, dstPoints);
        cv::Mat warped;
        cv::warpPerspective(src, warped, M, cv::Size(dstWidth, dstHeight));

        cv::Mat rgba = matToRGBA(warped);
        std::string b64 = matToBase64(rgba);
        return strdup(b64.c_str());
    } catch (const std::exception& e) {
        return strdup("");
    }
}

char* auto_enhance(unsigned char* imageData, int width, int height, int channels) {
    try {
        cv::Mat src = bufferToMat(imageData, width, height, channels);
        cv::Mat gray, enhanced;

        cv::cvtColor(src, gray, cv::COLOR_BGRA2GRAY);

        cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE(2.0, cv::Size(8, 8));
        clahe->apply(gray, enhanced);

        cv::bilateralFilter(enhanced, enhanced, 9, 75, 75);

        cv::Mat sharp = enhanced.clone();
        cv::GaussianBlur(enhanced, sharp, cv::Size(0, 0), 1.0);
        cv::addWeighted(enhanced, 1.5, sharp, -0.5, 0, enhanced);

        cv::Mat result;
        cv::cvtColor(enhanced, result, cv::COLOR_GRAY2BGRA);

        cv::Mat rgba = matToRGBA(result);
        std::string b64 = matToBase64(rgba);
        return strdup(b64.c_str());
    } catch (const std::exception& e) {
        return strdup("");
    }
}

char* preprocess_for_handwriting(unsigned char* imageData, int width, int height, int channels) {
    try {
        cv::Mat src = bufferToMat(imageData, width, height, channels);
        cv::Mat gray, binary, closed;

        cv::cvtColor(src, gray, cv::COLOR_BGRA2GRAY);
        cv::GaussianBlur(gray, gray, cv::Size(3, 3), 0.8);

        cv::adaptiveThreshold(gray, binary, 255,
            cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 15, 6);

        cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(3, 3));
        cv::morphologyEx(binary, closed, cv::MORPH_CLOSE, kernel);

        cv::Mat result;
        cv::cvtColor(closed, result, cv::COLOR_GRAY2BGRA);

        cv::Mat rgba = matToRGBA(result);
        std::string b64 = matToBase64(rgba);
        return strdup(b64.c_str());
    } catch (const std::exception& e) {
        return strdup("");
    }
}

#ifdef __cplusplus
}
#endif
