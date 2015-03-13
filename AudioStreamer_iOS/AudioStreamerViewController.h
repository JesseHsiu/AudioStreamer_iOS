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
#import "NetworkStreamer.h"

//cell
#import "InstrumentsListTableViewCell.h"
#import "InstrumentsSettingTableViewCell.h"

@interface AudioStreamerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NetworkStreamerDelegate,InstrumentsListCellDelegate,InstrumentsSettingCellDelegate>
{
    
    IBOutlet InstrumentsListTableView *instrumentsTableView;
    NSMutableArray *monitorChannels;
    
    AEAudioController *aeAudioController;
    
    
    BOOL initialized;
    NetworkStreamer *networkStreamer;
    
    int numberOfSettingCell;
    NSMutableArray *viewIndex;
    
    //Try to fix random crashes
    NSMutableArray *ablNSArray;
    bool flag;
    
}
@property (nonatomic,assign) NSInteger numOfChannels;
@property (nonatomic,assign) NSString *ipAddress;
@property (nonatomic,assign) NSString *serverName;


@property (nonatomic) Byte *byteDataArray;

@end
