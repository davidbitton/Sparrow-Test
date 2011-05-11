//
//  RCCamera.h
//  ImageOverlay
//
//  Created by David Bitton on 5/2/11.
//  Copyright 2011 Code No Evil, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol RCCameraOutputDelegate;

@interface RCCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *captureSession;
    AVCaptureVideoDataOutput *videoOutput;
    AVCaptureDevice *captureDevice;
    AVCaptureDeviceInput *deviceInput;
    BOOL isRunning;
    CMTime lastSampleTime;
    
}

@property (nonatomic, assign) id<RCCameraOutputDelegate> delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) CMTime lastSampleTime;

- (void) startRunning;
- (void) stopRunning;

@end

@protocol RCCameraOutputDelegate

- (void) sessionStarted;
- (void) processNewBuffer:(CVImageBufferRef)cameraFrame;

@end
