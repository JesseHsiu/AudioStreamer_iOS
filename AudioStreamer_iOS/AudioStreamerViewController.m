//
//  AudioStreamerViewController.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import "AudioStreamerViewController.h"


//TableCellView
#import "InstrumentsListTableViewCell.h"
#import "InstrumentsSettingTableViewCell.h"

@interface AudioStreamerViewController ()

@end

@implementation AudioStreamerViewController

- (void)viewDidLoad {
    self.navigationItem.title = self.ServerName;
    instrumentsTableView = [[InstrumentsListTableView alloc]init];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma TableView DataSources Thing
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Instruments";
    static NSString *CellIdentifier_Setting = @"InstrumentsSettings";
    
    
    if (indexPath.row>5) {
        InstrumentsSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Setting];
        if (cell == nil) {
            cell = [[InstrumentsSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        return cell;
    }
    else
    {
        InstrumentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[InstrumentsListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        return cell;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([[tableView cellForRowAtIndexPath:indexPath] isMemberOfClass:[InstrumentsListTableViewCell class]]) {
        return 120;
//    }
//    else
//    {
//        return 120;
//    }
}

#pragma TableView Delegate Thing



@end
