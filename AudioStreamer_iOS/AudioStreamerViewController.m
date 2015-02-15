//
//  AudioStreamerViewController.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

//#define DATA_SIZE 512
#define PortNumber 21369

#import "AudioStreamerViewController.h"


//TableCellView
#import "InstrumentsListTableViewCell.h"
#import "InstrumentsSettingTableViewCell.h"

@interface AudioStreamerViewController ()
@end

@implementation AudioStreamerViewController
@synthesize numOfChannel;

- (void)viewDidLoad {
    
    self.navigationItem.title = self.ServerName;
    monitorChannels = [[NSMutableArray alloc] init];
    
    //??
    initialized = false;
    self.numOfChannel= 0;
    //localtag???
    
    networkStreamer = [[NetworkStreamer alloc]initWithIpAddress:self.IpAddress portNumber:PortNumber];
    networkStreamer.delegate = self;
    
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

#pragma mark Init Functions
-(void)initializeAll{
    
    [monitorChannels removeAllObjects];
    aeAudioController = nil;
    
    self.byteDataArray = (Byte *) malloc(DATA_SIZE*self.numOfChannel);
    aeAudioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:NO];
    //    _audioController.preferredBufferDuration = 0.005;
    aeAudioController.preferredBufferDuration = 0.0029;
//        aeAudioController.preferredBufferDuration = 0.00145;
    
    NSError *error = [NSError alloc];
    if(![aeAudioController start:&error]){
        NSLog(@"Error starting AudioController: %@", error.localizedDescription);
    }
    
    
    for(int i = 0; i < self.numOfChannel; i++){
        
        MonitorChannel* channelToProcess = [[MonitorChannel alloc]initWithAudioController:aeAudioController];
        AudioBufferManager *ablManager = [[AudioBufferManager alloc]init];
        ablManager.buffer = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], DATA_SIZE);
        channelToProcess.audioBufferManager =ablManager;
        
        [monitorChannels addObject:channelToProcess];
    }

//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
//    NSLog(@"Proximity Monitoring Enabled? %@ ",    [UIDevice currentDevice].proximityMonitoringEnabled ? @"YES" : @"NO");
    
    initialized = true;
}


#pragma mark TableView DataSources Thing
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [monitorChannels count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Instruments";
    static NSString *CellIdentifier_Setting = @"InstrumentsSettings";
    
    
//    if (indexPath.row>5) {
//        InstrumentsSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Setting];
//        if (cell == nil) {
//            cell = [[InstrumentsSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//    
//        
//        return cell;
//    }
//    else
//    {
        InstrumentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[InstrumentsListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    
        cell.nameLabel.text = ((MonitorChannel*)[monitorChannels objectAtIndex:indexPath.row]).name;
        return cell;
//    }
    
    
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

#pragma mark TableView Delegate Thing
//not implement



#pragma mark NetworkStreamer Delegate
- (void)NetworkStreamerReceivedData:(NSData *)data
{
    NSUInteger dataLen = [data length];
    if(dataLen > 0){
        //Empty the byteDataArray
        //        self.byteDataArray = [self.byteDataArray initWithCapacity:numChannels];
        //Take the start position of the first subrange
        NSUInteger startPos = 0;
        //Calculate the length of the subranges
        NSUInteger rangeLen = dataLen / self.numOfChannel;
        //        NSLog(@"%lu,%d ->rangelen :  %lu %lu",(unsigned long)dataLen,numChannels,(unsigned long)rangeLen, sizeof(_ablArray));
        //Create a uint32 version of the rangelength
        UInt32 rLen = (UInt32) rangeLen;
        
        
        
        
        for(int i = 0; i < [monitorChannels count]; i++){
            NSRange range = NSMakeRange(startPos, rangeLen);
            NSData *subdata = [data subdataWithRange:range];
            
            //Get the i'th audio buffer list and fill it with data
            
            //            self.abl->mBuffers[i].mDataByteSize = rLen;
            //            self.abl->mBuffers[i].mNumberChannels = 1;
            memcpy(&self.byteDataArray[DATA_SIZE*i], [subdata bytes], rLen);
            //            self.abl->mBuffers[i].mData = &self.byteDataArray[dataSize*i];
            
            AudioBufferList *ablManagerBufferList = ((MonitorChannel*)[monitorChannels objectAtIndex:i]).audioBufferManager.buffer;
            ablManagerBufferList->mBuffers[0].mData = nil;
            ablManagerBufferList->mNumberBuffers = 2;
            ablManagerBufferList->mBuffers[0].mDataByteSize = rLen;
            ablManagerBufferList->mBuffers[0].mNumberChannels = 1;
            ablManagerBufferList->mBuffers[0].mData = &self.byteDataArray[DATA_SIZE*i];
            //            self.ablArray[16*i].mBuffers[1].mDataByteSize = rLen;
            //            self.ablArray[16*i].mBuffers[1].mNumberChannels = 1;
            //            self.ablArray[16*i].mBuffers[1].mData = &self.byteDataArray[dataSize*i];
            ablManagerBufferList->mBuffers[1] = ablManagerBufferList->mBuffers[0];
            
            [[monitorChannels objectAtIndex:i] addToBufferToList];
            
            startPos += rangeLen;
        }
        //return self.abl;
        //        return self.ablArray;
    }
    //    return nil;

}
-(void)NetworkStreamerUpdateName:(NSArray *)nameArray NumberOfChannel:(NSUInteger)num
{
    self.numOfChannel = num;
    if (!initialized) {
        [self initializeAll];
    }
    
    for (int i = 0; i < self.numOfChannel; i++) {
        ((MonitorChannel*)[monitorChannels objectAtIndex:i]).name = [nameArray objectAtIndex:i];
        NSLog(@"%@",[nameArray objectAtIndex:i]);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [instrumentsTableView reloadData];
    });
}
-(void)NetworkStreamerUpdateNumberOfChannel:(NSUInteger)num
{
    self.numOfChannel = num;
    [self initializeAll];
    NSLog(@"NumberOfChannel changed %ld",(long)self.numOfChannel);
}


@end
