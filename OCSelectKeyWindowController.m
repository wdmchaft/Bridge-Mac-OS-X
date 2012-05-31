//
//  OCSelectKeyWindowController.m
//  Bridge
//
//  Created by Philip Regan on 2011/11/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCSelectKeyWindowController.h"

#import "OCWindowController.h"
#import "OCConstants.h"

@implementation OCSelectKeyWindowController
@synthesize windowController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    
    return self;
}

- (void)initInterface
{    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [keyTonicMenu removeAllItems];
    [keyTonicMenu addItemWithTitle:kKeyType_C];
    [keyTonicMenu addItemWithTitle:kKeyType_CsharpDflat];
    [keyTonicMenu addItemWithTitle:kKeyType_D];
    [keyTonicMenu addItemWithTitle:kKeyType_DsharpEflat];
    [keyTonicMenu addItemWithTitle:kKeyType_E];
    [keyTonicMenu addItemWithTitle:kKeyType_F];
    [keyTonicMenu addItemWithTitle:kKeyType_FsharpGflat];
    [keyTonicMenu addItemWithTitle:kKeyType_G];
    [keyTonicMenu addItemWithTitle:kKeyType_GsharpAFlat];
    [keyTonicMenu addItemWithTitle:kKeyType_A];
    [keyTonicMenu addItemWithTitle:kKeyType_AsharpBflat];
    [keyTonicMenu addItemWithTitle:kKeyType_B];
    
    [keyTypeMenu removeAllItems];
    [keyTypeMenu addItemWithTitle:kKeyMajor];
    [keyTypeMenu addItemWithTitle:kKeyMinor];
    [keyTypeMenu addItemWithTitle:kKeyMinorHarmonic];
    [keyTypeMenu addItemWithTitle:kKeyMinorMelodic];
    [keyTypeMenu addItemWithTitle:kKeyPentatonicMajor];
    [keyTypeMenu addItemWithTitle:kKeyPentatonicMinor];
    
}

- (IBAction)setKeyTonic:(id)sender {
    [windowController setKeyTonic:sender];
}

- (IBAction)setKeyType:(id)sender {
    [windowController setKeyType:sender];
}

- (IBAction)okButton:(id)sender {
    [windowController keyOkButton:sender];
}

- (IBAction)cancelButton:(id)sender {
    [windowController keyCancelButton:sender];
}
@end
