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

@end
