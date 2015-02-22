//
//  SliderModel.h
//  sliderTest
//
//  Created by Sander Valstar on 2/16/15.
//  Copyright (c) 2015 Sander Valstar. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface SliderModel : UIControl
@property (nonatomic) IBInspectable float maximumValue;
@property (nonatomic) IBInspectable float minimumValue;
@property (nonatomic) IBInspectable float centerValue;
@property (nonatomic) IBInspectable float sliderValue;

@property (nonatomic) UIColor* trackColor;
@property (nonatomic) UIColor* trackHighlightColor;
@property (nonatomic) UIColor* knobColor;
@property (nonatomic) UIColor* centerPointColor;
@property (nonatomic) float curvaceousness;


-(void) setLayerFrames;
- (float) positionForValue:(float)value;

@end
