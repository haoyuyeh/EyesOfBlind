//
//  OpenCVWrapper.m
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/30.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

#import "OpenCVWrapper.h"
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>

@implementation OpenCVWrapper
// implement here

// transform color image to grayscale

+(UIImage *) toGray:(UIImage *)image
{
    // transform UIImage to Mat image
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    // if the image was already grayscale, return it
    if (imageMat.channels() == 1) {
        return image;
    }
    
    // transform color image to grayscale and return it
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    return MatToUIImage(grayMat);
}

@end
