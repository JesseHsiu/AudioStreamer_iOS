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
@synthesize numOfChannels;

- (void)viewDidLoad {

    self.navigationItem.title = self.serverName;
    monitorChannels = [[NSMutableArray alloc] init];
    
    //??
    initialized = false;
    self.numOfChannels= 0;
    //localtag???
    
    networkStreamer = [[NetworkStreamer alloc]initWithIpAddress:self.ipAddress portNumber:PortNumber];
    networkStreamer.delegate = self;
    
    
    viewIndex = [[NSMutableArray alloc]init];
    
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
    [viewIndex removeAllObjects];
    [monitorChannels removeAllObjects];
    aeAudioController = nil;
    
    self.byteDataArray = (Byte *) malloc(DATA_SIZE*self.numOfChannels);
    aeAudioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:NO];
    //    _audioController.preferredBufferDuration = 0.005;
    aeAudioController.preferredBufferDuration = 0.0029;
//        aeAudioController.preferredBufferDuration = 0.00145;
    
    
    NSError *error = [NSError alloc];
    if(![aeAudioController start:&error]){
        NSLog(@"Error starting AudioController: %@", error.localizedDescription);
    }
    
    
    for(int i = 0; i < self.numOfChannels; i++){
        
        MonitorChannel* channelToProcess = [[MonitorChannel alloc]initWithAudioController:aeAudioController];
        AudioBufferManager *ablManager = [[AudioBufferManager alloc]init];
        ablManager.buffer = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], DATA_SIZE);
        channelToProcess.audioBufferManager =ablManager;
        channelToProcess.channelNumber = i+1;
        
        [viewIndex addObject:channelToProcess];
        [monitorChannels addObject:channelToProcess];
    }

//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
//    NSLog(@"Proximity Monitoring Enabled? %@ ",    [UIDevice currentDevice].proximityMonitoringEnabled ? @"YES" : @"NO");
    
    AudioStreamBasicDescription asbd = aeAudioController.audioDescription;
    
    initialized = true;
}


