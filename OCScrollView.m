//
//  OCScrollView.m
//  OCDocumentFramework
//
//  Created by Philip Regan on 6/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * Managing class for the editing interfaces
 * OCView is managed directly by this class, particularly scrolling, and then 
 * updates the surrounding rulers as needed.
 */

#import "OCScrollView.h"

#import "OCView.h"
#import "OCRulerView.h"
#import "OCKeyRollView.h"

@implementation OCScrollView

@synthesize editorView;
@synthesize rulerView;
@synthesize keyRollView;

/*
 * tile is a NSScrollView supplied class for managing other views relative to 
 * the primary view, in this case OCView
 */

- (void)tile {
	[super tile];
	
	[rulerView setFrame:NSMakeRect([rulerView frame].origin.x, 
								   [rulerView frame].origin.y, 
								   [self frame].size.width + 16.0f, 
								   [rulerView frame].size.height)];
	
	[keyRollView setFrame:NSMakeRect([keyRollView frame].origin.x, 
									 [keyRollView frame].origin.y, 
									 [keyRollView frame].size.width, 
									 [self frame].size.height)];
	}

@end
