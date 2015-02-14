//
//  NetworkStreamer.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/14/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import <Foundation/Foundation.h>
//socket
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"


@interface NetworkStreamer : NSObject<GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>
{
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *tcpSocket;
    
    dispatch_queue_t bufferQueue;
}

@end
