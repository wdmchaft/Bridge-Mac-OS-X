//
//  OCMusicLib.h
//  Bridge
//
//  Created by Philip Regan on 8/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/* 
 * This is for holding constants that are based on class methods, and complex data 
 * types.
 * Simple constants, ones based on core data types need to be moved to OCMusicConstants 
 * if one exists.
 * This is a Singleton class
 * Initialization happens in OCWindowController:windowDidLoad:
 */

#import <Cocoa/Cocoa.h>

@interface OCMusicLib : NSObject {
	
}

#pragma mark -
#pragma mark Class and Singleton Methods
#pragma mark -

+ (OCMusicLib *) sharedLib;

#pragma mark -
#pragma mark Logic Methods
#pragma mark -

/*
 * Determines if a particular pitch is a black key on a standard 88-key keyboard
 * return true if black, else false on any other value
 */

- (BOOL) isBlackKey:(int)tone;

@end
