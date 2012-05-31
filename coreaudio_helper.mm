//
//  coreaudio_helper.cpp
//  Bridge
//
//  Created by Philip Regan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <CoreServices/CoreServices.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h> //for AUGraph
#include <unistd.h> // used for usleep...

AUGraph graph = 0;
AudioUnit synthUnit;
OSStatus result;

UInt8 midiChannelInUse = 0; //we're using midi channel 1...


// This call creates the Graph and the Synth unit...
OSStatus	
CreateAUGraph (AUGraph &outGraph, AudioUnit &outSynth) 
{
	OSStatus result;
	//create the nodes of the graph
	AUNode synthNode, limiterNode, outNode;
	
	AudioComponentDescription cd;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
	
	require_noerr (result = NewAUGraph (&outGraph), home);
	
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_DLSSynth;
	
	require_noerr (result = AUGraphAddNode (outGraph, &cd, &synthNode), home);
	
	cd.componentType = kAudioUnitType_Effect;
	cd.componentSubType = kAudioUnitSubType_PeakLimiter;  
	
	require_noerr (result = AUGraphAddNode (outGraph, &cd, &limiterNode), home);
	
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_DefaultOutput;  
	require_noerr (result = AUGraphAddNode (outGraph, &cd, &outNode), home);
	
	require_noerr (result = AUGraphOpen (outGraph), home);
	
	require_noerr (result = AUGraphConnectNodeInput (outGraph, synthNode, 0, limiterNode, 0), home);
	require_noerr (result = AUGraphConnectNodeInput (outGraph, limiterNode, 0, outNode, 0), home);
	
	// ok we're good to go - get the Synth Unit...
	require_noerr (result = AUGraphNodeInfo(outGraph, synthNode, 0, &outSynth), home);
	
home:
	return result;
}