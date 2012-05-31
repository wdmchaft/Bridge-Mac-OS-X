//
//  OCMusicPieceObj.h
//  Bridge
//
//  Created by Philip Regan on 2011/11/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
    Manages the music piece itself. This is different from the WindowController 
    in that the Window Controller is really focused on user interaction with the 
    objects. This is more focused on the music-related logic, like the key, time
    signature, tempo, and the like
 */

#import <Foundation/Foundation.h>

@class OCKeyObj;

@interface OCMusicPieceObj : NSObject {
    
    OCKeyObj *key;
    
}

@property (readonly) OCKeyObj *key;

@end
