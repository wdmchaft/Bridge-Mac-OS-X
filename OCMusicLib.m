//
// OCMusicLib.m
// Bridge
//
// Created by Philip Regan on 8/7/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

/* 
 * This is for holding constants that are based on class methods, and complex data 
 * types.
 * Simple constants, ones based on core data types need to be moved to OCMusicConstants 
 * if one exists.
 * This is a Singleton class
 * Initialization happens in OCWindowController:windowDidLoad:
 */

#import "OCMusicLib.h"


@implementation OCMusicLib

static OCMusicLib *sharedInstance = nil;

#pragma mark -
#pragma mark Class and Singleton methods
#pragma mark -

+ (OCMusicLib *)sharedLib
{
  @synchronized(self)
  {
    if (sharedInstance == nil)
			sharedInstance = [[OCMusicLib alloc] init];
  }
  return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (sharedInstance == nil) {
      sharedInstance = [super allocWithZone:zone];
      return sharedInstance; // assignment and return on first allocation
    }
  }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (id)retain {
  return self;
}

- (NSUInteger)retainCount {
  return UINT_MAX; // denotes an object that cannot be released
}

- (oneway void)release {
  //do nothing
}

- (id)autorelease {
  return self;
}

#pragma mark -
#pragma mark Init
#pragma mark -

//---------------------------------------------------------- 
// - (id) init
//
//---------------------------------------------------------- 
- (id) init
{
  self = [super init];
  if (self) {
		
    // do something
		
  }
  return self;
}

#pragma mark -
#pragma mark Logic Methods
#pragma mark -

/*
 * Organized by octave for easy identification.
 */

