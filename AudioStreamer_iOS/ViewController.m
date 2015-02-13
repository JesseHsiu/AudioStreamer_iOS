//
//  ViewController.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import "ViewController.h"
#import "AudioStreamerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    ServerManager = [[DiscoverServerManager alloc]init];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [ServerManager startSearching];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTableView:) name:@"ServerChanged" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [ServerManager stopSearching];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateTableView:(NSNotification *)notification
{
    [tableview reloadData];
}
#pragma mark tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ServerManager.DiscoveredServers count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tmp = [ServerManager.DiscoveredServers objectAtIndex:indexPath.row];
    cell.textLabel.text = [tmp objectForKey:@"name"];
    cell.detailTextLabel.text = [tmp objectForKey:@"ip"];

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AudioStreamerViewController * vc = (AudioStreamerViewController *)[sb instantiateViewControllerWithIdentifier:@"AudioStreamerVC"];
    NSDictionary *tmp = [ServerManager.DiscoveredServers objectAtIndex:indexPath.row];
    vc.IpAddress =[tmp objectForKey:@"ip"];
    vc.ServerName = [tmp objectForKey:@"name"];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
