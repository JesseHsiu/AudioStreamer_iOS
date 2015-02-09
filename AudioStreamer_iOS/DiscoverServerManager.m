//
//  DiscoverServerManager.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import "DiscoverServerManager.h"
#include <arpa/inet.h>

@implementation DiscoverServerManager

- (id)init {
    if (self = [super init]) {

        //init servers
        NSString *type = @"TestingProtocol";
        self->Discover = [[Server alloc]initWithProtocol:type];
        self->Discover.delegate= self;
        
        NSError *error = nil;
        if(![self->Discover start:&error]) {
            NSLog(@"error = %@", error);
        }
        else
        {
            NSLog(@"success");
        }
        
        //init array
        self.DiscoveredServers = [[NSMutableArray alloc]init];
    }
    return self;
}

// sent when both sides of the connection are ready to go
- (void)serverRemoteConnectionComplete:(Server *)server
{
    
}
// called when the server is finished stopping
- (void)serverStopped:(Server *)server
{

}
// called when something goes wrong in the starup
- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict
{

}
// called when data gets here from the remote side of the server
- (void)server:(Server *)server didAcceptData:(NSData *)data
{

}
// called when the connection to the remote side is lost
- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict
{

}
// called when a new service comes on line
- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more
{
    //[DiscoveredServers addObject:service];
    
    //reslove ip address
    NetReslover = service;
    NetReslover.delegate = self;
    [NetReslover resolveWithTimeout:0.1];
}
// called when a service goes off line
- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more
{
    for (NSDictionary *dict in self.DiscoveredServers) {
        if ([[dict objectForKey:@"name"] isEqualToString:[service name]]) {
            [self.DiscoveredServers removeObject:dict];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerChanged" object:self];
    //[DiscoveredServers removeObject:service];
}

#pragma mark NSNetServiceDelegate
- (void)netServiceDidResolveAddress:(NSNetService *)service {
    
    char addressBuffer[INET6_ADDRSTRLEN];
    
    NSData *data = [service.addresses objectAtIndex:0];
    memset(addressBuffer, 0, INET6_ADDRSTRLEN);
    
    typedef union {
        struct sockaddr sa;
        struct sockaddr_in ipv4;
        struct sockaddr_in6 ipv6;
    } ip_socket_address;
    
    ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
    
    if (socketAddress && (socketAddress->sa.sa_family == AF_INET || socketAddress->sa.sa_family == AF_INET6))
    {
        const char *addressStr = inet_ntop(
                                           socketAddress->sa.sa_family,
                                           (socketAddress->sa.sa_family == AF_INET ? (void *)&(socketAddress->ipv4.sin_addr) : (void *)&(socketAddress->ipv6.sin6_addr)),
                                           addressBuffer,
                                           sizeof(addressBuffer));
        
        int port = ntohs(socketAddress->sa.sa_family == AF_INET ? socketAddress->ipv4.sin_port : socketAddress->ipv6.sin6_port);
        
        if (addressStr && port)
        {
            NSLog(@"Found service at %s:%d", addressStr, port);
            NSMutableDictionary *tmp = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[service name],@"name",[NSString stringWithFormat:@"%s",addressStr],@"ip", nil];
            [self.DiscoveredServers addObject:tmp];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerChanged" object:self];
        }
    }
    //    }
    
    assert(service == NetReslover);
    
    
    
    
    [NetReslover stop];
    NetReslover = nil;
}



@end
