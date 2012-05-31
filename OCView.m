//
//  OCView.m
//  OCDocumentFramework
//
//  Created by Philip Regan on 2/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * This is the core Piano Roll interface where most editing takes place.
 * This class is designed to intercept user actions and push needed data to the 
 * WindowController which is responsible for the actual music data.
 * This class primarily handles mouse events and drawing, and should not actually
 * manipulate data.
 */

#import "OCView.h"

#import "OCConstantsLib.h"
#import "OCMusicLib.h"

#import "OCWindowController.h"

#import "OCNoteObj.h"
#import "OCGroupObj.h"
#import "OCChordObj.h"
#import "OCSequenceObj.h"
#import "OCResizeTabObj.h"

@implementation OCView

@synthesize windowController;

@synthesize zoomX;
@synthesize zoomY;

@synthesize editorArea;

@synthesize timeSignatureBasicBeat;
@synthesize timeSignatureBeatsPerMeasure;

@synthesize snapToValue;

@synthesize mouseDownPoint;
@synthesize lastDragPoint;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		zoomX = 1.0f;
		zoomY = 1.0f;
		
		snapToValue = kOCView_DefaultNoteLength;
		timeSignatureBasicBeat = kOCView_DefaultNoteLength;
		timeSignatureBeatsPerMeasure = 4;
        
        mouseMode = kOCNoMode;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	// Clear background
	
    [[NSColor whiteColor] set];
	NSRectFill(rect);
	
	// Background Key Roll lines
    // For each line type, we use one Bezier path for all lines to save memory and 
    // speed up drawing
	
	NSBezierPath *keyRollLine = [NSBezierPath bezierPath];
	
	int firstKeyRollLine = 0;
	int currentKeyRollLine = 0;
	int lastKeyRollLine = NSMaxY(self.editorArea);
	
	for (currentKeyRollLine = firstKeyRollLine; currentKeyRollLine <= lastKeyRollLine; currentKeyRollLine += keyRollUnit) {
		
		NSPoint startPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMinX(self.editorArea)], [[OCConstantsLib sharedLib] pixelExact:currentKeyRollLine]);
		NSPoint endPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(self.editorArea)], [[OCConstantsLib sharedLib] pixelExact:currentKeyRollLine]);
		
		[keyRollLine moveToPoint:startPoint];
		[keyRollLine lineToPoint:endPoint];
		
		// draw the black key background if needed
        // This is a filled rect as opposed to a simple line.
		
		BOOL blackKeyFlag = [[OCMusicLib sharedLib] isBlackKey:currentKeyRollLine / keyRollUnit];
		if (blackKeyFlag) {
			
			NSBezierPath *blackKey = [NSBezierPath bezierPath];
			
			NSPoint bottomLeft = startPoint;
			NSPoint bottomRight = endPoint;
			NSPoint topRight = NSMakePoint(bottomRight.x, (float)currentKeyRollLine + keyRollUnit);
			NSPoint topLeft = NSMakePoint(bottomLeft.x, topRight.y);
			
			[blackKey moveToPoint:bottomLeft];
			[blackKey lineToPoint:bottomRight];
			[blackKey lineToPoint:topRight];
			[blackKey lineToPoint:topLeft];
			[blackKey lineToPoint:bottomLeft];
			
			[[NSColor lightGrayColor] set];
			[blackKey fill];
			
		}
		
	}
	
	[[NSColor grayColor] set];
	[keyRollLine setLineWidth:1.0];
	[keyRollLine stroke];	

	// SnapTo Lines
	
	NSBezierPath *snapToLine = [NSBezierPath bezierPath];
	
	int firstSnapToLine = 0;
	int currentSnapToLine = 0;
	int lastSnapToLine = NSMaxX(self.editorArea);
		
	for (currentSnapToLine = firstSnapToLine; currentSnapToLine <= lastSnapToLine; currentSnapToLine += snapToUnit) {
		
		NSPoint startPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentSnapToLine], [[OCConstantsLib sharedLib] pixelExact:NSMinY(self.editorArea)]);
		NSPoint endPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentSnapToLine], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(self.editorArea)]);
		
		[snapToLine moveToPoint:startPoint];
		[snapToLine lineToPoint:endPoint];
		
	}
	
	[[NSColor whiteColor] set];
	[snapToLine setLineWidth:1.0];
	[snapToLine stroke];
    
    // Measure Lines
    
	NSBezierPath *measureLine = [NSBezierPath bezierPath];
	
	int firstMeasureLine = measureUnit;
	int currentMeasureLine = 0;
	int lastMeasureLine = NSMaxX(self.editorArea);

	for (currentMeasureLine = firstMeasureLine; currentMeasureLine <= lastMeasureLine; currentMeasureLine += measureUnit) {
		
		NSPoint startPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentMeasureLine], [[OCConstantsLib sharedLib] pixelExact:NSMinY(self.editorArea)]);
		NSPoint endPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentMeasureLine], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(self.editorArea)]);
		
		[measureLine moveToPoint:startPoint];
		[measureLine lineToPoint:endPoint];
		
	}
	
	[[NSColor darkGrayColor] set];
	[measureLine setLineWidth:1.0];
	[measureLine stroke];
	
	// Start and Stop lines (left and right borders)
	
	NSPoint startStopLinePoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(self.editorArea)], [[OCConstantsLib sharedLib] pixelExact:NSMinY(self.editorArea)]);
	NSPoint endStopLinePoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(self.editorArea)], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(self.editorArea)]);
	NSBezierPath *stopLine = [NSBezierPath bezierPath];
	[stopLine moveToPoint:startStopLinePoint];
	[stopLine lineToPoint:endStopLinePoint];
	[[NSColor blackColor] set];
	[stopLine setLineWidth:1.0];
	[stopLine stroke];
	
	// Draw music objects
    // Objects are drawn from the bottom up
	
	// color prep; (n/255.0) for easy conversion from RGB values.
    
	NSColor *groupFillUnselectedColor = [NSColor colorWithCalibratedRed:(255.0/255.0) green:(204.0/255.0) blue:(0.0/255.0) alpha:0.15];
	NSColor *groupFillSelectedColor = [NSColor colorWithCalibratedRed:(255.0/255.0) green:(102.0/255.0) blue:(0.0/255.0) alpha:0.15];
	
	NSColor *noteFillUnselectedColor = [NSColor colorWithCalibratedRed:(255.0/255.0) green:(204.0/255.0) blue:(0.0/255.0) alpha:1.0];
	NSColor *noteFillSelectedColor = [NSColor colorWithCalibratedRed:(255.0/255.0) green:(102.0/255.0) blue:(0.0/255.0) alpha:1.0];
    
    NSColor *resizeTabColor = [NSColor colorWithCalibratedRed:(255.0/255.0) green:(102.0/255.0) blue:(0.0/255.0) alpha:0.5];
    
    // Sequences
    
	if ( [[windowController sequences] count] > 0 ) {
		for ( OCSequenceObj *sequence in [windowController sequences] ) {
			
			NSRect bounds = [self calculateRectFromSequence:sequence];
			
			NSBezierPath *outline = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:8.0 yRadius:8.0];
			[outline setLineWidth:2.0];
			double lineDash[2];
			lineDash[0] = 4.0;
			lineDash[1] = 4.0;
			[outline setLineDash:lineDash count:1.0 phase:0.0];
			
			// now that the bounds are calculated, draw the objects
			if ( sequence.selected ) {
				// fill
				[groupFillSelectedColor set];
				[outline fill];
				// stroke
				[noteFillSelectedColor set];
				[outline stroke];
				
				// show the resize tab since the object is selected
				NSRect tabRect = [self calculateResizeTabRectFromRect:bounds];
				NSBezierPath *tab = [NSBezierPath bezierPathWithRoundedRect:tabRect xRadius:8.0 yRadius:8.0];
				[resizeTabColor set];
				[tab fill];
				
			} else {
				// fill
				[groupFillUnselectedColor set];
				[outline fill];
				// stroke
				[noteFillUnselectedColor set];
				[outline stroke];
			}
		}
	}
	
	// Groups
	// We are only drawing the bounds of the group and not all of the children since
    // that is handled in subsequent groups
	if ( [[windowController groups] count] > 0 ) {
		for ( OCGroupObj *group in [windowController groups] ) {
			
			if ( [group.objects count] > 0 ) {
				NSRect bounds = [self calculateRectFromGroup:group];
				
				NSBezierPath *outline = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:8.0 yRadius:8.0];
				
				// now that the bounds are calculated, draw the objects
				if (group.selected) {
					// fill
					[groupFillSelectedColor set];
					[outline fill];
					// stroke
					[noteFillSelectedColor set];
					[outline stroke];
				} else {
					// fill
					[groupFillUnselectedColor set];
					[outline fill];
					// stroke
					[noteFillUnselectedColor set];
					[outline stroke];
				}
			}
		}
	}
		
	// Chords
	// Handled similarly to groups
	if ( [[windowController chords] count] > 0 ) {
		for ( OCChordObj *chord in [windowController chords] ) {
			
			NSRect bounds = [self calculateRectFromChord:chord];
			
			// now that the bounds are calculated, draw the objects
			if (chord.selected) {
				// fill
				[groupFillSelectedColor set];
				[NSBezierPath fillRect:bounds];
				// stroke
				[noteFillSelectedColor set];
				[NSBezierPath strokeRect:bounds];
			} else {
				// fill
				[groupFillUnselectedColor set];
				[NSBezierPath fillRect:bounds];
				// stroke
				[noteFillUnselectedColor set];
				[NSBezierPath strokeRect:bounds];
			}
		}
	}
	    
    // Notes
	if ( [[windowController notes] count] > 0 ) {
		for (OCNoteObj *note in [windowController notes]) {
			
			NSRect bounds = [self calculateRectFromNote:note];
			
			// fill
			if (note.selected) {
				[noteFillSelectedColor set];
				[NSBezierPath fillRect:bounds];
				
				// show the resize tab since the object is selected
				NSRect tabRect = [self calculateResizeTabRectFromRect:bounds];
				NSBezierPath *tab = [NSBezierPath bezierPathWithRoundedRect:tabRect xRadius:8.0 yRadius:8.0];
				[resizeTabColor set];
				[tab fill];
				
				
			} else {
				[noteFillUnselectedColor set];
				[NSBezierPath fillRect:bounds];
			}
			
			// stroke
			[[NSColor blackColor] set];
			[NSBezierPath strokeRect:bounds];
		}
	}
	
	if ( mouseMode == kOCDragSelectMode ) {
		NSRect bounds = NSMakeRect(dragBoundX, dragBoundY, dragBoundW, dragBoundH);
		// stroke
		[[NSColor blackColor] set];
		[NSBezierPath strokeRect:bounds];
	}
}

