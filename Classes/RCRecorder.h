//
//  Recorder.h
//  ImageOverlay
//
//  Created by David Bitton on 4/29/11.
//  Copyright 2011 Code No Evil, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RCRecorder : NSObject {
    AVAssetWriter *videoWriter;
    AVAssetWriterInput *writerInput;
    AVAssetWriterInputPixelBufferAdaptor *adaptor;
    
    BOOL recording;
}

@property (nonatomic, readonly) BOOL recording;

- (BOOL) setupRecorder;
- (void) startRecorder:(CMTime)sourceTime;
- (void) stopRecorder:(CMTime)sourceTime;
- (BOOL) appendPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime;
- (CVPixelBufferRef) createPixelBufferRef;

@end
