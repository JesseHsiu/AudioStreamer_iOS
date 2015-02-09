//
//  DiscoverServerManager.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscoverServerManager : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
    NSNetService *NetReslover;
    NSNetServiceBrowser *Browser;
    
}
@property (strong,nonatomic)NSMutableArray *DiscoveredServers;

@end
