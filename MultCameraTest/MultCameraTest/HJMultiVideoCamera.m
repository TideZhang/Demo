//
//  HJMultiVideoCamera.m
//  MultCameraTest
//
//  Created by   on 2019/9/18.
//  Copyright © 2019  . All rights reserved.
//

#import "HJMultiVideoCamera.h"

@interface HJMultiVideoCamera () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureMultiCamSession  *cameraSession;

@property (nonatomic, strong) AVCaptureDeviceInput      *frontDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput      *frontVideoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer        *frontPreviewLayer;

@property (nonatomic, strong) AVCaptureDeviceInput      *backDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput      *backVideoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer        *backPreviewLayer;


@property (nonatomic, strong) dispatch_queue_t dataOutputQueue;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (nonatomic, weak) UIView *containerView;


@end

@implementation HJMultiVideoCamera

- (instancetype)initWithPreviewView:(UIView *)view {
    if (self = [super init]) {
        self.sessionQueue = dispatch_queue_create("session.queue", NULL);
        self.dataOutputQueue = dispatch_queue_create("data.output.queue", NULL);
        self.containerView = view;
        [self configSession];
    }
    return self;
}

- (void)startCapture {
    [self.cameraSession startRunning];
}

- (void)stopCapture {
    [self.cameraSession stopRunning];
}

- (void)configSession {
    if (AVCaptureMultiCamSession.isMultiCamSupported == NO) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    
    self.cameraSession = [[AVCaptureMultiCamSession alloc] init];
    [self.cameraSession beginConfiguration];
    
    if ([self configBackCamera] == NO) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        [self.cameraSession commitConfiguration];
        return;
    }
    
    if ([self configFrontCamera] == NO) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        [self.cameraSession commitConfiguration];
        return;
    }
    
    if ([self configMicrophone] == NO) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        [self.cameraSession commitConfiguration];
        return;
    }
    
    [self.cameraSession commitConfiguration];
}

