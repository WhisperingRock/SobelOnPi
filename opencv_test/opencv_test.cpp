#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>

int main() {
    std::cout << "OpenCV version: " << CV_MAJOR_VERSION << "." 
              << CV_MINOR_VERSION << "." << CV_SUBMINOR_VERSION << std::endl;
    
    // Create a simple 3x3 matrix
    cv::Mat mat = cv::Mat::zeros(3, 3, CV_32F);
    mat.at<float>(0, 0) = 1.5f;
    mat.at<float>(1, 1) = 2.5f;
    mat.at<float>(2, 2) = 3.5f;
    
    std::cout << "Matrix created and populated successfully:\n" << mat << std::endl;
    
    // Test a simple operation
    cv::Mat result;
    cv::transpose(mat, result);
    std::cout << "Transpose successful:\n" << result << std::endl;
    
    std::cout << "\n All tests passed!" << std::endl;
    return 0;
}

