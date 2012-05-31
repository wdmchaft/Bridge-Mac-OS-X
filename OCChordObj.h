//
//  OCChordObj.h
//  Bridge
//
//  Created by Philip Regan on 2011/11/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCGroupObj.h"

#import "OCConstants.h"
#import "OCMusicLib.h"

@class MyDocument;
@class OCMusicPieceObj;
@class OCKeyObj;
@class OCNoteObj;

#define MAX_STEPS 6
// 1 (b)3 (#)5 (6||(b)7) (b)9 (b)11

@interface OCChordObj : OCGroupObj {
    
    MyDocument *myDocument;
    // this kind of breaks MVC, but since we want the logic of the pitch selection
    // to be encapsulated in the chord, and they are both data classes, it is easier
    // to make an exception than it is to try and manage crosstalk between the two.
    
    // contains all of the variations needed to build this chord.
    int chordTypeSelection;
    int chordModifierSelection;
    int chordExtensionSeventhSelection;
    int chordExtensionSeventhModifierSelection;
    
}

@property (nonatomic, retain) MyDocument *myDocument;

@property (readwrite) int chordTypeSelection;
@property (readwrite) int chordModifierSelection;
@property (readwrite) int chordExtensionSeventhSelection;
@property (readwrite) int chordExtensionSeventhModifierSelection;

- (void)calculatePitches;

- (NSString *)getChordTypeFromSelection:(int)selection;
- (OCChordModifier)getChordModifierFromSelection:(int)selection;
- (int)getChordExtensionSeventhSelection:(int)selection;
- (int)getchordExtensionSeventhModifierSelection:(int)selection;
@end