/*
 Apple's supplied method
 */

- (BOOL) isFlipped {
	return NO;
}

#pragma mark -
#pragma mark Drawing Calculations
#pragma mark -

- (void) calculateValuesForDrawing {
	snapToUnit = (float)snapToValue * zoomX;
	measureUnit = (float)timeSignatureBasicBeat * (float)timeSignatureBeatsPerMeasure * zoomX;
	keyRollUnit = kOCView_CoreKeyHeight * zoomY;
}

- (NSRect) calculateRectFromNote:(OCNoteObj *)note {
	
	// we calculate this as pixel-accurate to be sure that we are starting off on the right foot.
	float x = [[OCConstantsLib sharedLib] pixelExact:note.startBeat * zoomX];
	float y = [[OCConstantsLib sharedLib] pixelExact:note.pitch * keyRollUnit];
    float w = note.length * zoomX;
	float h = keyRollUnit;
	
	NSRect bounds = NSMakeRect(x, y, w, h);
	return bounds;
	
}

/*
 The calculateRectFromObjectMethods translate the object's beats and pitches into
 pixels drawRect: can use to draw the object
 */

- (NSRect) calculateRectFromGroup:(OCGroupObj *)group {
	
    // all grouping object return the outermost dimensions for all child objects
	NSRect musicBounds = [group dimensions];
    
    // primary differentiator between groups and chords
    float padding = 4.0;
    
    // size
    float w = ( musicBounds.size.width * zoomX ) + ( padding * 2 );
	float h = ( ( musicBounds.size.height + 1 ) * keyRollUnit ) + ( padding * 2 ) ;
	
    // origin
	float x = [[OCConstantsLib sharedLib] pixelExact:( musicBounds.origin.x * zoomX ) - padding];
	float y = [[OCConstantsLib sharedLib] pixelExact:( musicBounds.origin.y * keyRollUnit ) - padding ];
	
	NSRect bounds = NSMakeRect(x, y, w, h);
	return bounds;
}

