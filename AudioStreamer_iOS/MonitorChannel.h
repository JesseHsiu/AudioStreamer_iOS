//
//  ChannelGroupRefModel.h
//  taaeTest2
//
//  Created by Sander Valstar on 2/12/15.
//  Copyright (c) 2015 Sander. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"
#import "TPCircularBuffer.h"
#import "TPCircularBuffer+AudioBufferList.h"
#import "ChannelPlayer.h"
#import "AudioBufferManager.h"
#import "NetworkStreamer.h"

@interface MonitorChannel: NSObject
{

}
@property (nonatomic, copy) NSString *pathToImg;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int channelNumber;
@property (nonatomic, assign) float reverbValue;
@property (nonatomic, assign) float volumeValue;
@property (nonatomic, assign) float panValue;
@property (nonatomic, assign) float bassValue;
@property (nonatomic, assign) float midValue;
@property (nonatomic, assign) float trebleValue;
@property (nonatomic, assign) BOOL mutedValue;
@property (nonatomic, assign) NetworkStreamer *networkStreamer;

//
//@property (nonatomic, strong) AudioBufferManager *audioBufferManager;
//@property (nonatomic, assign) TPCircularBuffer cbuffer;
//@property (nonatomic, assign) AEAudioController *audioController;
//@property (nonatomic, assign) AEChannelGroupRef channelGroup;
//@property (nonatomic, strong) ChannelPlayer *channelPlayer;
//@property (nonatomic, strong) AEAudioUnitFilter *reverb;

//-(MonitorChannel*)initWithAudioController:(AEAudioController*)audioController;
//-(ChannelPlayer*)getChannelPlayer;
//-(void)addReverb;
-(void)changeReverb:(float)reverbValue;
-(void)setVolume:(float)volume;
-(void)setPan:(float)pan;
-(void)setBass:(float)bass;
-(void)setMid:(float)mid;
-(void)setTreble:(float)treble;
-(void)setMuted:(BOOL)muted;
//-(void)addToBufferToList;
//-(void)addToCircularBufferAudioBufferList:(AudioBufferList *)abl;
@end
