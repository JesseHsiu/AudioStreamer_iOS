//
//  InstrumentsListTableViewCell.h
//  AudioStreamer_iOS
//
//  Created by Hsiu Jesse on 2/12/15.
//  Copyright (c) 2015 MobileHCILab. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InstrumentsListCellDelegate
- (void)MuteBtnPressed:(id)sender;
- (void)VolumeSliderChanged:(float)value Sender:(id)sender;
- (void)displaySettingBtnPressed:(id)sender;
@end


@interface InstrumentsListTableViewCell : UITableViewCell

@property (retain) id delegate;
@property (nonatomic,assign)IBOutlet UIImageView *imageOfInstruments;
@property (nonatomic,assign)IBOutlet UILabel *nameLabel;
@property (nonatomic,assign)IBOutlet UISlider *volumeSlider;
@property (nonatomic,assign)IBOutlet UIButton *muteButton;
@property (nonatomic,assign)IBOutlet UIButton *displaySettingButton;

@end
