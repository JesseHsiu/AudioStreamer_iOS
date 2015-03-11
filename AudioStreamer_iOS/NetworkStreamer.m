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
        SocketList = [[NSMutableDictionary alloc]init];
        ipAddress = ipaddress;
        portNumber = port;
//        [self setupTCPSocket];
        [SocketList setObject:[self setupInitUDPSocket] forKey:@"initSocket"];
        
        self.bufferQueue = dispatch_queue_create("com.mydomain.app.newimagesinbackground", NULL); // create my serial queue
        
        numOfChannel = 0;
        initialized =false;
        
        
        UUID = [NSUUID UUID];
        stringUUID = [UUID UUIDString];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[[UIDevice currentDevice] name] forKey:@"name"];
        [dict setObject:stringUUID forKey:@"uuid"];
    
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
        
        [SocketList setObject:AudioStreamSocket forKey:@"audioSocket"];
        [AudioStreamSocket connectToHost:ipAddress onPort:portNumber error:nil];
    }
    else
    {
        GCDAsyncUdpSocket *AudioStreamSocket =[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [SocketList setObject:AudioStreamSocket forKey:@"audioSocket"];
        
        if (![AudioStreamSocket bindToPort:0 error:nil]) {
            NSLog(@"error to open the port");
        }
        if (![AudioStreamSocket beginReceiving:nil]) {
            NSLog(@"error to beginingReceiving");
        }
        NSLog(@"Audio Socket Address: %@",[AudioStreamSocket localAddress]);
        NSLog(@"Audio Socket Port: %@",[NSString stringWithFormat:@"%d",[AudioStreamSocket localPort]]);
    }
    
}

-(void)setUpUpdateSocket{
    if (ConnectionType.Updates) {//tcp
        GCDAsyncSocket *UpdateSocket =[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [SocketList setObject:UpdateSocket forKey:@"updateSocket"];
        if (![UpdateSocket acceptOnPort:0 error:nil]) {
            NSLog(@"error to accept on port");
        }
    }
    else
    {
        GCDAsyncUdpSocket *UpdateSocket =[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [SocketList setObject:UpdateSocket forKey:@"updateSocket"];
        if (![UpdateSocket bindToPort:0 error:nil]) {
            NSLog(@"error to open the port");
        }
        if (![UpdateSocket beginReceiving:nil]) {
            NSLog(@"error to beginingReceiving");
        }
        NSLog(@"Update Socket Address: %@",[UpdateSocket localAddress]);
        NSLog(@"Update Socket Port: %@",[NSString stringWithFormat:@"%d",[UpdateSocket localPort]]);
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
    NSError *err = nil;
    
    if (![initSocket bindToPort:0 error:&err])
    {
        NSLog(@"Error binding: %@", err);
        return nil;
    }
    if (![initSocket beginReceiving:&err])
    {
        NSLog(@"Error receiving: %@", err);
        return nil;
    }
    
    NSLog(@"Socket Ready");
    return initSocket;
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    
    
    if(sock == [SocketList objectForKey:@"audioSocket"])
    {
        if(data.length == DATA_SIZE * numOfChannel){
            [self.delegate NetworkStreamerReceivedData:[data copy]];
        }
        //        NSUInteger datalength = DATA_SIZE * numOfChannel;
        //        [sock readDataToLength:datalength withTimeout:-1 tag:0];
    }
    else if (sock == [SocketList objectForKey:@"initSocket"]) {
        //Initialize the Update socket and the Audio socket and send their port numbers to the server
        [self InitSocketProcess:data];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject:stringUUID forKey:@"uuid"];
        [dict setObject:@"updateSocket" forKey:@"socket"];
        NSData *dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [[SocketList objectForKey:@"updateSocket"] sendData:dictData toAddress:address withTimeout:-1 tag:0];
        
        [dict removeObjectForKey:@"socket"];
        [dict setObject:@"audioSocket" forKey:@"socket"];
        dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [[SocketList objectForKey:@"audioSocket"] sendData:dictData toAddress:address withTimeout:-1 tag:0];
        
        [sock close];
    }
    else if (sock == [SocketList objectForKey:@"updateSocket"])
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
            
            NSLog(@"InitSocketProcess - %@",[jsonDict objectForKey:@"audio"]);
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
        NSLog(@"update channel number, hasn't been implememted yet");
    }
}


#pragma mark TCP_delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if (sock == [SocketList objectForKey:@"initSocket"]) {
        [self InitSocketProcess:data];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:stringUUID forKey:@"uuid"];
        [dict setObject:[[SocketList objectForKey:@"updateSocket"] localHost] forKey:@"ipaddress"];
        [dict setObject:[NSString stringWithFormat:@"%d",[[SocketList objectForKey:@"updateSocket"] localPort]] forKey:@"port"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [sock writeData:data withTimeout:-1 tag:0];
        [sock disconnectAfterWriting];
    }
    else if(sock == [SocketList objectForKey:@"audioSocket"])
    {
        if(data.length == DATA_SIZE * numOfChannel){
            [self.delegate NetworkStreamerReceivedData:[data copy]];
        }
        NSUInteger datalength = DATA_SIZE * numOfChannel;
        [sock readDataToLength:datalength withTimeout:-1 tag:0];
    }
    else if(sock == [SocketList objectForKey:@"updateSocket"])
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
