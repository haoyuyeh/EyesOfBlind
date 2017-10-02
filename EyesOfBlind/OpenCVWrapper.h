//
//  OpenCVWrapper.h
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/30.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

// define function here

// transform color image to grayscale
+(UIImage *) toGray:(UIImage *) image;

/**
 compare two images and visulize the corresponding and similar points;
 if there is any
 */
+(UIImage *) imageSimilarity:(UIImage *)image1 andImage2:(UIImage *)image2;

/**
 determine the shifting angle based on the start and end point
 */
+(double) getShiftingAngle:(double)x1 andY1:(double)y1 andX2:(double)x2 andY2:(double)y2;

@end
