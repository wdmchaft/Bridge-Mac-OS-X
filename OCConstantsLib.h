//
//  OCConstantsLib.h
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

#import <Cocoa/Cocoa.h>
#import "OCConstants.h"

@interface OCConstantsLib : NSObject {
	
	NSArray *kOCView_ZoomFactors;
	NSArray *kOCView_ZoomDefactors;
	NSArray *kOCView_ZoomLabels;
	int kOCView_zoomIndex_100;
	
	int kOCView_MaxZoomIndex;
	
	int kOCView_ZoomXMinIndex;
	int kOCView_ZoomXMaxIndex;
	int kOCView_ZoomYMinIndex;
	int kOCView_ZoomYMaxIndex;
	
	NSArray *kOCData_TimeSignatureBeatMIDILengths;
	NSArray *kOCData_TimeSignatureBeatLengths;
	
	int currentID;
}

#pragma mark -
#pragma mark Properties
#pragma mark -

@property (nonatomic, readonly) NSArray *kOCView_ZoomFactors;
@property (nonatomic, readonly) NSArray *kOCView_ZoomDefactors;
@property (nonatomic, readonly) NSArray *kOCView_ZoomLabels;
@property (nonatomic, readonly) int kOCView_zoomIndex_100;

@property (nonatomic, readonly) int kOCView_MaxZoomIndex;

@property (nonatomic, readonly) int kOCView_ZoomXMinIndex;
@property (nonatomic, readonly) int kOCView_ZoomXMaxIndex;
@property (nonatomic, readonly) int kOCView_ZoomYMinIndex;
@property (nonatomic, readonly) int kOCView_ZoomYMaxIndex;

@property (nonatomic, readonly) NSArray *kOCData_TimeSignatureBeatMIDILengths;
@property (nonatomic, readonly) NSArray *kOCData_TimeSignatureBeatLengths;

#pragma mark -
#pragma mark Class and Singleton Methods
#pragma mark -

+ (OCConstantsLib *) sharedLib;

#pragma mark -
#pragma mark View Methods
#pragma mark -

/*
 * pixelExact ensures a coordinate will appear as a clean, 1-pixel line on screen
 * without sacrificing anti-aliasing on curves.
 */

- (float) pixelExact:(float)coordinate;

- (float) getZoomFactorAtIndex:(int)index;
- (float) getZoomDefactorAtIndex:(int)index;

#pragma mark -
#pragma mark Model Methods
#pragma mark -

/*
 * currentID returns a float unique to the entire application runtime, regardless
 * of where it is being called from.
 */

- (float) currentID; 

#pragma mark -
#pragma mark Troubleshooting Methods
#pragma mark -

- (void) logRect:(NSRect)rect withLabel:(NSString *)label;

@end
