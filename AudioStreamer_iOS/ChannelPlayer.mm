//
//  MyAudioPlayer.m
//  taaeTest2
//
//  Created by Sander on 1/13/15.
//  Copyright (c) 2015 Sander. All rights reserved.
//

#import "ChannelPlayer.h"


@implementation ChannelPlayer

-(instancetype)init{
    self = [super init];
    TPCircularBufferInit(&_cbuffer, 16384);
    
    return self;
}

static OSStatus renderCallback(__unsafe_unretained ChannelPlayer *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio) {
    //NSLog(@"Outpuuutaaa");
    
//    while ( 1 ) {
//        // Discard any buffers with an incompatible format, in the event of a format change
//        AudioBufferList *nextBuffer = TPCircularBufferNextBufferList(&THIS->_cbuffer, NULL);
//        if ( !nextBuffer ) break;
//        if ( nextBuffer->mNumberBuffers == audio->mNumberBuffers ) break;
//        TPCircularBufferConsumeNextBufferList(&THIS->_cbuffer);
//    }
//    
//    UInt32 fillCount = TPCircularBufferPeek(&THIS->_cbuffer, NULL, AEAudioControllerAudioDescription(audioController));
//    if ( fillCount > frames ) {
//        UInt32 skip = fillCount - frames;
//        TPCircularBufferDequeueBufferListFrames(&THIS->_cbuffer,
//                                                &skip,
//                                                NULL,
//                                                NULL,
//                                                AEAudioControllerAudioDescription(audioController));
//    }
    
    TPCircularBufferDequeueBufferListFrames(&THIS->_cbuffer,
                                            &frames,
                                            audio,
                                            NULL,
                                            AEAudioControllerAudioDescription(audioController));

    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback{
    return (AEAudioControllerRenderCallback)renderCallback;
}

-(void)addToBufferAudioBufferList:(AudioBufferList *)abl frames:(UInt32)frames timestamp:(const AudioTimeStamp *)time{
    TPCircularBufferCopyAudioBufferList(&_cbuffer, abl, time, kTPCircularBufferCopyAll, NULL);
}

-(void)addToBufferWithoutTimeStampAudioBufferList:(AudioBufferList *)abl {
    
        if(TPCircularBufferCopyAudioBufferList(&_cbuffer, abl, NULL, kTPCircularBufferCopyAll, NULL)){
            //AEFreeAudioBufferList(abl);
            if(abl){
                //AEFreeAudioBufferList(abl);
            }
        }
}


-(void)produceBytesInCircularBuffer:(NSData*)data{
    TPCircularBufferProduceBytes(&_cbuffer, [data bytes], [data length]);
}


@end
