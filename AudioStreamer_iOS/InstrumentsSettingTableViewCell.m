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
    [self.panSlider addTarget:self action:@selector(panSliderChanged) forControlEvents:UIControlEventValueChanged];
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
    [self.delegate reverbSliderSliderChanged:self.reverbSlider.value Sender:self];
}
-(void)panSliderChanged
{
    [self.delegate panSliderSliderChanged:self.panSlider.value Sender:self];
}

@end
