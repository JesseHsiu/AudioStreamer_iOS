//
//  NetworkStreamer.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/14/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#define DATA_SIZE 512

#import <Foundation/Foundation.h>
//socket
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

@protocol NetworkStreamerDelegate
- (void)NetworkStreamerUpdateNumberOfChannel:(NSUInteger)num;
- (void)NetworkStreamerUpdateName:(NSArray*)nameArray;
- (void)NetworkStreamerReceivedData:(NSData *)data;
@end


@interface NetworkStreamer : NSObject<GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>
{
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *tcpSocket;
    
    dispatch_queue_t bufferQueue;
    
    NSString *ipAddress;
    uint16_t portNumber;
    NSUInteger numOfChannel;
    

    BOOL initialized;
}
@property (nonatomic) Byte *byteDataArray;
@property (retain) id delegate;
-(NetworkStreamer*)initWithIpAddress:(NSString*)ipaddress portNumber:(uint16_t)port;
@end

