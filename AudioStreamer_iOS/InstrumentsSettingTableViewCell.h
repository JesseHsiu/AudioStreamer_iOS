//
//  InstrumentsSettingTableViewCell.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/13/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InstrumentsSettingCellDelegate
- (void)volumeAddBtnPressed:(id)sender;
- (void)volumeSubBtnPressed:(id)sender;
- (void)panSliderSliderChanged:(float)value Sender:(id)sender;
- (void)reverbSliderSliderChanged:(float)value Sender:(id)sender;
@end



@interface InstrumentsSettingTableViewCell : UITableViewCell
@property (retain) id delegate;
@property (nonatomic,assign)IBOutlet UILabel *volumLabel;
@property (nonatomic,assign)IBOutlet UISlider *reverbSlider;
@property (nonatomic,assign)IBOutlet UISlider *panSlider;

@property (nonatomic,assign)IBOutlet UIButton *volumeAddBtn;
@property (nonatomic,assign)IBOutlet UIButton *volumeSubBtn;

@end
