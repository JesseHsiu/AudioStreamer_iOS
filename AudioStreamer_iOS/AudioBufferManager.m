//
//  AudioBufferManager.m
//  taaeTest2
//
//  Created by Sander Valstar on 1/31/15.
//  Copyright (c) 2015 Sander. All rights reserved.
//

#import "AudioBufferManager.h"
#import <TheAmazingAudioEngine.h>

@implementation AudioBufferManager

-(instancetype)initWithAnAudioBufferListWithSize: (int) dataSize{
    self = [super init];
    
    self.buffer = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], dataSize);
    
    return self;
}

@end
