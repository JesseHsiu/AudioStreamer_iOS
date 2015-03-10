//
//  NetworkStreamer.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/14/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//


@import UIKit;
#import "NetworkStreamer.h"
//true means that using tcp
struct StreamType
{
    BOOL Audio;
    BOOL Updates;
};
struct StreamType ConnectionType;
//initSocket, Audio, Update

@implementation NetworkStreamer

-(NetworkStreamer*)initWithIpAddress:(NSString*)ipaddress portNumber:(uint16_t)port
{
    self = [super init];
    
    if (self) {
        SocketList = [[NSDictionary alloc]init];
        ipAddress = ipaddress;
        portNumber = port;
//        [self setupTCPSocket];
        [SocketList setValue:[self setupInitUDPSocket] forKey:@"initSocket"];
        
        self.bufferQueue = dispatch_queue_create("com.mydomain.app.newimagesinbackground", NULL); // create my serial queue
        
        numOfChannel = 0;
        initialized =false;
        
        
        NSUUID  *UUID = [NSUUID UUID];
        NSString* stringUUID = [UUID UUIDString];
        
        NSDictionary *dict = [[NSDictionary alloc]init];
        [dict setValue:[[UIDevice currentDevice] name] forKey:@"name"];
        [dict setValue:stringUUID forKey:@"uuid"];
    
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [[SocketList objectForKey:@"initSocket"] sendData:data toHost:ipAddress port:portNumber withTimeout:-1 tag:0];
    }
    return self;

}

-(void)initSocketAtLocal
{
    [self setUpAudioStreamingSocket];
    [self setUpUpdateSocket];
}


-(void)setUpAudioStreamingSocket{
    
    if (ConnectionType.Audio) {//tcp
        
        GCDAsyncSocket *AudioStreamSocket =[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        [SocketList setValue:AudioStreamSocket forKey:@"Audio"];
        [AudioStreamSocket connectToHost:ipAddress onPort:portNumber error:nil];
    }
    else
    {
        GCDAsyncUdpSocket *AudioStreamSocket =[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [SocketList setValue:AudioStreamSocket forKey:@"Audio"];
        [AudioStreamSocket connectToHost:ipAddress onPort:portNumber error:nil];
    }
    
}

-(void)setUpUpdateSocket{
    if (ConnectionType.Updates) {//tcp
        GCDAsyncSocket *UpdateSocket =[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [SocketList setValue:UpdateSocket forKey:@"Update"];
        if (![UpdateSocket acceptOnPort:portNumber+1 error:nil]) {
            NSLog(@"error to accept on the port");
        }
    }
    else
    {
        GCDAsyncUdpSocket *UpdateSocket =[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [SocketList setValue:UpdateSocket forKey:@"Update"];
        if (![UpdateSocket bindToPort:portNumber+1 error:nil]) {
            NSLog(@"error to open the port %d", portNumber+1);
        }
        if (![UpdateSocket beginReceiving:nil]) {
            NSLog(@"error to beginingReceiving");
        }
    }
    
}

#pragma mark TCP_Socket
//-(void)setupTCPSocket{
//    tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//    
//    NSString *host = ipAddress;
//    
//    //fixed port number
//    uint16_t port = portNumber;
//    
//    NSError *error = nil;
//    if (![tcpSocket connectToHost:host onPort:port error:&error])
//    {
//        NSLog(@"Error connecting: %@", error);
//    }
//}

#pragma mark UDP_Socket
-(GCDAsyncUdpSocket*)setupInitUDPSocket{
    //    localTag = 0;
    GCDAsyncUdpSocket *initSocket =  [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    
    if (![initSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return nil;
    }
    if (![initSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return nil;
    }
    
    NSLog(@"Socket Ready");
    return initSocket;
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    
    if ([[SocketList objectForKey:sock] isEqualToString:@"initSocket"]) {
        [self InitSocketProcess:data];
        
        NSDictionary *dict = [[NSDictionary alloc]init];
        [dict setValue:[[SocketList objectForKey:@"Update"] localHost] forKey:@"ipaddress"];
        [dict setValue:[NSString stringWithFormat:@"%d",[[SocketList objectForKey:@"Update"] localPort]] forKey:@"port"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        
        [sock sendData:data toHost:ipAddress port:portNumber withTimeout:-1 tag:0];
        [sock closeAfterSending];
    }
    else if([[SocketList objectForKey:sock] isEqualToString:@"Audio"])
    {
        if(data.length == DATA_SIZE * numOfChannel){
            [self.delegate NetworkStreamerReceivedData:[data copy]];
        }
//        NSUInteger datalength = DATA_SIZE * numOfChannel;
//        [sock readDataToLength:datalength withTimeout:-1 tag:0];
    }
    else if ([[SocketList objectForKey:sock] isEqualToString:@"Update"])
    {
        [self UpdateProcess:data];
    }
    
    
    
}


-(void)InitSocketProcess:(NSData*)data
{
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (jsonDict)
    {
        NSLog(@"RECV: %@", jsonDict);
        
        NSArray *array = [jsonDict objectForKey:@"channels"];
        if ([array count] == numOfChannel || !initialized){
            numOfChannel = [array count];
            [self.delegate NetworkStreamerChannelInfoUpdate:array NumberOfChannel:[array count]];
            
            
            if([[jsonDict objectForKey:@"audio"] isEqualToString:@"udp"])
            {
                ConnectionType.Audio = false;
            }
            else
            {
                ConnectionType.Audio = true;
            }
            
            if ([[jsonDict objectForKey:@"update"] isEqualToString:@"udp"]) {
                ConnectionType.Updates = false;
            }
            else
            {
                ConnectionType.Updates = true;
            }
            [self initSocketAtLocal];
        }
    }

}

-(void)UpdateProcess:(NSData*)data
{
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *array = [jsonDict objectForKey:@"channels"];
    if ([array count] == numOfChannel || !initialized){
        numOfChannel = [array count];
        [self.delegate NetworkStreamerChannelInfoUpdate:array NumberOfChannel:[array count]];
    }
    else
    {
        NSLog(@"update channel number, it hasn't implememt");
    }
}


#pragma mark TCP_delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if ([[SocketList objectForKey:sock] isEqualToString:@"initSocket"]) {
        [self InitSocketProcess:data];
        NSDictionary *dict = [[NSDictionary alloc]init];
        [dict setValue:[[SocketList objectForKey:@"Update"] localHost] forKey:@"ipaddress"];
        [dict setValue:[NSString stringWithFormat:@"%d",[[SocketList objectForKey:@"Update"] localPort]] forKey:@"port"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [sock writeData:data withTimeout:-1 tag:0];
        [sock disconnectAfterWriting];
    }
    else if([[SocketList objectForKey:sock] isEqualToString:@"Audio"])
    {
        if(data.length == DATA_SIZE * numOfChannel){
            [self.delegate NetworkStreamerReceivedData:[data copy]];
        }
        NSUInteger datalength = DATA_SIZE * numOfChannel;
        [sock readDataToLength:datalength withTimeout:-1 tag:0];
    }
    else if([[SocketList objectForKey:sock] isEqualToString:@"Update"])
    {
        [self UpdateProcess:data];
    }
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Disconnected with error: %@", err.localizedDescription);
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Did write data with tag: %li",tag);
    // [sock readDataWithTimeout:-1 tag:0];
}

@end
