//
//  OCRulerView.h
//  Bridge
//
//  Created by Philip Regan on 6/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * This is the ruler that sits above the piano roll that shows where
 * in the song objects are. 
 * Position and drawing is updated automatically based on the actions 
 * of the scroll view
 */

#import <Cocoa/Cocoa.h>
#import "OCConstants.h"

@class OCConstantsLib;

@interface OCRulerView : NSView {

	float zoomX;
	
	NSRect editorArea;
	
	int timeSignatureBasicBeat;
	int timeSignatureBeatsPerMeasure;
	
	int snapToValue;
	
	float basicBeatUnit;
	float measureUnit;	
	float snapToUnit;
	
}

#pragma mark -
#pragma mark Properties
@property (nonatomic) float zoomX;

@property (nonatomic) NSRect editorArea;

@property (nonatomic) int timeSignatureBasicBeat;
@property (nonatomic) int timeSignatureBeatsPerMeasure;

@property (nonatomic) int snapToValue;

- (void) boundsDidChangeNotification: (NSNotification *) notification;
- (float) pixelExact:(float)coordinate;

- (void) calculateValuesForDrawing;
@end
