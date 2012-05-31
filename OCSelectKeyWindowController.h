//
//  OCSelectKeyWindowController.h
//  Bridge
//
//  Created by Philip Regan on 2011/11/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Helps to manage user interaction within the window, mainly passing values from 
 the interface to the window controller.
*/

/*
 If there is a "standard Apple way" of doing this, I wasn't able to find it after 
 a day of searching and a lot of trial and error. Documentation in widely scattered
 and any issues surrounding handling issues are subtle and poorly documented. Knowing
 what I know about working with Cocoa, this isn't ideal, but this works, so I'm 
 running with it.
 */

#import <Cocoa/Cocoa.h>

@class OCWindowController;

@interface OCSelectKeyWindowController : NSWindowController {
    OCWindowController *windowController;
    IBOutlet NSPopUpButton *keyTonicMenu;
    IBOutlet NSPopUpButton *keyTypeMenu;
}

@property (assign) IBOutlet OCWindowController *windowController;

- (IBAction)setKeyTonic:(id)sender;
- (IBAction)setKeyType:(id)sender;
- (IBAction)okButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

- (void)initInterface;


@end

