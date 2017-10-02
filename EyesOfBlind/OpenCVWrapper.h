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
+(double) positionShifting:(UIImage *)image1 andImage2:(UIImage *)image2;


@end
