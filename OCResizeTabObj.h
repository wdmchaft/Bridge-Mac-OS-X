//
//  OCResizeTabObj.h
//  Bridge
//
//  Created by Philip Regan on 2011/12/03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 This is a particular interface class used to give the user a visible, clickable
 object so that they may resize the length of a given object. Only those objects
 that handle resizing need implement this class.  It is, more than anything, simply 
 a convenience class to aid in interface development.
 
 This class contains no data other than a link back to the data class that it was
 attached to upon that object's creation via the super's parent property. But that
 link is crucial to link mouse clicks to objects.
 
 The object's appearance and mouse click interception is handled entirely within 
 the piano roll along with all of the other objects.
 
 Resize tabs are drawn directly to the right of the object to be resized. To keep 
 sizing consistent and scalable across classes and context, we base it on kNoteLength_16
  */

#import "OCMusicObj.h"

@interface OCResizeTabObj : OCMusicObj

// use the parent property of OCMusicObj to link back to the affected object

@end
