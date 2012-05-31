//
//  OCConstantsLib.m
//  Bridge
//
//  Created by Philip Regan on 7/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * OCConstantsLib is for holding constants that are based on class methods, and 
 * complex data types.
 * Simple constants, ones based on core data types need to be moved to OCConstants
 * This is a singleton class.
 * Initialization happens in OCWindowController:windowDidLoad:
 */


#import "OCConstantsLib.h"


@implementation OCConstantsLib

static OCConstantsLib *sharedInstance = nil;

#pragma mark -
#pragma mark Properties
#pragma mark -

@synthesize kOCView_ZoomFactors;
@synthesize kOCView_ZoomDefactors;
@synthesize kOCView_ZoomLabels;
@synthesize kOCView_zoomIndex_100;
@synthesize kOCView_MaxZoomIndex;
@synthesize kOCView_ZoomXMinIndex;
@synthesize kOCView_ZoomXMaxIndex;
@synthesize kOCView_ZoomYMinIndex;
@synthesize kOCView_ZoomYMaxIndex;
@synthesize kOCData_TimeSignatureBeatMIDILengths;
@synthesize kOCData_TimeSignatureBeatLengths;

#pragma mark -
#pragma mark Class and Singleton methods
#pragma mark -

+ (OCConstantsLib *)sharedLib
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[OCConstantsLib alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
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
    return UINT_MAX;  // denotes an object that cannot be released
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
        kOCView_ZoomFactors = [NSArray arrayWithObjects:
							   [NSNumber numberWithFloat:0.25f],
							   [NSNumber numberWithFloat:0.5f],	
							   [NSNumber numberWithFloat:0.75f],
							   [NSNumber numberWithFloat:1.0f],	
							   [NSNumber numberWithFloat:1.25f],
							   [NSNumber numberWithFloat:1.5f],
							   [NSNumber numberWithFloat:2.0f],	
							   [NSNumber numberWithFloat:4.0f],	
							   [NSNumber numberWithFloat:8.0f],	
							   [NSNumber numberWithFloat:16.0f],
							   nil];
		[kOCView_ZoomFactors retain];
		
		kOCView_ZoomDefactors = [NSArray arrayWithObjects:
										   [NSNumber numberWithFloat:4.0f],
										   [NSNumber numberWithFloat:2.0f],	
										   [NSNumber numberWithFloat:1.33333333f],
										   [NSNumber numberWithFloat:1.0f],	
										   [NSNumber numberWithFloat:0.8f],
										   [NSNumber numberWithFloat:0.66666666f],	
										   [NSNumber numberWithFloat:0.5f],	
										   [NSNumber numberWithFloat:0.25],	
										   [NSNumber numberWithFloat:0.125f], 
										   [NSNumber numberWithFloat:0.0625f], 
										   nil];
		[kOCView_ZoomDefactors retain];
		
		kOCView_ZoomLabels = [NSArray arrayWithObjects:
										@"25%",
										@"50%",	
										@"75%",
										@"100%",	
										@"125%",
										@"150%",
										@"200%",	
										@"400%",	
										@"800%",	
										@"1600%",
										nil];
		[kOCView_ZoomLabels retain];
		
		kOCData_TimeSignatureBeatMIDILengths = [NSArray arrayWithObjects: 
										[NSNumber numberWithFloat:kNoteLength_01], 
										[NSNumber numberWithFloat:kNoteLength_02], 
										[NSNumber numberWithFloat:kNoteLength_04],
										[NSNumber numberWithFloat:kNoteLength_08],
										[NSNumber numberWithFloat:kNoteLength_16],
										[NSNumber numberWithFloat:kNoteLength_32],
										[NSNumber numberWithFloat:kNoteLength_64],
											nil];
		[kOCData_TimeSignatureBeatMIDILengths retain];
		
		kOCData_TimeSignatureBeatLengths = [NSArray arrayWithObjects: 
											[NSNumber numberWithFloat:1], 
											[NSNumber numberWithFloat:2], 
											[NSNumber numberWithFloat:4],
											[NSNumber numberWithFloat:8],
											[NSNumber numberWithFloat:16],
											[NSNumber numberWithFloat:32],
											[NSNumber numberWithFloat:64],
												nil];
		[kOCData_TimeSignatureBeatLengths retain];
		
		kOCView_zoomIndex_100 = 3;
		
		kOCView_ZoomXMinIndex = 0;
		kOCView_ZoomXMaxIndex = [kOCView_ZoomFactors count] - 1;
		
		int firstZoomFactor = 0;
		int currentZoomFactor = 0;
		int lastZoomFactor = [kOCView_ZoomFactors count];
		for (currentZoomFactor = firstZoomFactor; currentZoomFactor < lastZoomFactor; currentZoomFactor++) {
			NSNumber *zoomFactor = [kOCView_ZoomFactors objectAtIndex:currentZoomFactor];
			
			if ([zoomFactor floatValue] == 1.0f) { kOCView_zoomIndex_100 = currentZoomFactor; }
			if ([zoomFactor floatValue] == 0.25f) { kOCView_ZoomYMinIndex = currentZoomFactor; }
			if ([zoomFactor floatValue] == 2.0f) { kOCView_ZoomYMaxIndex = currentZoomFactor; }
			
		}
		
		kOCView_MaxZoomIndex = [kOCView_ZoomFactors count] - 1;
		
		currentID = 0;
    }
    return self;
}

#pragma mark -
#pragma mark View Methods
#pragma mark -

- (float) pixelExact:(float)coordinate {
	return floorf(coordinate) + 0.5f;
}

- (float) getZoomFactorAtIndex:(int)index {
	NSNumber *zoomFactor = [kOCView_ZoomFactors objectAtIndex:index];
	float zoomFactorValue = [zoomFactor floatValue];
	return zoomFactorValue;
}

- (float) getZoomDefactorAtIndex:(int)index {
	NSNumber *zoomDefactor = [kOCView_ZoomDefactors objectAtIndex:index];
	float zoomDefactorValue = [zoomDefactor floatValue];
	return zoomDefactorValue;
}

#pragma mark -
#pragma mark Model Methods
#pragma mark -

- (float) currentID {
	currentID++;
	return currentID;
}

#pragma mark -
#pragma mark Troubleshooting Methods
#pragma mark -

- (void) logRect:(NSRect)rect withLabel:(NSString *)label {
	
	//NSLog(@"%@: {%f, %f, %f, %f}", label, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
}

@end
