//
//  OCRulerView.m
//  Bridge
//
//  Created by Philip Regan on 6/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OCRulerView.h"

#import "OCConstantsLib.h"

@implementation OCRulerView

#pragma mark -
#pragma mark Properties
@synthesize zoomX;

@synthesize editorArea;

@synthesize timeSignatureBasicBeat;
@synthesize timeSignatureBeatsPerMeasure;

@synthesize snapToValue;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        zoomX = 1.0f;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    
    // clear the background
    
    [[NSColor whiteColor] set];
	NSRectFill(rect);
	
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	// measure line
	
	NSBezierPath *measureLine = [NSBezierPath bezierPath];
	
	int firstMeasureLine = 0;
	int currentMeasureLine = 0;
	int lastMeasureLine = NSMaxX(self.editorArea);
	
	for (currentMeasureLine = firstMeasureLine; currentMeasureLine <= lastMeasureLine; currentMeasureLine += measureUnit) {
		
		NSPoint startPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentMeasureLine], [[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
		NSPoint endPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentMeasureLine], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(rect)]);
		
		[measureLine moveToPoint:startPoint];
		[measureLine lineToPoint:endPoint];
		
		NSPoint labelPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentMeasureLine] + 3.0f, [[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
		NSString *measureLabel = [NSString stringWithFormat:@"%i", (currentMeasureLine / (int)measureUnit) + 1];
		[measureLabel drawAtPoint:labelPoint withAttributes:nil];
		
	}
	
	[[NSColor blackColor] set];
	[measureLine setLineWidth:1.0];
	[measureLine stroke];
	
	// snap to line
	
	NSBezierPath *snapToLine = [NSBezierPath bezierPath];
	
	int firstSnapToLine = 0;
	int currentSnapToLine = 0;
	int lastSnapToLine = NSMaxX(self.editorArea);
	
	for (currentSnapToLine = firstSnapToLine; currentSnapToLine <= lastSnapToLine; currentSnapToLine += snapToUnit) {
		
		NSPoint startPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentSnapToLine], [[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
		NSPoint endPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentSnapToLine], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(rect) / 3.0f]);
		
		[snapToLine moveToPoint:startPoint];
		[snapToLine lineToPoint:endPoint];
		
	}
	
	[[NSColor lightGrayColor] set];
	[snapToLine setLineWidth:1.0];
	[snapToLine stroke];
		
	// basic beat line
	
	NSBezierPath *basicBeatLine = [NSBezierPath bezierPath];
	
	int firstbasicBeatLine = 0;
	int currentbasicBeatLine = 0;
	int lastbasicBeatLine = NSMaxX(self.editorArea);
	
	for (currentbasicBeatLine = firstbasicBeatLine; currentbasicBeatLine <= lastbasicBeatLine; currentbasicBeatLine += basicBeatUnit) {
		
		NSPoint startPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentbasicBeatLine], [[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
		NSPoint endPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:currentbasicBeatLine], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(rect) / 2.0f]);
		
		[basicBeatLine moveToPoint:startPoint];
		[basicBeatLine lineToPoint:endPoint];
		
	}
	
	[[NSColor darkGrayColor] set];
	[basicBeatLine setLineWidth:1.0];
	[basicBeatLine stroke];
	
	// outline

	NSBezierPath *outline = [NSBezierPath bezierPath];
	
	// {0, 0}, {x, 0}, {x, y}, {0, y}
	
	NSPoint topLeftPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMinX(rect)], [[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
	NSPoint topRightPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(rect) - 1.0f], [[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
	NSPoint bottomRightPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(rect) - 1.0f], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(rect) - 1.0f]);
	NSPoint bottomLeftPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMinX(rect)], [[OCConstantsLib sharedLib] pixelExact:NSMaxY(rect) - 1.0f]);

	[outline moveToPoint:topLeftPoint];
	[outline lineToPoint:topRightPoint];
	[outline lineToPoint:bottomRightPoint];
	[outline lineToPoint:bottomLeftPoint];
	[outline lineToPoint:topLeftPoint];
	
	[[NSColor blackColor] set];
	[outline setLineWidth:1.0];
	[outline stroke];
	
}

/*
 Apple-supplied method
 */

- (BOOL) isFlipped {
	return NO;
}

/*
 Apple-supplied method
 */

- (void) boundsDidChangeNotification: (NSNotification *) notification
{
	NSView *changedContentView = [notification object];
	NSPoint changedBoundsOrigin = [changedContentView bounds].origin;
	[self setBounds:NSMakeRect(changedBoundsOrigin.x - 30.0f, [self bounds].origin.y, [self bounds].size.width, [self bounds].size.height)];
}

/*
 Originally placed here to ensure lines are drawn clearly, but moved to OCConstants for better code reuse. What should happen, however, is all
 of the views that need pixel exact drawing should inherit from a common superclass containing this method.
 */

- (float) pixelExact:(float)coordinate {
	return floorf(coordinate) + 0.5f;
}

/*
 Called by the window controller to ensure that the piano roll is up to date before drawing the data.
 */
- (void) calculateValuesForDrawing {
	basicBeatUnit = (float)timeSignatureBasicBeat * zoomX;
	measureUnit = (float)timeSignatureBasicBeat * (float)timeSignatureBeatsPerMeasure * zoomX;
	snapToUnit = (float)snapToValue * zoomX;
}

@end
