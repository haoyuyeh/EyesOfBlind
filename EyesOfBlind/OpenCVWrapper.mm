//
//  OpenCVWrapper.m
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/30.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

#import "OpenCVWrapper.h"
#import <opencv2/core.hpp>
#import <opencv2/features2d.hpp>
#import <opencv2/xfeatures2d.hpp>
#import <opencv2/imgcodecs.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>

using namespace cv;
using namespace cv::xfeatures2d;

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

/**
 compare two images to find out the shift of objects, if two images have something in common
 */
+(double) positionShifting:(UIImage *)image1 andImage2:(UIImage *)image2
{
    Mat img1GrayMat;
    
    UIImage* image1Gray = [OpenCVWrapper toGray:image1];
    UIImageToMat(image1Gray, img1GrayMat);
    
    Mat img2GrayMat;
    
    UIImage* image2Gray = [OpenCVWrapper toGray:image2];
    UIImageToMat(image2Gray, img2GrayMat);
    
    //-- Step 1: Detect the keypoints using SURF Detector, compute the descriptors
    int minHessian = 400;
    
    Ptr<SURF> detector = SURF::create();
    detector->setHessianThreshold(minHessian);
    
    std::vector<KeyPoint> keypoints_1, keypoints_2;
    Mat descriptors_1, descriptors_2;
    
    detector->detectAndCompute( img1GrayMat, Mat(), keypoints_1, descriptors_1 );
    detector->detectAndCompute( img2GrayMat, Mat(), keypoints_2, descriptors_2 );
    
    //-- Step 2: Matching descriptor vectors using FLANN matcher
    if(descriptors_1.type()!=CV_32F) {
        descriptors_1.convertTo(descriptors_1, CV_32F);
    }
    
    if(descriptors_2.type()!=CV_32F) {
        descriptors_2.convertTo(descriptors_2, CV_32F);
    }
    // if no keypoints, the following code would failed
    if((keypoints_1.capacity() <= 0) || (keypoints_2.capacity() <= 0))
    {
        return 0.0;
    }
    
    cv::FlannBasedMatcher matcher;
    std::vector< cv::DMatch > matches;
    
    matcher.match( descriptors_1, descriptors_2, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_1.rows; i++ ) {
        double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
//    printf("-- Max dist : %f \n", max_dist );
//    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 2*min_dist,
    //-- or a small arbitary value ( 0.02 ) in the event that min_dist is very
    //-- small)
    //-- PS.- radiusMatch can also be used here.
    std::vector< cv::DMatch > good_matches;
    
    for( int i = 0; i < descriptors_1.rows; i++ ) {
        if( matches[i].distance <= fmax(2*min_dist, 0.02) ) {
            good_matches.push_back( matches[i]);
        }
    }
    
    //-- Draw only "good" matches
    cv::Mat img_matches;
    
    drawMatches( img1GrayMat, keypoints_1, img2GrayMat, keypoints_2,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                std::vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    //-- Show detected matches
    long num_matches = good_matches.size();
    float x = 0;
//    float y = 0;
    
    for (int i=0; i<num_matches; i++)
    {
        int idx1=good_matches[i].queryIdx;
        int idx2=good_matches[i].trainIdx;
        float p1x, p2x;
//        float p1y, p2y;
        p1x = keypoints_1[idx1].pt.y;
//        p1y = keypoints_1[idx1].pt.x;
        p2x = keypoints_2[idx2].pt.y;
//        p2y = keypoints_2[idx2].pt.x;
        
//        printf( "-- Good Match [%d] Keypoint 1: (%f,%f)  -- Keypoint 2: (%f,%f)  \n", i, keypoints_1[idx1].pt.x, keypoints_1[idx1].pt.y, keypoints_2[idx2].pt.x, keypoints_2[idx2].pt.y );
        x += (p1x - p2x);
//        y += (p1y - p2y);
    }
    
//    printf("x = %f\n", x/num_matches);
    return x/num_matches;
}



@end
