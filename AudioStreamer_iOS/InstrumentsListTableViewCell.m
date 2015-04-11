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
    [self.volumeLabel setText:[NSString stringWithFormat:@"%i", (int)(self.volumeSlider.value * 100)]];
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
    [self.volumeLabel setText:[NSString stringWithFormat:@"%i", (int)(self.volumeSlider.value * 100)]];
}
-(void)SettingBtn
{
    if (!self.isEditing) {
        [self.delegate displaySettingBtnPressed:self];
    }
}
-(void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if ((state & UITableViewCellStateShowingEditControlMask) == UITableViewCellStateShowingEditControlMask)
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.displaySettingButton setAlpha:0.4];
            [self.volumeLabel setAlpha:0];
        }];

        [self.displaySettingButton setEnabled:NO];
    }
    else if (state == UITableViewCellStateDefaultMask)
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.displaySettingButton setAlpha:1];
            [self.volumeLabel setAlpha:1];
        }];
        [self.displaySettingButton setEnabled:YES];
    }
    
}


@end
