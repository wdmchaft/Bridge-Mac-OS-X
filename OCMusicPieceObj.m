//
//  OCSongObj.m
//  Bridge
//
//  Created by Philip Regan on 2011/11/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCMusicPieceObj.h"

#import "OCKeyObj.h"

@implementation OCMusicPieceObj

@synthesize key;

#pragma mark -
#pragma mark init
#pragma mark -

- (id)init {
    self = [super init];
    if (self) {
        key = [[OCKeyObj alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark dealloc
#pragma mark -

- (void)dealloc {
    [key release];
    [super dealloc];
}

@end
