//
//  Recorder.m
//  ImageOverlay
//
//  Created by David Bitton on 4/29/11.
//  Copyright 2011 Code No Evil, LLC. All rights reserved.
//

#import "RCRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@implementation RCRecorder

@synthesize recording;

- (id) init {
    if((self = [super init]) != nil) {
        
        [self setupRecorder];
        
    }
    
    return self;
}

- (BOOL) recording {
    return videoWriter.status == AVAssetWriterStatusWriting;
}

- (NSURL *) tempFileURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"]];
}

- (void) copyMovieToCameraRoll {
    NSLog(@"end record");
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[self tempFileURL]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    //                                    if (error) {
                                    //                                        if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                    //                                            [[self delegate] captureManager:self didFailWithError:error];
                                    //                                        }											
                                    //                                    }
                                    //                                    
                                    //                                    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                                    //                                        [[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
                                    //                                    }
                                    //                                    
                                    //                                    if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
                                    //                                        [[self delegate] captureManagerRecordingFinished:self];
                                    //                                    }
                                }];
    [library release];
}

- (void) dealloc {
    [adaptor        release];
    [videoWriter    release];
    [super dealloc];
}

- (BOOL) setupRecorder {
    NSError *error = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:[[self tempFileURL] path]])
        [[NSFileManager defaultManager] removeItemAtURL:[self tempFileURL] error:&error];
    

    videoWriter = [[AVAssetWriter alloc] initWithURL: [self tempFileURL] 
                                            fileType:AVFileTypeQuickTimeMovie
                                               error:&error]; 
    // writer
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey, 
                                   [NSNumber numberWithInt:1280], AVVideoWidthKey, 
                                   [NSNumber numberWithInt:720], AVVideoHeightKey,
                                   nil];
    
    writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo 
                                                      outputSettings:videoSettings];
    
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys: 
                                      [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, 
                                      nil];
    
    adaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:bufferAttributes];  
    [adaptor retain];
    writerInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:writerInput];

    return NO;
}

- (void) startRecorder:(CMTime)sourceTime {
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:sourceTime];
}

- (void) stopRecorder:(CMTime)sourceTime {
    [writerInput markAsFinished];
    [videoWriter endSessionAtSourceTime:sourceTime];
    [videoWriter finishWriting];
    [self copyMovieToCameraRoll];
}

- (BOOL)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime {
    if (writerInput.readyForMoreMediaData)     
        return [adaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];  
    return NO;
}

- (CVPixelBufferRef) createPixelBufferRef {
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &pixelBuffer);
    return pixelBuffer;
}

@end
