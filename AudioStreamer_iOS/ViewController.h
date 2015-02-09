//
//  ViewController.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverServerManager.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDataSource>
{
    DiscoverServerManager *ServerManager;
    IBOutlet UITableView *tableview;
}


@end

