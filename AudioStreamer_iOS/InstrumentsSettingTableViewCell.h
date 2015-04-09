//
//  InstrumentsSettingTableViewCell.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/13/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EFCircularSlider.h"



@protocol InstrumentsSettingCellDelegate
- (void)volumeAddBtnPressed:(id)sender;
- (void)volumeSubBtnPressed:(id)sender;
- (void)panSliderSliderChanged:(float)value Sender:(id)sender;
- (void)reverbSliderSliderChanged:(float)value Sender:(id)sender;
- (void)bassSliderSliderChanged:(float)value Sender:(id)sender;
- (void)midSliderSliderChanged:(float)value Sender:(id)sender;
- (void)trebleSliderSliderChanged:(float)value Sender:(id)sender;
@end


IB_DESIGNABLE
@interface InstrumentsSettingTableViewCell : UITableViewCell
@property (retain) id delegate;
@property (nonatomic,assign)IBOutlet UILabel *volumLabel;
@property (nonatomic,assign)IBOutlet UISlider *reverbSlider;
@property (nonatomic,assign)IBOutlet UISlider *panSlider;

@property (nonatomic,assign)IBOutlet UIButton *volumeAddBtn;
@property (nonatomic,assign)IBOutlet UIButton *volumeSubBtn;

@property (nonatomic, assign) IBOutlet UISlider *bassSlider;
@property (nonatomic, assign) IBOutlet UISlider *midSlider;
@property (nonatomic, assign) IBOutlet UISlider *trebleSlider;

@property (nonatomic, assign) IBOutlet EFCircularSlider *circleBassSlider;
@property (nonatomic, assign) IBOutlet EFCircularSlider *circleMidSlider;
@property (nonatomic, assign) IBOutlet EFCircularSlider *circleTrebleSlider;

@end