- (NSRect) calculateRectFromChord:(OCChordObj *)chord {
	
	NSRect musicBounds = [chord dimensions];
    
    float padding = 1.0;
    
    float w = ( musicBounds.size.width * zoomX ) + ( padding * 2 );
	float h = ( ( musicBounds.size.height + 1 ) * keyRollUnit ) + ( padding * 2 ) ;
	
	float x = [[OCConstantsLib sharedLib] pixelExact:( musicBounds.origin.x * zoomX ) - padding];
	float y = [[OCConstantsLib sharedLib] pixelExact:( musicBounds.origin.y * keyRollUnit ) - padding ];
	
	NSRect bounds = NSMakeRect(x, y, w, h);
	return bounds;
}

- (NSRect) calculateRectFromSequence:(OCSequenceObj *)sequence {
    
    NSRect musicBounds = [sequence dimensions];
    
    float padding = 6.0;
    
    float w = ( musicBounds.size.width * zoomX ) + ( padding * 2 );
	float h = ( ( musicBounds.size.height + 1 ) * keyRollUnit ) + ( padding * 2 ) ;
	
	float x = [[OCConstantsLib sharedLib] pixelExact:( musicBounds.origin.x * zoomX ) - padding];
	float y = [[OCConstantsLib sharedLib] pixelExact:( musicBounds.origin.y * keyRollUnit ) - padding ];
	
	NSRect bounds = NSMakeRect(x, y, w, h);
	return bounds;

}

