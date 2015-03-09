//
//  NetworkStreamer.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/14/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//



#import "NetworkStreamer.h"

@implementation NetworkStreamer

-(NetworkStreamer*)initWithIpAddress:(NSString*)ipaddress portNumber:(uint16_t)port
{
    self = [super init];
    
    if (self) {
        ipAddress = ipaddress;
        portNumber = port;
        [self setupTCPSocket];
        [self setupUDPSocket];
        
        self.bufferQueue = dispatch_queue_create("com.mydomain.app.newimagesinbackground", NULL); // create my serial queue
        
        numOfChannel = 0;
        initialized =false;
        
        NSData *data = [@"hey" dataUsingEncoding:NSUTF8StringEncoding];
        [udpSocket sendData:data toHost:ipAddress port:portNumber withTimeout:-1 tag:0];
    }
    return self;

}


#pragma mark TCP_Socket
-(void)setupTCPSocket{
    tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSString *host = ipAddress;
    
    //fixed port number
    uint16_t port = portNumber;
    
    NSError *error = nil;
    if (![tcpSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
}

#pragma mark UDP_Socket
-(void)setupUDPSocket{
    //    localTag = 0;
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSError *error = nil;
    
    if (![udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"Socket Ready");
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (jsonDict)
    {
        NSLog(@"RECV: %@", jsonDict);

        NSArray *array = [jsonDict objectForKey:@"channels"];
        
//        if(!initialized){
//            // //                numChannels = (int)array.count;
//            // //                channelNames = [[NSMutableArray alloc]init];
//            // //                [channelNames addObjectsFromArray:array];
//            // //
//            // //                [self initializeAll];
//        }
//        else
//        if ([[array objectAtIndex:0] isEqual:@"image"]){
//            //            ignore now
//            NSLog(@"New image");
//
//            [self.delegate NetworkStreamerReceivedImageForChannelNumber:
//                        [[array objectAtIndex:1] integerValue]
//                        fileName: [array objectAtIndex:2]
//                        fileExtension:[array objectAtIndex:3]];
//            
//            //            //Initialize standard image already on the phone
//            //            long index = [[array objectAtIndex:1] integerValue];
//            //            NSString *path = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:2] ofType:[array objectAtIndex:3]];
//            //            ((MonitorChannel*)[monitorChannels objectAtIndex:index]).pathToImg = path;
//            //            [instrumentsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//        } else
        
        if ([array count] == numOfChannel || !initialized){
            numOfChannel = [array count];
//            [self.delegate NetworkStreamerUpdateNumberOfChannel:[array count]];
            [self.delegate NetworkStreamerChannelInfoUpdate:array NumberOfChannel:[array count]];
        }
    }
}

#pragma mark TCP_delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
    //    NSString *ack = [[NSString alloc] initWithFormat:@"received %li",tag];
    //    NSData *d = [ack dataUsingEncoding:NSUTF8StringEncoding];
    //    [sock writeData:d withTimeout:-1 tag:0];
    
    if(data.length == DATA_SIZE * numOfChannel){
        [self.delegate NetworkStreamerReceivedData:[data copy]];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [instrumentsTableView reloadData];
        //        });
    } else {
//        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSArray *array = [msg componentsSeparatedByString:@":"];
//        numOfChannel = [array count];
////        [self.delegate NetworkStreamerUpdateNumberOfChannel:[array count]];
////        [self.delegate NetworkStreamerUpdateName:array];
//        [self.delegate NetworkStreamerUpdateName:array NumberOfChannel:[array count]];
//        NSLog(@"NetworkStreamer: error dataSize");
//        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        if (msg)
//        {
//            NSLog(@"RECV: %@", msg);
//            
//            NSArray *array = [msg componentsSeparatedByString:@":"];
//            if(!initialized){
//                numOfChannel = [array count];
//                [self initializeAll];
//            } else if ([array count] == numOfChannel){
//                [self updateChannelNames:array];
//            } else if ([[array objectAtIndex:0] isEqual:@"image"]){
//                //Initialize standard image already on the phone
//                long index = [[array objectAtIndex:1] integerValue];
//                NSString *path = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:2] ofType:[array objectAtIndex:3]];
//                ((MonitorChannel*)[monitorChannels objectAtIndex:index]).pathToImg = path;
//            }
//        }
    }
    
    NSUInteger datalength = DATA_SIZE * numOfChannel;
    [sock readDataToLength:datalength withTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Disconnected with error: %@", err.localizedDescription);
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Did write data with tag: %li",tag);
    // [sock readDataWithTimeout:-1 tag:0];
}

@end
