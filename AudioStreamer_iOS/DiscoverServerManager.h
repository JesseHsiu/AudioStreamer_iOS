//
//  DiscoverServerManager.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

@interface DiscoverServerManager : NSObject <ServerDelegate,NSNetServiceDelegate>
{
    Server *Discover;
    NSNetService *NetReslover;
    
}
@property (strong,nonatomic)NSMutableArray *DiscoveredServers;

@end
