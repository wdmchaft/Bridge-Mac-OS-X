//
//  OCKeyRollView.m
//  Bridge
//
//  Created by Philip Regan on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OCKeyRollView.h"

#import "OCConstantsLib.h"
#import "OCMusicLib.h"
#import "OCScrollView.h"
#import "OCWindowController.h"
#import "OCKeyObj.h"

float const defaultFirstContentViewHeight = -1;
float const defaultScrollBarHeight = 15.0;

@implementation OCKeyRollView

#pragma mark -
#pragma mark Properties
#pragma mark -

@synthesize zoomY;

@synthesize editorArea;
@synthesize keyObj;

#pragma mark -
#pragma mark Class Methods
#pragma mark -

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		zoomY = 1.0f;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];

    [[NSColor whiteColor] set];
	NSRectFill(rect);
	
	NSBezierPath *keyRollLine = [NSBezierPath bezierPath];
		
	int firstKeyRollLine = NSMinY(self.editorArea);
	int currentKeyRollLine = 0;
	int lastKeyRollLine = NSMaxY(self.editorArea);
	
	for (currentKeyRollLine = firstKeyRollLine; currentKeyRollLine <= lastKeyRollLine; currentKeyRollLine += keyRollUnit) {
		
		// get the far-left and far-right points
		
		NSPoint startPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMinX(self.editorArea)], 
										 [[OCConstantsLib sharedLib] pixelExact:currentKeyRollLine]);
		
		NSPoint endPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(self.editorArea)], 
									   [[OCConstantsLib sharedLib] pixelExact:currentKeyRollLine]);
		
		// draw the key divider line
		
		[keyRollLine moveToPoint:startPoint];
		[keyRollLine lineToPoint:endPoint];
		
		// draw the black key if needed
		
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
		
		// draw the key marker if in key
		
		if ( [keyObj isPitchInKey:currentKeyRollLine / keyRollUnit] ) {
			NSBezierPath *keyMark = [NSBezierPath bezierPath];
			
			NSPoint bottomLeft = startPoint;
			NSPoint bottomRight = endPoint;
			NSPoint topRight = NSMakePoint(bottomRight.x, (float)currentKeyRollLine + keyRollUnit);
			NSPoint topLeft = NSMakePoint(bottomLeft.x, topRight.y);
			
			[keyMark moveToPoint:bottomLeft];
			[keyMark lineToPoint:bottomRight];
			[keyMark lineToPoint:topRight];
			[keyMark lineToPoint:topLeft];
			[keyMark lineToPoint:bottomLeft];
			
			NSColor *inKeyMarker = [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.25];
			[inKeyMarker set];
			[keyMark fill];
		}
		
		// draw the pitch number itself
		
		NSPoint labelPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:2.0f], 
										 [[OCConstantsLib sharedLib] pixelExact:currentKeyRollLine]);
		
		NSString *noteLabel = [NSString stringWithFormat:@"%i", (currentKeyRollLine / (int)keyRollUnit)];
		[noteLabel drawAtPoint:labelPoint withAttributes:nil];
		
	}
	
	[[NSColor blackColor] set];
	[keyRollLine setLineWidth:1.0];
	[keyRollLine stroke];	
	
	// outline
	
	NSBezierPath *outline = [NSBezierPath bezierPath];
	
	NSPoint topLeftPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMinX(rect)], 
									   [[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
	
	NSPoint topRightPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(rect) - 1.0f], 
										[[OCConstantsLib sharedLib] pixelExact:NSMinY(rect)]);
	
	NSPoint bottomRightPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMaxX(rect) - 1.0f], 
										   [[OCConstantsLib sharedLib] pixelExact:NSMaxY(rect) - 1.0f]);
	
	NSPoint bottomLeftPoint = NSMakePoint([[OCConstantsLib sharedLib] pixelExact:NSMinX(rect)], 
										  [[OCConstantsLib sharedLib] pixelExact:NSMaxY(rect) - 1.0f]);
	
	[outline moveToPoint:bottomLeftPoint];
	[outline lineToPoint:topLeftPoint];
	[outline lineToPoint:topRightPoint];
	[outline lineToPoint:bottomRightPoint];
	 
	[[NSColor blackColor] set];
	[outline setLineWidth:1.0];
	[outline stroke];
		
}

- (BOOL) isFlipped {
	return NO;
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (void) boundsDidChangeNotification: (NSNotification *) notification {
	
	NSView *changedContentView = [notification object];
	
	float selfBoundsX = [self bounds].origin.x;
	float selfBoundsWidth = [self bounds].size.width;
	
	float contentBoundsY = [changedContentView bounds].origin.y;
	float contentBoundsHeight = [changedContentView bounds].size.height;
			
	[self setBounds:NSMakeRect(selfBoundsX, 
							   contentBoundsY - defaultScrollBarHeight, 
							   selfBoundsWidth, 
							   contentBoundsHeight + defaultScrollBarHeight)];
}


- (void) calculateValuesForDrawing {
	keyRollUnit = kOCView_CoreKeyHeight * zoomY;
}

@end
