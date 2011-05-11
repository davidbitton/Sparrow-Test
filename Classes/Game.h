//
//  Game.h
//  AppScaffold
//
//  Created by Daniel Sperl on 14.01.10.
//  Copyright 2010 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCCamera.h"
#import "RCRecorder.h"

@interface Game : SPStage <RCCameraOutputDelegate> {
    RCCamera *camera;
    RCRecorder *recorder;
    
    GLuint videoFrameTexture;
    SPSprite *sprite;
    SPImage *image;
    SPButton *button;
    
    dispatch_queue_t recordQueue;
}

@end
