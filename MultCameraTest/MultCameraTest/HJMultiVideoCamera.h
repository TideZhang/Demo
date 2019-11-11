//
//  HJMultiVideoCamera.h
//  MultCameraTest
//
//  Created by   on 2019/9/18.
//  Copyright © 2019  . All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface HJMultiVideoCamera : NSObject

- (instancetype)initWithPreviewView:(UIView *)view;
- (void)startCapture;

- (BOOL)reduceFrameRateForCamera:(AVCaptureDevicePosition)position;
- (BOOL)reduceResolutionForCamera:(AVCaptureDevicePosition)position;

@end

NS_ASSUME_NONNULL_END
