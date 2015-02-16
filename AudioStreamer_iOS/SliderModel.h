//
//  SliderModel.h
//  sliderTest
//
//  Created by Sander Valstar on 2/16/15.
//  Copyright (c) 2015 Sander Valstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderModel : UIControl

@property (nonatomic) float maximumValue;
@property (nonatomic) float minimumValue;
@property (nonatomic) float centerValue;
@property (nonatomic) float sliderValue;

@property (nonatomic) UIColor* trackColor;
@property (nonatomic) UIColor* trackHighlightColor;
@property (nonatomic) UIColor* knobColor;
@property (nonatomic) UIColor* centerPointColor;
@property (nonatomic) float curvaceousness;


-(void) setLayerFrames;
- (float) positionForValue:(float)value;

@end
