//
//  ChannelGroupRefModel.m
//  taaeTest2
//
//  Created by Sander Valstar on 2/12/15.
//  Copyright (c) 2015 Sander. All rights reserved.
//

#import "MonitorChannel.h"

@implementation MonitorChannel

-(MonitorChannel*)initWithAudioController:(AEAudioController*)audioController{
    self = [super init];
    
    if (self) {
        TPCircularBufferInit(&_cbuffer, 16384);
        
        self.audioController = audioController;
        self.channelPlayer = [[ChannelPlayer alloc] init];
        self.channelGroup = [self.audioController createChannelGroup];
        [self.audioController addChannels:[[NSArray alloc] initWithObjects:self.channelPlayer, nil] toChannelGroup:self.channelGroup];
        
        self.pathToImg =@"";
        self.channelNumber = -1;
        self.reverbValue = 0;
        self.volumeValue = 0.5;
        self.panValue = 0;
        self.mutedValue = false;
        
        
    }
    return self;
}

-(ChannelPlayer*)getChannelPlayer{
    return self.channelPlayer;
}

-(void)addReverb {
    AudioComponentDescription component
    = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                      kAudioUnitType_Effect,
                                      kAudioUnitSubType_Reverb2);
    NSError *error = NULL;
    self.reverb = [[AEAudioUnitFilter alloc]
                                 initWithComponentDescription:component
                                 audioController:_audioController
                                 error:&error];
    if ( !self.reverb ) {
        // Report error
        NSLog(@"Error initializing reverb: %@",error.localizedDescription);
    }
    
    AudioUnitSetParameter(self.reverb.audioUnit,
                          kReverb2Param_DryWetMix,
                          kAudioUnitScope_Global,
                          0,
                          0.f,
                          0);

    [self.audioController addFilter:self.reverb toChannelGroup:self.channelGroup];
}

-(void)changeReverb:(float)reverbValue{
    assert(0.f <= reverbValue && reverbValue <= 100.f);
    
    if (!self.reverb) {
        [self addReverb];
        return;
    }
    AudioUnitSetParameter(self.reverb.audioUnit,
                          kReverb2Param_DryWetMix,
                          kAudioUnitScope_Global,
                          0,
                          reverbValue,
                          0);
    self.reverbValue = reverbValue;
}

-(void)setMuted:(BOOL)muted{
    self.mutedValue = muted;
    [self.audioController setMuted:muted forChannelGroup:self.channelGroup];
}

-(void)setVolume:(float)volume
{
    assert(0.f <= volume && volume <= 1.f);
    self.volumeValue = volume;
    [self.audioController setVolume:volume forChannelGroup:self.channelGroup];
}

-(void)setPan:(float)pan{
    self.panValue = pan;
    [self.audioController setPan:pan forChannelGroup:self.channelGroup];
}
-(void)addToBufferToList
{
    [self.channelPlayer addToBufferWithoutTimeStampAudioBufferList:self.audioBufferManager.buffer];
}

-(void)addToCircularBufferAudioBufferList:(AudioBufferList *)abl{
    [self.channelPlayer addToBufferWithoutTimeStampAudioBufferList:abl];
}

@end
