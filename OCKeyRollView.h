//
//  OCKeyRollView.h
//  Bridge
//
//  Created by Philip Regan on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * This is the key "ruler" that sits to the left of the piano roll.
 */

#import <Cocoa/Cocoa.h>
#import "OCConstants.h"

@class OCConstantsLib;
@class OCMusicLib;
@class OCScrollView;
@class OCKeyObj;

@interface OCKeyRollView : NSView {
	
	OCKeyObj *keyObj;
	
	float zoomY;
	
	NSRect editorArea;
	
	float keyRollUnit;
}

#pragma mark -
#pragma mark Properties
#pragma mark -

@property (nonatomic) float zoomY;

@property (nonatomic) NSRect editorArea;
@property (nonatomic, readwrite, retain) OCKeyObj *keyObj;

#pragma mark -
#pragma mark Methods
#pragma mark -

//- (void) boundsChanged:(NSView *)contentView heightDifference:(float)theHeightDifference;

- (void) boundsDidChangeNotification: (NSNotification *) notification;

- (void) calculateValuesForDrawing;
@end
