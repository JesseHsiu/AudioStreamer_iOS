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
    
    int NumberOfSettingCell;
    NSMutableArray *ShowingSettingIndex;
    
}
@property (nonatomic,assign) NSInteger numOfChannel;
@property (nonatomic,assign) NSString *IpAddress;
@property (nonatomic,assign) NSString *ServerName;


@property (nonatomic) Byte *byteDataArray;

@end
