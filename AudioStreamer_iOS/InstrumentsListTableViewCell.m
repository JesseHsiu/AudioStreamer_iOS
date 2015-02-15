//
//  InstrumentsListTableViewCell.m
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/12/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import "InstrumentsListTableViewCell.h"

@implementation InstrumentsListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.muteButton addTarget:self action:@selector(MuteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.volumeSlider addTarget:self action:@selector(VolumeChanged) forControlEvents:UIControlEventValueChanged];
    [self.displaySettingButton addTarget:self action:@selector(SettingBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)MuteBtn
{
    [self.delegate MuteBtnPressed:self];
}
-(void)VolumeChanged
{
    [self.delegate VolumeSliderChanged:self.volumeSlider.value Sender:self];
}
-(void)SettingBtn
{
    [self.delegate displaySettingBtnPressed:self];
}


@end
