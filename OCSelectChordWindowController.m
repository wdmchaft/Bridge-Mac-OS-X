//
//  OCSelectChordWindowController.m
//  Bridge
//
//  Created by Philip Regan on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCSelectChordWindowController.h"
#import "OCConstants.h"

#import "OCWindowController.h"

@implementation OCSelectChordWindowController

@synthesize windowController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's 
    // window has been loaded from its nib file.
}

- (void)initInterface
{    
    // Implement this method to handle any initialization after your window controller's 
    // window has been loaded from its nib file.

    // populate menus 
	[chordTypeMenu removeAllItems];
	[chordTypeMenu addItemWithTitle:kChordType_Major];
	[chordTypeMenu addItemWithTitle:kChordType_Minor];
	[chordTypeMenu addItemWithTitle:kChordType_Augmented];
	[chordTypeMenu addItemWithTitle:kChordType_Diminished];
	
	[chordModifierMenu removeAllItems];
	[chordModifierMenu addItemWithTitle:kChordModifer_Label_None];
	[chordModifierMenu addItemWithTitle:kChordModifer_Label_Suspended];
	[chordModifierMenu addItemWithTitle:kChordModifer_Label_Power];
	
	[extensionSeventhModifier removeAllItems];
	[extensionSeventhModifier addItemWithTitle:kChordExtension_Label_Major];
	[extensionSeventhModifier addItemWithTitle:kChordExtension_Label_Minor];
	[extensionSeventhModifier setEnabled:NO];
	
}

- (IBAction)setChordType:(id)sender {
	[windowController setChordType:sender];
}

- (IBAction)selectExtensionSeventh:(id)sender {
	if ( [sender state] == NSOnState ) {
		[extensionSeventhModifier setEnabled:YES];
	} else {
		[extensionSeventhModifier setEnabled:NO];
	}
	[windowController selectExtensionSeventh:sender];
}

- (IBAction)selectExtensionSeventhModifier:(id)sender {
	[windowController selectExtensionSeventhModifier:sender];
}

- (IBAction)selectChordModifier:(id)sender {
	[windowController selectChordModifier:sender];
}

@end
