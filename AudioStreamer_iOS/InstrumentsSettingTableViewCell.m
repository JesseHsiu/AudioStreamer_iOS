//
//  InstrumentsSettingTableViewCell.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/13/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import "InstrumentsSettingTableViewCell.h"

@implementation InstrumentsSettingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.volumeAddBtn addTarget:self action:@selector(volumeAdd) forControlEvents:UIControlEventTouchUpInside];
    [self.volumeSubBtn addTarget:self action:@selector(volumeSub) forControlEvents:UIControlEventTouchUpInside];
    [self.reverbSlider addTarget:self action:@selector(reverbSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self.panSlider addTarget:self action:@selector(panSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.bassSlider addTarget:self action:@selector(bassSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.midSlider addTarget:self action:@selector(midSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.trebleSlider addTarget:self action:@selector(trebleSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    
//    [self.circleBassSlider addTarget:self action:@selector(circlebassSliderChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.circleMidSlider addTarget:self action:@selector(circlemidSliderChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.circleTrebleSlider addTarget:self action:@selector(circletrebleSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)volumeAdd
{
    [self.delegate volumeAddBtnPressed:self];
}
-(void)volumeSub
{
    [self.delegate volumeSubBtnPressed:self];
}
-(void)reverbSliderChanged
{
    if( self.reverbSlider.value < 2.0f ){
        self.reverbSlider.value = 0.0f;
    }
    [self.delegate reverbSliderSliderChanged:self.reverbSlider.value Sender:self];
}
-(void)panSliderChanged:(id)sender
{
    if( -0.04f < self.panSlider.value && self.panSlider.value < 0.04f ){
        self.panSlider.value = 0.0f;
    }
    [self.delegate panSliderSliderChanged:self.panSlider.value Sender:self];
    
}
-(void)bassSliderChanged:(id)sender{
    if( 0.96f < self.bassSlider.value && self.bassSlider.value < 1.04f ){
        self.bassSlider.value = 1.0f;
    }
    [self.delegate bassSliderSliderChanged:self.bassSlider.value Sender:self];
}

-(void)midSliderChanged:(id)sender{
    if( 0.96f < self.midSlider.value && self.midSlider.value < 1.04f ){
        self.midSlider.value = 1.0f;
    }
    [self.delegate midSliderSliderChanged: self.midSlider.value Sender:self];
}

-(void)trebleSliderChanged:(id)sender{
    if( 0.96f < self.trebleSlider.value && self.trebleSlider.value < 1.04f ){
        self.trebleSlider.value = 1.0f;
    }
    [self.delegate trebleSliderSliderChanged:self.trebleSlider.value Sender:self];
}
//
//-(void)circlebassSliderChanged:(id)sender{
//    if( 0.96f < self.circleBassSlider.currentValue && self.circleBassSlider.currentValue < 1.04f ){
//        self.circleBassSlider.currentValue = 1.0f;
//    }
//    [self.delegate bassSliderSliderChanged:self.circleBassSlider.currentValue Sender:self];
//}
//
//-(void)circlemidSliderChanged:(id)sender{
//    if( 0.96f < self.circleMidSlider.currentValue && self.circleMidSlider.currentValue < 1.04f ){
//        self.circleMidSlider.currentValue = 1.0f;
//    }
//    [self.delegate midSliderSliderChanged: self.circleMidSlider.currentValue Sender:self];
//}
//
//-(void)circletrebleSliderChanged:(id)sender{
//    if( 0.96f < self.circleTrebleSlider.currentValue && self.circleTrebleSlider.currentValue < 1.04f ){
//        self.circleTrebleSlider.currentValue = 1.0f;
//    }
//    [self.delegate trebleSliderSliderChanged:self.circleTrebleSlider.currentValue Sender:self];
//}


@end