- (BOOL) isBlackKey:(int)tone {
	//Octave 1
	//if (tone ==) { return NO; } // A
	//if (tone ==) { return YES; } // A#
	//if (tone ==) { return NO; } // B
	if (tone == 0) { return NO; } // C
	if (tone == 1) { return YES; } // C#
	if (tone == 2) { return NO; } // D
	if (tone == 3) { return YES; } // D#
	if (tone == 4) { return NO; } // E
	if (tone == 5) { return NO; } // F
	if (tone == 6) { return YES; } // F#
	if (tone == 7) { return NO; } // G
	if (tone == 8) { return YES; } // G#
	//Octave 2
	if (tone == 9) { return NO; } // A
	if (tone == 10) { return YES; } // A#
	if (tone == 11) { return NO; } // B
	if (tone == 12) { return NO; } // C
	if (tone == 13) { return YES; } // C#
	if (tone == 14) { return NO; } // D
	if (tone == 15) { return YES; } // D#
	if (tone == 16) { return NO; } // E
	if (tone == 17) { return NO; } // F
	if (tone == 18) { return YES; } // F#
	if (tone == 19) { return NO; } // G
	if (tone == 20) { return YES; } // G#
	//Octave 3
	if (tone == 21) { return NO; } // A
	if (tone == 22) { return YES; } // A#
	if (tone == 23) { return NO; } // B
	if (tone == 24) { return NO; } // C
	if (tone == 25) { return YES; } // C#
	if (tone == 26) { return NO; } // D
	if (tone == 27) { return YES; } // D#
	if (tone == 28) { return NO; } // E
	if (tone == 29) { return NO; } // F
	if (tone == 30) { return YES; } // F#
	if (tone == 31) { return NO; } // G
	if (tone == 32) { return YES; } // G#
	//Octave 4
	if (tone == 33) { return NO; } // A
	if (tone == 34) { return YES; } // A#
	if (tone == 35) { return NO; } // B
	if (tone == 36) { return NO; } // C
	if (tone == 37) { return YES; } // C#
	if (tone == 38) { return NO; } // D
	if (tone == 39) { return YES; } // D#
	if (tone == 40) { return NO; } // E
	if (tone == 41) { return NO; } // F
	if (tone == 42) { return YES; } // F#
	if (tone == 43) { return NO; } // G
	if (tone == 44) { return YES; } // G#
	//Octave 5
	if (tone == 45) { return NO; } // A
	if (tone == 46) { return YES; } // A#
	if (tone == 47) { return NO; } // B
	if (tone == 48) { return NO; } // C
	if (tone == 49) { return YES; } // C#
	if (tone == 50) { return NO; } // D
	if (tone == 51) { return YES; } // D#
	if (tone == 52) { return NO; } // E
	if (tone == 53) { return NO; } // F
	if (tone == 54) { return YES; } // F#
	if (tone == 55) { return NO; } // G
	if (tone == 56) { return YES; } // G#
	//Octave 6
	if (tone == 57) { return NO; } // A
	if (tone == 58) { return YES; } // A#
	if (tone == 59) { return NO; } // B
	if (tone == 60) { return NO; } // C
	if (tone == 61) { return YES; } // C#
	if (tone == 62) { return NO; } // D
	if (tone == 63) { return YES; } // D#
	if (tone == 64) { return NO; } // E
	if (tone == 65) { return NO; } // F
	if (tone == 66) { return YES; } // F#
	if (tone == 67) { return NO; } // G
	if (tone == 68) { return YES; } // G#
	//Octave 7
	if (tone == 69) { return NO; } // A
	if (tone == 70) { return YES; } // A#
	if (tone == 71) { return NO; } // B
	if (tone == 72) { return NO; } // C
	if (tone == 73) { return YES; } // C#
	if (tone == 74) { return NO; } // D
	if (tone == 75) { return YES; } // D#
	if (tone == 76) { return NO; } // E
	if (tone == 77) { return NO; } // F
	if (tone == 78) { return YES; } // F#
	if (tone == 79) { return NO; } // G
	if (tone == 80) { return YES; } // G#
	//Octave 8
	if (tone == 81) { return NO; } // A
	if (tone == 82) { return YES; } // A#
	if (tone == 83) { return NO; } // B
	if (tone == 84) { return NO; } // C
	if (tone == 85) { return YES; } // C#
	if (tone == 86) { return NO; } // D
	if (tone == 87) { return YES; } // D#
	if (tone == 88) { return NO; } // E
	if (tone == 89) { return NO; } // F
	if (tone == 90) { return YES; } // F#
	if (tone == 91) { return NO; } // G
	if (tone == 92) { return YES; } // G#
	//Octave 9
	if (tone == 93) { return NO; } // A
	if (tone == 94) { return YES; } // A#
	if (tone == 95) { return NO; } // B
	if (tone == 96) { return NO; } // C
	if (tone == 97) { return YES; } // C#
	if (tone == 98) { return NO; } // D
	if (tone == 99) { return YES; } // D#
	if (tone == 100) { return NO; } // E
	if (tone == 101) { return NO; } // F
	if (tone == 102) { return YES; } // F#
	if (tone == 103) { return NO; } // G
	if (tone == 104) { return YES; } // G#
	//Octave 10
	if (tone == 105) { return NO; } // A
	if (tone == 106) { return YES; } // A#
	if (tone == 107) { return NO; } // B
	if (tone == 108) { return NO; } // C
	if (tone == 109) { return YES; } // C#
	if (tone == 110) { return NO; } // D
	if (tone == 111) { return YES; } // D#
	if (tone == 112) { return NO; } // E
	if (tone == 113) { return NO; } // F
	if (tone == 114) { return YES; } // F#
	if (tone == 115) { return NO; } // G
	if (tone == 116) { return YES; } // G#
	//Octave 11
	if (tone == 117) { return NO; } // A
	if (tone == 118) { return YES; } // A#
	if (tone == 119) { return NO; } // B
	if (tone == 120) { return NO; } // C
	if (tone == 121) { return YES; } // C#
	if (tone == 122) { return NO; } // D
	if (tone == 123) { return YES; } // D#
	if (tone == 124) { return NO; } // E
	if (tone == 125) { return NO; } // F
	if (tone == 126) { return YES; } // F#
	if (tone == 127) { return NO; } // G
	//if (tone ==) { return YES; } // G#
	
	return NO;
}
@end
