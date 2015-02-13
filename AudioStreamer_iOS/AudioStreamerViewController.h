//
//  AudioStreamerViewController.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import "ViewController.h"
#import "InstrumentsListTableView.h"

@interface AudioStreamerViewController : ViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet InstrumentsListTableView *instrumentsTableView;
}

@property (nonatomic,assign) NSString *IpAddress;
@property (nonatomic,assign) NSString *ServerName;

@end