#pragma mark TableView DataSources Thing
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [viewIndex count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Instruments";
    static NSString *CellIdentifier_Setting = @"InstrumentsSettings";

//    if ([ShowingSettingIndex containsObject:indexPath]) {
//    if ([[viewIndex objectAtIndex:indexPath.row] isMemberOfClass:[NSIndexPath class]]) {
    if ([[viewIndex objectAtIndex:indexPath.row] isKindOfClass:[NSIndexPath class]]) {

        InstrumentsSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Setting];
        cell.delegate = self;
        if (cell == nil) {
            cell = [[InstrumentsSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.volumLabel.text = [NSString stringWithFormat:@"%1.0f",((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row-1]).volumeValue * 100];
        
        cell.reverbSlider.value =((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row-1]).reverbValue;
        cell.panSlider.value = ((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row-1]).panValue;
        
//        cell.CustomSlider.sliderValue =((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row-1]).panValue;

        return cell;
    }
    else
    {
        InstrumentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate=self;
        if (cell == nil) {
            cell = [[InstrumentsListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

            
        }
        
        MonitorChannel *monChan = ((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row]);
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%i - %@", monChan.channelNumber, monChan.name];
        cell.volumeSlider.value = monChan.volumeValue;
        
        
        NSLog(@"%@",monChan.pathToImg);
        
        if (![monChan.pathToImg isEqualToString:@""]) {
            [cell.imageOfInstruments setImage:[UIImage imageNamed:monChan.pathToImg]];
        }
        else
        {
            [cell.imageOfInstruments setImage:[UIImage imageNamed:@"music-note.png"]];
        }
        
        return cell;

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 120;
}
#pragma mark tableUIDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (instrumentsTableView.isEditing) {
        return YES;
    }
    else
    {
        return NO;
    }
    // Return YES - we will be able to delete all rows
    
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSObject *Object = [viewIndex objectAtIndex:sourceIndexPath.row];
    
    [viewIndex removeObjectAtIndex:sourceIndexPath.row];
    [viewIndex insertObject:Object atIndex:destinationIndexPath.row];
    
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

#pragma mark NetworkStreamer Delegate
- (void)NetworkStreamerReceivedData:(NSData *)data
{
    @autoreleasepool {
        
//        int countChannels = 0;
//        for (int i = 0; i < [monitorChannels count]; i++) {
//            if ([[monitorChannels objectAtIndex:i] isKindOfClass:[MonitorChannel class]]) {
//                countChannels++;
//            }
//        }
//        NSLog(@"countChannels: %d",countChannels);
        
        
        NSData *copiedData = [data copy];
        NSUInteger dataLen = [copiedData length];
        if(dataLen > 0){
            //Empty the byteDataArray
            //        self.byteDataArray = [self.byteDataArray initWithCapacity:numChannels];
            //Take the start position of the first subrange
            NSUInteger startPos = 0;
            //Calculate the length of the subranges
            NSUInteger rangeLen = dataLen / [monitorChannels count];
            //        NSLog(@"%lu,%d ->rangelen :  %lu %lu",(unsigned long)dataLen,numChannels,(unsigned long)rangeLen, sizeof(_ablArray));
            //Create a uint32 version of the rangelength
            UInt32 rLen = (UInt32) rangeLen;
            
            for(int i = 0; i < [monitorChannels count]; i++){
                
                NSRange range = NSMakeRange(startPos, rangeLen);
                NSData *subdata = [[copiedData subdataWithRange:range] copy];
                
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
    
}

-(void)NetworkStreamerChannelInfoUpdate:(NSArray *)info NumberOfChannel:(NSUInteger)num
{
    self.numOfChannels = num;
    if (!initialized) {
        [self initializeAll];
    }
    for (int i = 0; i < [monitorChannels count]; i++) {
        ((MonitorChannel*)[monitorChannels objectAtIndex:i]).name = [[info objectAtIndex:i] objectForKey:@"name"];
        
        NSDictionary *ImageDict = [[info objectAtIndex:i] objectForKey:@"image"];
        
        NSString *path = [NSString stringWithFormat:@"%@.%@",[ImageDict objectForKey:@"fileName"],[ImageDict objectForKey:@"fileExtension"]];
        MonitorChannel* mc = (MonitorChannel*)[monitorChannels objectAtIndex:num];
        mc.pathToImg = path;

        dispatch_async(dispatch_get_main_queue(), ^{
            [instrumentsTableView reloadData];
        });
        
        NSLog(@"%@",[info objectAtIndex:i]);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [instrumentsTableView reloadData];
    });
}

-(void)NetworkStreamerReceivedImageForChannelNumber:(int)num fileName:(NSString *)fileName fileExtension:(NSString *)fileExtension{
    //Change the image for the channel at index "num" to the image with name "fileName"
    NSString *path = [NSString stringWithFormat:@"%@.%@",fileName,fileExtension];//[[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
    
    MonitorChannel* mc = (MonitorChannel*)[monitorChannels objectAtIndex:num];
    mc.pathToImg = path;
    
    //UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    //[instrumentsTableView cellForRowAtIndexPath:<#(NSIndexPath *)#>]
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [instrumentsTableView reloadData];
    });
    

//    [instrumentsTableView ind]
}

-(void)NetworkStreamerUpdateNumberOfChannel:(NSUInteger)num
{
    self.numOfChannels = num;
    [self initializeAll];
    NSLog(@"NumberOfChannel changed %ld",(long)self.numOfChannels);
}
#pragma mark InstrumentsListTableViewCell Delegate

- (void)MuteBtnPressed:(id)sender
{
    NSIndexPath *indexPath = [instrumentsTableView indexPathForCell:sender];
    if (((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row]).mutedValue) {
        [((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row]) setMuted:NO];
        [((InstrumentsListTableViewCell*)sender).muteButton setTitle:@"Mute" forState:UIControlStateNormal];
    }
    else
    {
        [((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row]) setMuted:YES];
        [((InstrumentsListTableViewCell*)sender).muteButton setTitle:@"Unmute" forState:UIControlStateNormal];
    }
    
}
- (void)VolumeSliderChanged:(float)value Sender:(id)sender
{
    NSIndexPath *indexPath = [instrumentsTableView indexPathForCell:sender];
    [((MonitorChannel*)[viewIndex objectAtIndex:indexPath.row]) setVolume:value];
    
    
    NSIndexPath *NewIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    
    if ([instrumentsTableView cellForRowAtIndexPath:NewIndexPath] != nil) {
        if ([[instrumentsTableView cellForRowAtIndexPath:NewIndexPath] isKindOfClass:[InstrumentsSettingTableViewCell class]]) {
            ((InstrumentsSettingTableViewCell*)[instrumentsTableView cellForRowAtIndexPath:NewIndexPath]).volumLabel.text = [NSString stringWithFormat:@"%1.0f",value * 100];
        }
    }
}

- (void)displaySettingBtnPressed:(id)sender
{
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [instrumentsTableView indexPathForCell:sender];
    NSIndexPath *NewIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [indexPaths addObject:NewIndexPath];
    

    if ([[instrumentsTableView cellForRowAtIndexPath:NewIndexPath] isKindOfClass:[InstrumentsSettingTableViewCell class]]) {
//        [ShowingSettingIndex removeObject:NewIndexPath];
        [viewIndex removeObjectAtIndex:NewIndexPath.row];
        [instrumentsTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        //do stuff
        [viewIndex insertObject:NewIndexPath atIndex:NewIndexPath.row];
//        [ShowingSettingIndex addObject:NewIndexPath];
        [instrumentsTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }

}
#pragma mark InstrumentsSettingCellDelegate Delegate
- (void)volumeAddBtnPressed:(id)sender
{
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [instrumentsTableView indexPathForCell:sender];
    NSIndexPath *NewIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    
    [indexPaths addObject:NewIndexPath];
    float tmp =((MonitorChannel*)[viewIndex objectAtIndex:NewIndexPath.row]).volumeValue;
    
    if (tmp == 1.f) {
        return;
    }
    
    tmp += 0.01f;
    
    if (tmp > 1.f) {
        tmp = 1.f;
    }
    
    [((MonitorChannel*)[viewIndex objectAtIndex:NewIndexPath.row]) setVolume:tmp];
    ((InstrumentsSettingTableViewCell*)[instrumentsTableView cellForRowAtIndexPath:indexPath]).volumLabel.text =[NSString stringWithFormat:@"%1.0f",tmp*100];
    [instrumentsTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}
- (void)volumeSubBtnPressed:(id)sender
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [instrumentsTableView indexPathForCell:sender];
    NSIndexPath *NewIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    
    [indexPaths addObject:NewIndexPath];
    float tmp =((MonitorChannel*)[viewIndex objectAtIndex:NewIndexPath.row]).volumeValue;
    
    if (tmp == 0.f) {
        return;
    }
    
    tmp -= 0.01f;
    
    if (tmp < 0.f) {
        tmp = 0.f;
    }
    
    [((MonitorChannel*)[viewIndex objectAtIndex:NewIndexPath.row]) setVolume:tmp];
    ((InstrumentsSettingTableViewCell*)[instrumentsTableView cellForRowAtIndexPath:indexPath]).volumLabel.text =[NSString stringWithFormat:@"%1.0f",tmp*100];
    [instrumentsTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}
- (void)panSliderSliderChanged:(float)value Sender:(id)sender
{
    NSIndexPath *indexPath = [instrumentsTableView indexPathForCell:sender];
    NSIndexPath *NewIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    
    [((MonitorChannel*)[viewIndex objectAtIndex:NewIndexPath.row]) setPan:value];
}
- (void)reverbSliderSliderChanged:(float)value Sender:(id)sender
{
    NSIndexPath *indexPath = [instrumentsTableView indexPathForCell:sender];
    NSIndexPath *NewIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    [((MonitorChannel*)[viewIndex objectAtIndex:NewIndexPath.row]) changeReverb:value];
}
- (IBAction)EditBtnPressed:(UIBarButtonItem *)sender {
    
    if (instrumentsTableView.isEditing) {
        sender.title = @"Edit";
        [instrumentsTableView setEditing:NO animated:YES];
    }
    else
    {
        sender.title = @"Done";
        
        NSMutableArray *indexPathsNeedToRemove = [[NSMutableArray alloc] init];
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
        
        for (int i =0 ; i< [viewIndex count]; i++) {
            if ([[viewIndex objectAtIndex:i] isKindOfClass:[NSIndexPath class]]) {
                NSIndexPath *Path = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPathsNeedToRemove addObject:Path];
                [indexSet addIndex:i];
            }
        }
        
        [viewIndex removeObjectsAtIndexes:indexSet];
        
        [instrumentsTableView deleteRowsAtIndexPaths:indexPathsNeedToRemove withRowAnimation:UITableViewRowAnimationFade];
        [instrumentsTableView setEditing:YES animated:YES];
    }
    
    
}

@end
