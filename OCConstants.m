//
//  OCConstants.m
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

#import "OCConstants.h"


@implementation OCConstants

#pragma mark MIDI Constants

int const kOCMIDI_StandardNoteCount = 128;
int const kOCMIDI_StandardNoteMin = 0;
int const kOCMIDI_StandardNoteMax = 127;

#pragma mark Drawing Constants

int const kOCData_NoteLengthDivisor = 6;

int const kOCView_DefaultNoteLength = kNoteLength_08;

float const kOCView_PixelBuffer = 2.0f;

float const kOCView_CoreKeyHeight = 24.0f; // Range: 2.4 px - 384.0 px

float const kOCModel_DefaultNumberOfMeasures = 8.0f;

#pragma mark -
#pragma mark Chord Settings
#pragma mark -

char const kNoteSharp = '#';
char const kNoteFlat = 'b';

NSString * const kChordType_Major = @"Major=1 3 5";
NSString * const kChordType_Minor = @"Minor=1 b3 5";
NSString * const kChordType_Augmented = @"Augmented=1 3 #5";
NSString * const kChordType_Diminished = @"Diminished=1 b3 b5";

NSString * const kChordModifer_Label_None = @"None";
NSString * const kChordModifer_Label_Suspended = @"Suspended";
NSString * const kChordModifer_Label_Power = @"Power";

NSString * const kChordModifer_Suspended = @"4";
NSString * const kChordModifer_Suspended_Augmented = @"b4";

NSString * const kChordExtension_Label_Major = @"Major";
NSString * const kChordExtension_Label_Minor = @"Minor";

NSString * const kChordExtension_Seventh_Major = @"7";
NSString * const kChordExtension_Seventh_Minor = @"b7";
NSString * const kChordExtension_Ninth_Major = @"9";
NSString * const kChordExtension_Ninth_Minor = @"b9";
NSString * const kChordExtension_Eleventh_Major = @"11";
NSString * const kChordExtension_Eleventh_Minor = @"b11";
NSString * const kChordExtension_Sixth_Major = @"6";
NSString * const kChordExtension_Sixth_Minor = @"b6";

#pragma mark -
#pragma mark Key Settings
#pragma mark -

NSString * const kKeyType_C = @"C"; 
NSString * const kKeyType_CsharpDflat = @"A#/Bb"; 
NSString * const kKeyType_D = @"D"; 
NSString * const kKeyType_DsharpEflat = @"D#/Eb"; 
NSString * const kKeyType_E = @"E"; 
NSString * const kKeyType_F = @"F"; 
NSString * const kKeyType_FsharpGflat = @"F#/Gb"; 
NSString * const kKeyType_G = @"G"; 
NSString * const kKeyType_GsharpAFlat = @"G#/Ab";
NSString * const kKeyType_A = @"A"; 
NSString * const kKeyType_AsharpBflat = @"A#/Bb"; 
NSString * const kKeyType_B = @"B";


NSString * const kKeyMajor = @"Major=2 2 1 2 2 2 1";
NSString * const kKeyMinor = @"Minor=2 1 2 2 1 2 2";
NSString * const kKeyMinorHarmonic = @"Harmonic Minor=2 1 2 2 1 3 1";
NSString * const kKeyMinorMelodic = @"Melodic Minor=2 1 2 2 2 2 1";
NSString * const kKeyPentatonicMajor = @"Major Pentatonic=2 2 3 2 3";
NSString * const kKeyPentatonicMinor = @"Minor Pentatonic=4 1 2 4 1";

@end
