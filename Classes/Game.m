//
//  Game.m
//  AppScaffold
//
//  Created by Daniel Sperl on 14.01.10.
//  Copyright 2010 Incognitek. All rights reserved.
//

#import "Game.h" 

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        // this is where the code of your game will start. 
        // in this sample, we add just a simple quad to see if it works.
        
//        SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
//        quad.color = 0xff0000;
//        quad.x = 50;
//        quad.y = 50;
//        [self addChild:quad];
        
        // Per default, this project compiles as an iPhone application. To change that, enter the 
        // project info screen, and in the "Build"-tab, find the setting "Targeted device family".
        //
        // Now Choose:  
        //   * iPhone      -> iPhone only App
        //   * iPad        -> iPad only App
        //   * iPhone/iPad -> Universal App  
        // 
        // If you want to support the iPad, you have to change the "iOS deployment target" setting
        // to "iOS 3.2" (or "iOS 4.2", if it is available.)
        self.frameRate = 30;
        
        image = [[SPImage alloc] initWithWidth:width height:height];
        [self addChild:image];
        [image release];
        
        button = [SPButton buttonWithUpState:[SPTexture textureWithContentsOfFile:@"button_normal.png"] text:@"Start Recording"];
        [button addEventListener:@selector(onRecordButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        button.x = 160 - (int)(button.width / 2);
        button.y = 20;
        [self addChild:button];
        //[button release];
        
        camera = [[RCCamera alloc] init];
        camera.delegate = self;
        [camera startRunning];
        
        recorder = [[RCRecorder alloc] init];  
    }
    return self;
}

- (void) dealloc {
    if (recorder.recording)
        [recorder stopRecorder:camera.lastSampleTime];
    [recorder release];

    if(camera.isRunning)
        [camera stopRunning];
    camera.delegate = nil;
    [camera release];
    [self removeAllChildren];
    [super dealloc];
}

- (void) onRecordButtonPressed:(SPEvent*)event {
    if (recorder.recording) {
        // finish up
        [recorder stopRecorder:camera.lastSampleTime];
        dispatch_release(recordQueue);
        button.text = @"Start Recording";
    } else {
        recordQueue = dispatch_queue_create("recordQueue", NULL);
        [recorder setupRecorder];
        [recorder startRecorder:camera.lastSampleTime];
        button.text = @"Stop Recording";
    }
}

#pragma mark -
#pragma mark RCCameraOutputDelegate

- (void) sessionStarted {
    NSLog(@"Camera session started");
}

- (void) processNewBuffer:(CVImageBufferRef)cameraFrame {
    SP_CREATE_POOL(pool);
    
//    if (!recorder.recording)
//        [recorder startRecorder:camera.lastSampleTime];
    CVPixelBufferLockBaseAddress(cameraFrame, 0);
        
        int bufferHeight = CVPixelBufferGetHeight(cameraFrame);
        int bufferWidth = CVPixelBufferGetWidth(cameraFrame);

    
    dispatch_sync(dispatch_get_main_queue(), ^{ 
        
        image.texture = [SPGLTexture textureWithData:CVPixelBufferGetBaseAddress(cameraFrame) 
                                          properties:(SPTextureProperties){ .width = bufferWidth, .height = bufferHeight, .format = SPTextureFormatBGRA }];
        
    });

    if(recorder.recording) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CVPixelBufferRef pixelBuffer = [recorder createPixelBufferRef];
            CVPixelBufferRetain(pixelBuffer);
            CVPixelBufferLockBaseAddress(pixelBuffer, 0);
            glReadPixels(0, 0, bufferWidth, bufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));
            
            [recorder appendPixelBuffer:pixelBuffer withPresentationTime:camera.lastSampleTime];
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            CVPixelBufferRelease(pixelBuffer);
         });
    }

    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
    
    SP_RELEASE_POOL(pool);
}

@end