#pragma mark Resize Tab Calculations

/*
 This calculates the placement of a rect relative to the passed rect sourced from
 an object.
 */

- (NSRect) calculateResizeTabRectFromRect:(NSRect)rect {
    
    float x = [[OCConstantsLib sharedLib] pixelExact:rect.origin.x + rect.size.width];
    float y = [[OCConstantsLib sharedLib] pixelExact:rect.origin.y];
    float w = [[OCConstantsLib sharedLib] pixelExact:kNoteLength_16];
    float h = -1.0;
	if ( rect.size.height > 1.0 ) {
		h = [[OCConstantsLib sharedLib] pixelExact:rect.size.height];
	} else {
		h = [[OCConstantsLib sharedLib] pixelExact:rect.origin.y];
	}
    
    NSRect tabRect = NSMakeRect(x, y, w, h);
    return tabRect;
}

#pragma mark -
#pragma mark Mouse Events
#pragma mark -

/*
 * Primarily facilitates object selection. Selection algorithms are held entirely 
 * in WindowController 
 */

- (void)mouseDown:(NSEvent *)theEvent {
    //NSLog(@"OCView:mouseDown");
    // get the location the mouse was clicked
    // this is a common pattern Apple presents as being the way to translate 
    // a mouse click into pixels we can use.
	
    mouseDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // save the location in case of a future drag operation
    lastDragPoint = mouseDownPoint;
    
    // calculate the the beat and pitch clicked in to
    float clickBeat = floor( mouseDownPoint.x / zoomX );
    float clickPitch = floor( mouseDownPoint.y / keyRollUnit );
    
	if ( self.windowController.editorMode == kAddMode ) {
		[windowController createNoteAtBeat:(float)clickBeat 
									 pitch:(float)clickPitch];
	}
	
	if ( self.windowController.editorMode == kEditMode ) {
		mouseMode = [windowController selectNoteAtBeat:clickBeat 
									 pitch:clickPitch 
								  modifier:([theEvent modifierFlags] & NSShiftKeyMask)];
	}
	
    if ( self.windowController.editorMode == kDeleteMode ) {
		[windowController deleteNoteAtBeat:clickBeat 
									 pitch:clickPitch];
	}
    
    [windowController setOldData];
    
    // update the interface
    [windowController updateViews];
    
}

/*
 * Primarily facilitates object selection and editing by dragging
 */

- (void)mouseDragged:(NSEvent *)theEvent {
    
	NSPoint currentDragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	int deltaXinPixels = floor( currentDragPoint.x - mouseDownPoint.x );
	int deltaXinBeats = floor( deltaXinPixels / zoomX );
	int deltaX = floor( deltaXinBeats / snapToValue ) * snapToValue;
	
	int deltaYinPixels = floor( currentDragPoint.y - mouseDownPoint.y );
	int deltaY = floor( deltaYinPixels / keyRollUnit / zoomY );
	
	if ( self.windowController.editorMode == kEditMode ) {
		
		// tell the WindowController to update the objects based on the editing mode
		
		if ( mouseMode == kOCResizeMode ) {
			// we need to manage how many times this needs to be sent to the 
			// objects that need to know
			if ( ( deltaX != lastDeltaX ) && ( deltaX % snapToValue == 0 ) ) {
				[windowController changeLengthOfSelectionByDeltaX:deltaXinBeats];
			}
			
		} else if ( mouseMode == kOCDragSelectMode ) {
			
			dragBoundX = floor(MIN(currentDragPoint.x, mouseDownPoint.x));
			dragBoundY = floor(MIN(currentDragPoint.y, mouseDownPoint.y));
			dragBoundW = deltaXinPixels;
			dragBoundH = deltaYinPixels;
			
		} else if ( mouseMode == kOCNoMode ) {
			
			[windowController moveSelectionDeltaX:deltaX DeltaY:deltaY];
		}
		
	}
	
	// update the pointer location
	lastDragPoint = currentDragPoint;
	lastDeltaX = deltaX;
	
	// update the interface
	[self autoscroll:theEvent];
	[windowController updateViews];
	
}

/*
 * Primarily facilitates triggering certain functionality based on edit mode and 
 * type of object being edited.
 */

- (void)mouseUp:(NSEvent *)theEvent {
    mouseMode = kOCNoMode;
}

@end
