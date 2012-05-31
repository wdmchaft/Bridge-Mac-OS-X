//
//  OCSelectChordWindowController.h
//  Bridge
//
//  Created by Philip Regan on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 This class is a simple passthrough for user selections back to the WindowController. It preps the interface as well.
 */

#import <Cocoa/Cocoa.h>

@class OCWindowController;

@interface OCSelectChordWindowController : NSWindowController {
	
	OCWindowController *windowController;
	
	IBOutlet NSPopUpButton *chordTypeMenu;
	IBOutlet NSButton *extensionSeventhCheck;
	IBOutlet NSPopUpButton *extensionSeventhModifier;
	IBOutlet NSPopUpButton *chordModifierMenu;
}

@property (assign) IBOutlet OCWindowController *windowController;

-(void)initInterface;

- (IBAction)setChordType:(id)sender;
- (IBAction)selectExtensionSeventh:(id)sender;
- (IBAction)selectExtensionSeventhModifier:(id)sender;
- (IBAction)selectChordModifier:(id)sender;

@end
