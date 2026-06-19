#include <iostream>
#include <opencv2/opencv.hpp>

int main(int argc, char** argv)
{
	cv::Mat img;
	img = cv::imread("./test/color.jpeg", cv::IMREAD_COLOR);

	/* ~~~~ edge case : cannot open file ~~~~ */
	if(!img.data)
	{
		std::cout << "Couldn't open the file" << std::endl;
		return EXIT_FAILURE;
	}

	/* ~~~~ create OS window for image ~~~~ */
	cv::namedWindow("imgwin", cv::WINDOW_NORMAL);

	/* ~~~~ place img into window ~~~~ */
	cv::imshow("imgwin", img);

	/* ~~~~ block prog from term ~~~~ */
	cv::waitKey(0);

	return EXIT_SUCCESS;
}
