//
//  OCScrollView.h
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

#import <Cocoa/Cocoa.h>
#import "OCConstants.h"

@class OCView;
@class OCRulerView;
@class OCKeyRollView;

@interface OCScrollView : NSScrollView {

	IBOutlet OCView *editorView;
	OCRulerView *rulerView;
	OCKeyRollView *keyRollView;
		
}

@property (nonatomic, retain) IBOutlet OCView *editorView;
@property (nonatomic, retain) OCRulerView *rulerView;
@property (nonatomic, retain) OCKeyRollView *keyRollView;

@end
