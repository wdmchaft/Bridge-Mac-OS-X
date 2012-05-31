//
//  OCConstants.h
//  Bridge
//
//  Created by Philip Regan on 7/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/* 
 * Values that are immutable across the application
 * OCConstants contains only core data type constants.
 * Anything requiring class methods of any kind need to be sent to OCConstantsLib
 */

#import <Cocoa/Cocoa.h>

// Note lengths are the core unit for music data.
// These values are used for everything from display calculations to music math (e.g., triplets) to writing MIDI files.
// If these values are to change, then they *must* be a multiple of 6.
typedef enum NoteLength
{
	kNoteLength_01 = 384,
	kNoteLength_02 = 192,
	kNoteLength_04 = 96,
	kNoteLength_08 = 48,
	kNoteLength_16 = 24,
	kNoteLength_32 = 12,
	kNoteLength_64 = 6,
} NoteLengths;

/*
 Settings for chords and keys are composed of two elements: integers and strings
 Integers are utilized with bit masks to store the variations.
 String are used to create the sequences of steps needed to create a chord or key
 Both objects call to here to verify and retrieve element values
 */

#pragma mark -
#pragma mark Chord Settings
#pragma mark -

extern char const kNoteSharp;
extern char const kNoteFlat;

enum chordType {
	kFlagChordType_Major, 
	kFlagChordType_Minor, 
	kFlagChordType_Diminished, 
	kFlagChordType_Augmented
};

extern NSString * const kChordType_Major;
extern NSString * const kChordType_Minor;
extern NSString * const kChordType_Augmented;
extern NSString * const kChordType_Diminished;


typedef enum OCChordModifier {
	kFlagChordModifer_None,
	kFlagChordModifier_Suspended, 
	kFlagChordModifier_Power
} OCChordModifier;

extern NSString * const kChordModifer_Label_None;
extern NSString * const kChordModifer_Label_Suspended;
extern NSString * const kChordModifer_Label_Power;

extern NSString * const kChordModifer_Suspended;
extern NSString * const kChordModifer_Suspended_Augmented;

enum chordExtension {
	kFLagChordExtension_NotSelected,
	kFlagChordExtension_Seventh, 
	kFlagChordExtension_Ninth, 
	kFlagChordExtension_Eleventh, 
	kFlagChordExtension_Sixth
};

enum chordExtensionModifier {
	kFlagChordExtensionModifier_Major, 
	kFlagChordExtensionModifier_Minor
} chordExtensionModifier;

extern NSString * const kChordExtension_Label_Major;
extern NSString * const kChordExtension_Label_Minor;

extern NSString * const kChordExtension_Seventh_Major;
extern NSString * const kChordExtension_Seventh_Minor;
extern NSString * const kChordExtension_Ninth_Major;
extern NSString * const kChordExtension_Ninth_Minor;
extern NSString * const kChordExtension_Eleventh_Major;
extern NSString * const kChordExtension_Eleventh_Minor;
extern NSString * const kChordExtension_Sixth_Major;
extern NSString * const kChordExtension_Sixth_Minor;


#pragma mark -
#pragma mark Key Settings
#pragma mark -

enum keyTonic {
	kFlagKeyType_C, 
	kFlagKeyType_CsharpDflat, 
	kFlagKeyType_D, 
	kFlagKeyType_DsharpEflat, 
	kFlagKeyType_E, 
	kFlagKeyType_F, 
	kFlagKeyType_FsharpGflat, 
	kFlagKeyType_G, 
	kFlagKeyType_GsharpAFlat,
	kFlagKeyType_A, 
	kFlagKeyType_AsharpBflat, 
	kFlagKeyType_B
};

extern NSString * const kKeyType_C; 
extern NSString * const kKeyType_CsharpDflat; 
extern NSString * const kKeyType_D; 
extern NSString * const kKeyType_DsharpEflat; 
extern NSString * const kKeyType_E; 
extern NSString * const kKeyType_F; 
extern NSString * const kKeyType_FsharpGflat; 
extern NSString * const kKeyType_G; 
extern NSString * const kKeyType_GsharpAFlat;
extern NSString * const kKeyType_A; 
extern NSString * const kKeyType_AsharpBflat; 
extern NSString * const kKeyType_B;

enum keyType {
	kFlagKeyMod_Major, 
	kFlagKeyMod_Minor, 
	kFlagKeyMod_MinorHarmonic, 
	kFlagKeyMod_MinorMelodic, 
	kFlagKeyMod_PentatonicMajor, 
	kFlagKeyMod_PentatonicMinor
};

extern NSString * const kKeyMajor;
extern NSString * const kKeyMinor;
extern NSString * const kKeyMinorHarmonic;
extern NSString * const kKeyMinorMelodic;
extern NSString * const kKeyPentatonicMajor;
extern NSString * const kKeyPentatonicMinor;

@interface OCConstants : NSObject {	
	
}

#define OCTAVE_COUNT 12

#pragma mark MIDI Constants

extern int const kOCMIDI_StandardNoteCount;
extern int const kOCMIDI_StandardNoteMin;
extern int const kOCMIDI_StandardNoteMax;

#pragma mark Drawing Constants

// the note length divisor is used by the window controller to properly display note lengths in a non-MIDI format.
extern int const kOCData_NoteLengthDivisor;

extern int const kOCView_DefaultNoteLength;

// The pixel buffer is used to create display objects in the OCView.
// This value is multiplied by the NoteLengths to create a object whose width is easily clickable
// There are no restrictions on this value (e.g., must be a multiple of n like with note length).
extern float const kOCView_PixelBuffer;

// The Core Key Height is the unit of measure for the height of the key roll and note objects in the editor.
// this value must be a multiple of 6
extern float const kOCView_CoreKeyHeight;

extern float const kOCModel_DefaultNumberOfMeasures;

#pragma mark Interface Constants

typedef enum EditorMode
{
    kAddMode,
    kEditMode,
    kDeleteMode
} EditorModes;

typedef enum OCMouseMode
{
	kOCNoMode,
	kOCResizeMode,
	kOCDragSelectMode
} OCMouseMode;



@end
