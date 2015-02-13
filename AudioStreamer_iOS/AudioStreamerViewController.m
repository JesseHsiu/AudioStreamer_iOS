//
//  AudioStreamerViewController.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/9/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#define DATA_SIZE 512
#define PortNumber 21369

#import "AudioStreamerViewController.h"


//TableCellView
#import "InstrumentsListTableViewCell.h"
#import "InstrumentsSettingTableViewCell.h"

@interface AudioStreamerViewController ()
-(void)updateChannelNames:(NSArray *)names;
@end

@implementation AudioStreamerViewController

- (void)viewDidLoad {
    
    self.navigationItem.title = self.ServerName;
    
    instrumentsTableView = [[InstrumentsListTableView alloc]init];
    monitorChannels = [[NSMutableArray alloc] init];
    
    //??
    initialized = false;
    numOfChannel= 0;
    //localtag???
    
    
    
    [self setupTCPSocket];
    [self setupUDPSocket];
    
    NSData *data = [@"hey" dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:self.IpAddress port:PortNumber withTimeout:-1 tag:0];
    
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
    
    self.byteDataArray = (Byte *) malloc(DATA_SIZE*numOfChannel);
    aeAudioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:NO];
    //    _audioController.preferredBufferDuration = 0.005;
    aeAudioController.preferredBufferDuration = 0.0029;
    //    _audioController.preferredBufferDuration = 0.00145;
    
    NSError *error = [NSError alloc];
    if(![aeAudioController start:&error]){
        NSLog(@"Error starting AudioController: %@", error.localizedDescription);
    }
    
    
    for(int i = 0; i < numOfChannel; i++){
        
        MonitorChannel* channelToProcess = [[MonitorChannel alloc]initWithAudioController:aeAudioController];
        AudioBufferManager *ablManager = [[AudioBufferManager alloc]init];
        ablManager.buffer = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], DATA_SIZE);
        channelToProcess.audioBufferManager =ablManager;
        
        [monitorChannels addObject:channelToProcess];
    }

    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    NSLog(@"Proximity Monitoring Enabled? %@ ",    [UIDevice currentDevice].proximityMonitoringEnabled ? @"YES" : @"NO");
    
    initialized = true;
}


#pragma mark TableView DataSources Thing
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

#pragma mark TableView Delegate Thing
//not implement


#pragma mark TCP_Socket
-(void)setupTCPSocket{
    tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSString *host = self.IpAddress;

    //fixed port number
    uint16_t port = PortNumber;
    
    NSError *error = nil;
    if (![tcpSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
}

#pragma mark UDP_Socket
-(void)setupUDPSocket{
//    localTag = 0;
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"Socket Ready");
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        NSLog(@"RECV: %@", msg);
        
        NSArray *array = [msg componentsSeparatedByString:@":"];
        if ((int)array.count == numOfChannel){
            [self updateChannelNames:array];
        } else if ([[array objectAtIndex:0] isEqual:@"image"]){
            //Initialize standard image already on the phone
            long index = [[array objectAtIndex:1] integerValue];
            NSString *path = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:2] ofType:[array objectAtIndex:3]];
            ((MonitorChannel*)[monitorChannels objectAtIndex:index]).PathToImg = path;
        }
    }
}


#pragma mark TCP_delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
    //    NSString *ack = [[NSString alloc] initWithFormat:@"received %li",tag];
    //    NSData *d = [ack dataUsingEncoding:NSUTF8StringEncoding];
    //    [sock writeData:d withTimeout:-1 tag:0];
    
    if(data.length == DATA_SIZE * numOfChannel){
        [self decodeAudioBufferListMultiChannel:data];
    } else {
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (msg)
        {
            NSLog(@"RECV: %@", msg);
            
            NSArray *array = [msg componentsSeparatedByString:@":"];
            if(!initialized){
                numOfChannel = [array count];
                
                [self initializeAll];
            } else if ([array count] == numOfChannel){
                [self updateChannelNames:array];
            } else if ([[array objectAtIndex:0] isEqual:@"image"]){
                //Initialize standard image already on the phone
                long index = [[array objectAtIndex:1] integerValue];
                NSString *path = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:2] ofType:[array objectAtIndex:3]];
                ((MonitorChannel*)[monitorChannels objectAtIndex:index]).PathToImg = path;
            }
        }
    }
    
    NSUInteger datalength = DATA_SIZE * numOfChannel;
    [sock readDataToLength:datalength withTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Disconnected with error: %@", err.localizedDescription);
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Did write data with tag: %li",tag);
    // [sock readDataWithTimeout:-1 tag:0];
}

-(void)updateChannelNames:(NSArray *)names{
    for (int i = 0; i < numOfChannel; i++) {
        ((MonitorChannel*)[monitorChannels objectAtIndex:i]).name = [names objectAtIndex:i];
    }
    [self.view reloadInputViews];
}


#pragma mark Decode
-(void)decodeAudioBufferListMultiChannel:(NSData *)data {
    //We should do the initialization part at a different place:
    
    NSUInteger dataLen = [data length];
    if(dataLen > 0){
        //Empty the byteDataArray
        //        self.byteDataArray = [self.byteDataArray initWithCapacity:numChannels];
        //Take the start position of the first subrange
        NSUInteger startPos = 0;
        //Calculate the length of the subranges
        NSUInteger rangeLen = dataLen / numOfChannel;
        //        NSLog(@"%lu,%d ->rangelen :  %lu %lu",(unsigned long)dataLen,numChannels,(unsigned long)rangeLen, sizeof(_ablArray));
        //Create a uint32 version of the rangelength
        UInt32 rLen = (UInt32) rangeLen;
        
        
        
        
        for(int i = 0; i < numOfChannel; i++){
            NSRange range = NSMakeRange(startPos, rangeLen);
            NSData *subdata = [data subdataWithRange:range];
            
            //Get the i'th audio buffer list and fill it with data
            
            //            self.abl->mBuffers[i].mDataByteSize = rLen;
            //            self.abl->mBuffers[i].mNumberChannels = 1;
            memcpy(&self.byteDataArray[DATA_SIZE*i], [subdata bytes], rLen);
            //            self.abl->mBuffers[i].mData = &self.byteDataArray[dataSize*i];

            AudioBufferManager *ablManager = ((MonitorChannel*)[monitorChannels objectAtIndex:i]).audioBufferManager;
            
            ablManager.buffer->mNumberBuffers = 2;
            ablManager.buffer->mBuffers[0].mDataByteSize = rLen;
            ablManager.buffer->mBuffers[0].mNumberChannels = 1;
            ablManager.buffer->mBuffers[0].mData = &self.byteDataArray[DATA_SIZE*i];
            //            self.ablArray[16*i].mBuffers[1].mDataByteSize = rLen;
            //            self.ablArray[16*i].mBuffers[1].mNumberChannels = 1;
            //            self.ablArray[16*i].mBuffers[1].mData = &self.byteDataArray[dataSize*i];
            ablManager.buffer->mBuffers[1] = ablManager.buffer->mBuffers[0];
            
            [[[monitorChannels objectAtIndex:i] getChannelPlayer] addToBufferWithoutTimeStampAudioBufferList:ablManager.buffer];
            
            startPos += rangeLen;
        }
        //return self.abl;
        //        return self.ablArray;
    }
    //    return nil;
}

@end
