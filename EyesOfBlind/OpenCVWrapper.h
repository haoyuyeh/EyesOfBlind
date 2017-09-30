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

@end
