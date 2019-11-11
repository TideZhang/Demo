//
//  ViewController.m
//  MultCameraTest
//
//  Created by   on 2019/9/15.
//  Copyright © 2019  . All rights reserved.
//

#import "ViewController.h"
@import AVFoundation;
#import "HJMultiVideoCamera.h"

@interface ViewController ()

@property (nonatomic, strong) HJMultiVideoCamera *videoCamera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.videoCamera = [[HJMultiVideoCamera alloc] initWithPreviewView:self.view];
    [self.videoCamera startCapture];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"FPS" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(300, 100, 80, 40)];
    [button addTarget:self action:@selector(fpsButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"后FPS" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(300, 150, 80, 40)];
    [button addTarget:self action:@selector(fpsButtonClicked1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Preset" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(300, 200, 80, 40)];
    [button addTarget:self action:@selector(presetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"后Preset" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(300, 250, 80, 40)];
    [button addTarget:self action:@selector(presetButtonClicked1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)fpsButtonClicked {
    [self.videoCamera reduceFrameRateForCamera:AVCaptureDevicePositionFront];
}

- (void)presetButtonClicked {
    [self.videoCamera reduceResolutionForCamera:AVCaptureDevicePositionFront];
}
- (void)fpsButtonClicked1 {
    [self.videoCamera reduceFrameRateForCamera:AVCaptureDevicePositionBack];
}

- (void)presetButtonClicked1 {
    [self.videoCamera reduceResolutionForCamera:AVCaptureDevicePositionBack];
}
@end
