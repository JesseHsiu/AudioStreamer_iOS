//
//  AudioStreamerViewController.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import "InstrumentsListTableView.h"

//socket
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

//
#import "MonitorChannel.h"

@interface AudioStreamerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>
{
    IBOutlet InstrumentsListTableView *instrumentsTableView;
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *tcpSocket;
    
    NSMutableArray *monitorChannels;
    
    AEAudioController *aeAudioController;
    
    NSUInteger numOfChannel;
    BOOL initialized;
    
    
    dispatch_queue_t bufferQueue;
    
}

@property (nonatomic,assign) NSString *IpAddress;
@property (nonatomic,assign) NSString *ServerName;


@property (nonatomic) Byte *byteDataArray;

@end
