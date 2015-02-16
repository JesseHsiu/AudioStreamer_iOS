//
//  SliderCenterPointLayer.m
//  sliderTest
//
//  Created by Sander Valstar on 2/16/15.
//  Copyright (c) 2015 Sander Valstar. All rights reserved.
//

#import "SliderCenterPointLayer.h"

#import "SliderModel.h"

@implementation SliderCenterPointLayer


-(void)drawInContext:(CGContextRef)ctx{
//    CGContextSetStrokeColorWithColor(ctx, self.slider.centerPointColor.CGColor);
    CGContextSetFillColorWithColor(ctx, self.slider.centerPointColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height));
    NSLog(@"Center Point Width: %f", self.bounds.size.width);
}

@end
