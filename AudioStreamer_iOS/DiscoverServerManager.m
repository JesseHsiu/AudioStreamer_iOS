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
        //init array
        self.DiscoveredServers = [[NSMutableArray alloc]init];
        
        self->Browser =[[NSNetServiceBrowser alloc] init];
        self->Browser.delegate = self;
        [self->Browser searchForServicesOfType:[NSString stringWithFormat:@"_%@._tcp.", type] inDomain:@"local"];
    }
    return self;
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

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NetReslover = aNetService;
    NetReslover.delegate = self;
    [NetReslover resolveWithTimeout:0.0];

}
-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSMutableArray *tmp = [self.DiscoveredServers copy];
    
    for (int i =  0 ; i< [tmp count];i++) {
        if ([[[tmp objectAtIndex:i] objectForKey:@"name"] isEqualToString:[aNetService name]]) {
            [self.DiscoveredServers removeObject:[tmp objectAtIndex:i]];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerChanged" object:self];
}

@end