- (BOOL)configFrontCamera {
    AVCaptureDevice *frontCamera = [self.class getCaptureDeviceWithPosition:AVCaptureDevicePositionFront];
    if (frontCamera == nil) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    
    NSError *error = nil;
    self.frontDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:frontCamera error:&error];
    if (![self.cameraSession canAddInput:self.frontDeviceInput]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [self.cameraSession addInputWithNoConnections:self.frontDeviceInput];
    
    self.frontVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.frontVideoDataOutput.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [self.frontVideoDataOutput setSampleBufferDelegate:self queue:self.dataOutputQueue];
    
    if (![self.cameraSession canAddOutput:self.frontVideoDataOutput]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [self.cameraSession addOutputWithNoConnections:self.frontVideoDataOutput];
    
    AVCaptureInputPort *port = [[self.frontDeviceInput portsWithMediaType:AVMediaTypeVideo
                                                         sourceDeviceType:frontCamera.deviceType
                                                     sourceDevicePosition:frontCamera.position] firstObject];
    AVCaptureConnection *frontConnection = [[AVCaptureConnection alloc] initWithInputPorts:@[port] output:self.frontVideoDataOutput];
    
    if (![self.cameraSession canAddConnection:frontConnection]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [self.cameraSession addConnection:frontConnection];
    [frontConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [frontConnection setAutomaticallyAdjustsVideoMirroring:NO];
    [frontConnection setVideoMirrored:YES];
    
    self.frontPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSessionWithNoConnection:self.cameraSession];
    AVCaptureConnection *frontPreviewLayerConnection = [[AVCaptureConnection alloc] initWithInputPort:port videoPreviewLayer:self.frontPreviewLayer];
    [frontPreviewLayerConnection setAutomaticallyAdjustsVideoMirroring:NO];
    [frontPreviewLayerConnection setVideoMirrored:YES];
    if (![self.cameraSession canAddConnection:frontPreviewLayerConnection]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    self.frontPreviewLayer.frame = CGRectMake(30, 30, 180, 320);
    [self.containerView.layer addSublayer:self.frontPreviewLayer];
    [self.cameraSession addConnection:frontPreviewLayerConnection];
    
    return YES;
}

- (BOOL)configBackCamera {
    AVCaptureDevice *backCamera = [self.class getCaptureDeviceWithPosition:AVCaptureDevicePositionBack];
    if (backCamera == nil) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    
    NSError *error = nil;
    self.backDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:backCamera error:&error];
    if (![self.cameraSession canAddInput:self.backDeviceInput]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [self.cameraSession addInputWithNoConnections:self.backDeviceInput];
    
    self.backVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.backVideoDataOutput.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [self.backVideoDataOutput setSampleBufferDelegate:self queue:self.dataOutputQueue];
    
    if (![self.cameraSession canAddOutput:self.backVideoDataOutput]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [self.cameraSession addOutputWithNoConnections:self.backVideoDataOutput];
    
    AVCaptureInputPort *port = [[self.backDeviceInput portsWithMediaType:AVMediaTypeVideo
                                                        sourceDeviceType:backCamera.deviceType
                                                    sourceDevicePosition:backCamera.position] firstObject];
    AVCaptureConnection *backConnection = [[AVCaptureConnection alloc] initWithInputPorts:@[port] output:self.backVideoDataOutput];
    
    if (![self.cameraSession canAddConnection:backConnection]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [self.cameraSession addConnection:backConnection];
    [backConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [backConnection setAutomaticallyAdjustsVideoMirroring:NO];
    [backConnection setVideoMirrored:NO];
    
    self.backPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSessionWithNoConnection:self.cameraSession];
    AVCaptureConnection *backPreviewLayerConnection = [[AVCaptureConnection alloc] initWithInputPort:port videoPreviewLayer:self.backPreviewLayer];
    //    [backPreviewLayerConnection setAutomaticallyAdjustsVideoMirroring:YES];
    //    [backPreviewLayerConnection setVideoMirrored:NO];
    if (![self.cameraSession canAddConnection:backPreviewLayerConnection]) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    self.backPreviewLayer.frame = self.containerView.bounds;
    [self.containerView.layer addSublayer:self.backPreviewLayer];
    
    [self.cameraSession addConnection:backPreviewLayerConnection];
    
    return YES;
}

- (BOOL)configMicrophone {
    
    return YES;
}

///修改分辨率
- (BOOL)reduceResolutionForCamera:(AVCaptureDevicePosition)position {
    for (AVCaptureConnection *connect in self.cameraSession.connections) {
        for (AVCaptureInputPort *inputPort in connect.inputPorts) {
            if (inputPort.mediaType == AVMediaTypeVideo && inputPort.sourceDevicePosition == position) {
                AVCaptureDeviceInput *videoDeviceInput = (AVCaptureDeviceInput *)inputPort.input;
                NSArray *formats = videoDeviceInput.device.formats;
                for (AVCaptureDeviceFormat *format in formats) {
                    if (format.isMultiCamSupported) {
                        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
                        if (dimensions.width == 1280 && dimensions.height == 720) {
                            NSError *error = nil;
                            [self.cameraSession beginConfiguration];
                            if ([videoDeviceInput.device lockForConfiguration:&error]) {
                                videoDeviceInput.device.activeFormat = format;
                                [videoDeviceInput.device setActiveVideoMinFrameDuration:CMTimeMake(1, 15)];
                                [videoDeviceInput.device setActiveVideoMaxFrameDuration:CMTimeMake(1, 15)];
                                [videoDeviceInput.device unlockForConfiguration];
                                NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
                                [self.cameraSession commitConfiguration];
                                return YES;
                            }
                            [self.cameraSession commitConfiguration];
                        }
                    }
                }
            }
        }
    }
    return NO;
}

///修改帧率
- (BOOL)reduceFrameRateForCamera:(AVCaptureDevicePosition)position {
    for (AVCaptureConnection *connect in self.cameraSession.connections) {
        for (AVCaptureInputPort *inputPort in connect.inputPorts) {
            if (inputPort.mediaType == AVMediaTypeVideo && inputPort.sourceDevicePosition == position) {
                AVCaptureDeviceInput *videoDeviceInput = (AVCaptureDeviceInput *)inputPort.input;
                double activeMaxFrameRate = [[@[@(5), @(15), @(20), @(25), @(28)] objectAtIndex:(random() % 5)] floatValue];
                NSError *error = nil;
                [self.cameraSession beginConfiguration];
                if ([videoDeviceInput.device lockForConfiguration:&error]) {
                    NSLog(@"%s, %d----%f", __PRETTY_FUNCTION__, __LINE__, activeMaxFrameRate);
                    [videoDeviceInput.device setActiveVideoMinFrameDuration:CMTimeMake(1, activeMaxFrameRate)];
                    [videoDeviceInput.device setActiveVideoMaxFrameDuration:CMTimeMake(1, activeMaxFrameRate)];
                    [videoDeviceInput.device unlockForConfiguration];
                    [self.cameraSession commitConfiguration];
                    return YES;
                }
                [self.cameraSession commitConfiguration];
            }
        }
    }
    return NO;
}

+ (AVCaptureDevice *)getCaptureDeviceWithPosition:(AVCaptureDevicePosition)position {
    if (@available(iOS 10.0, *)) {
        return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
        for (AVCaptureDevice *device in devices) {
            if (position == device.position) {
                return device;
            }
        }
    }
    return nil;
}


- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (output == self.frontVideoDataOutput) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        static int count = 0;
        static float lastTime = 0;
        CMClockRef hostClockRef = CMClockGetHostTimeClock();
        CMTime hostTime = CMClockGetTime(hostClockRef);
        float nowTime = CMTimeGetSeconds(hostTime);
        if(nowTime - lastTime >= 1) {
            NSLog(@"front-%d--%@-%@", count, NSStringFromCGSize(CVImageBufferGetDisplaySize(imageBuffer)), NSStringFromCGSize(CVImageBufferGetEncodedSize(imageBuffer)));
            lastTime = nowTime;
            count = 0;
        }else {
            count ++;
        }
    } else if (output == self.backVideoDataOutput) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        static int count = 0;
            static float lastTime = 0;
            CMClockRef hostClockRef = CMClockGetHostTimeClock();
            CMTime hostTime = CMClockGetTime(hostClockRef);
            float nowTime = CMTimeGetSeconds(hostTime);
            if(nowTime - lastTime >= 1) {
                NSLog(@"back-%d--%@-%@", count, NSStringFromCGSize(CVImageBufferGetDisplaySize(imageBuffer)), NSStringFromCGSize(CVImageBufferGetEncodedSize(imageBuffer)));
                lastTime = nowTime;
                count = 0;
            }else {
                count ++;
            }
    }
}

@end
