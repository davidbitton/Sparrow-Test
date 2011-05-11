//
//  RCCamera.m
//  ImageOverlay
//
//  Created by David Bitton on 5/2/11.
//  Copyright 2011 Code No Evil, LLC. All rights reserved.
//

#import "RCCamera.h"

@interface RCCamera ()

- (void) configureCaptureSession;

@end

@implementation RCCamera

@synthesize delegate;
@synthesize isRunning;
@synthesize lastSampleTime;

- (id) init {
	if (!(self = [super init]))
		return nil;
    
    [self configureCaptureSession];
    return self;
}

- (void) dealloc {
    [self stopRunning];
    
    [captureSession release];
    [super dealloc];
}

- (void) startRunning {    
    if(![captureSession isRunning])
        [captureSession startRunning];
    isRunning = [captureSession isRunning];
    
    [self.delegate sessionStarted];
}

- (void) stopRunning {
    if([captureSession isRunning])
        [captureSession stopRunning];  
    isRunning = [captureSession isRunning];
}

- (void) configureCaptureSession {
    captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error;  
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    [captureSession addInput:deviceInput];
    
    // Add the video frame output	
	videoOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES];
	// Use RGB frames instead of YUV to ease color processing
	[videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                                                              forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    dispatch_queue_t videoQueue = dispatch_queue_create("com.codenoevil.dev.videoqueue", NULL);
    [videoOutput setSampleBufferDelegate:self queue:videoQueue];
    videoOutput.minFrameDuration = CMTimeMake(1, 30);
    dispatch_release(videoQueue);
    
    if ([captureSession canAddOutput:videoOutput]) {
        [captureSession addOutput:videoOutput];
    }
    
    [captureSession beginConfiguration]; 
    // config session here
    //[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    [captureSession commitConfiguration];
    
    NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(onCaptureError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
    [notify addObserver:self selector:@selector(onCaptureStart:) name:AVCaptureSessionDidStartRunningNotification object:captureSession];
    [notify addObserver:self selector:@selector(onCaptureStop:) name:AVCaptureSessionDidStopRunningNotification object:captureSession];
    [notify addObserver:self selector:@selector(onCaptureInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:captureSession];
    [notify addObserver:self selector:@selector(onCaptureResumed:) name:AVCaptureSessionInterruptionEndedNotification object:captureSession];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate methods

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if( !CMSampleBufferDataIsReady(sampleBuffer) )
    {
        NSLog( @"sample buffer is not ready. Skipping sample" );
        return;
    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);

    [self.delegate processNewBuffer:imageBuffer];
    
}

#pragma mark -
#pragma mark AVCaptureSession Notifications

-(void)onCaptureError: (NSNotification *)notification {
    AVCaptureSession *session = [notification object];
    NSLog(@"Capture Error: %@", session);    
}

-(void)onCaptureStart: (NSNotification *)notification {
    AVCaptureSession *session = [notification object];
    NSLog(@"Capture Started: %@", session);
}

- (void)onCaptureStop: (NSNotification *)notification {
    AVCaptureSession *session = [notification object];
    NSLog(@"Capture Stopped: %@", session);
}

-(void)onCaptureInterrupted: (NSNotification *)notification {
    AVCaptureSession *session = [notification object];
    NSLog(@"Capture Interrupted: %@", session);    
}

-(void)onCaptureResumed: (NSNotification *)notification {
    AVCaptureSession *session = [notification object];
    NSLog(@"Capture Resumed: %@", session);    
}

@end
