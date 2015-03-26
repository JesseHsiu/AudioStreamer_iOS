//
//  ChannelGroupRefModel.m
//  taaeTest2
//
//  Created by Sander Valstar on 2/12/15.
//  Copyright (c) 2015 Sander. All rights reserved.
//

#import "MonitorChannel.h"

@implementation MonitorChannel

-(instancetype)init{
    self = [super init];
    
    if (self) {
        self.pathToImg =@"";
        self.channelNumber = -1;
        self.reverbValue = 0;
        self.volumeValue = 0.5;
        self.panValue = 0;
        self.mutedValue = false;
    }
    return self;
}

-(void)changeReverb:(float)reverbValue{
    assert(0.f <= reverbValue && reverbValue <= 100.f);
    self.reverbValue = reverbValue;
    [self prepareAndSendChannelInfoToServer];
}

-(void)setMuted:(BOOL)muted{
    self.mutedValue = muted;
    [self prepareAndSendChannelInfoToServer];
}

-(void)setVolume:(float)volume
{
    assert(0.f <= volume && volume <= 1.f);
    float dif = volume-self.volumeValue;
    //Don't send updates too soon, but also don't block the + and - buttons from editing the volume
    if(0.0098 <= dif || dif <= -0.0098){
        self.volumeValue = volume;
        [self prepareAndSendChannelInfoToServer];
    }
}

-(void)setPan:(float)pan{
    float dif = pan-self.panValue;
    if(0.05 < dif || dif < -0.05){
        self.panValue = pan;
        [self prepareAndSendChannelInfoToServer];
    }
}

-(void)prepareAndSendChannelInfoToServer{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSNumber *channel = [NSNumber numberWithInt:self.channelNumber];
    [dict setObject:channel forKey:@"channel"];
    NSNumber *volume = [NSNumber numberWithFloat:self.volumeValue];
    [dict setObject:volume forKey:@"volume"];
    NSNumber *muted = [NSNumber numberWithBool:self.mutedValue];
    [dict setObject:muted forKey:@"muted"];
    NSNumber *pan = [NSNumber numberWithFloat:self.panValue];
    [dict setObject:pan forKey:@"pan"];
    NSNumber *reverb = [NSNumber numberWithFloat:self.reverbValue];
    [dict setObject:reverb forKey:@"reverb"];
    [self.networkStreamer sendChannelInfoToServer:dict];
}

@end
