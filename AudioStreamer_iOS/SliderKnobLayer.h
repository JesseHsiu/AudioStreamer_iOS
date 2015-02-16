//
//  SliderKnobLayer.h
//  sliderTest
//
//  Created by Sander Valstar on 2/16/15.
//  Copyright (c) 2015 Sander Valstar. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class SliderModel;

@interface SliderKnobLayer : CALayer

@property BOOL highlighted;
@property (weak) SliderModel *slider;

@end
