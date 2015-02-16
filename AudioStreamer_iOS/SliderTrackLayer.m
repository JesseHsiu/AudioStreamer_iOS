//
//  SliderTrackLayer.m
//  sliderTest
//
//  Created by Sander Valstar on 2/16/15.
//  Copyright (c) 2015 Sander Valstar. All rights reserved.
//

#import "SliderTrackLayer.h"
#import "SliderModel.h"

@implementation SliderTrackLayer

-(void)drawInContext:(CGContextRef)ctx{
    
    
   // [UISlider tra]
    
    // clip
    float cornerRadius = self.bounds.size.height * self.slider.curvaceousness / 2.0;
    UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                             cornerRadius:cornerRadius];
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextClip(ctx);
    
    // 1) fill the track
    CGContextSetFillColorWithColor(ctx, self.slider.trackColor.CGColor);
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextFillPath(ctx);
    
    // 2) fill the highlighed range
    CGContextSetFillColorWithColor(ctx, self.slider.trackHighlightColor.CGColor);
    float lower = 0.0f;
    float upper = 0.0f;
    if (self.slider.sliderValue < self.slider.centerValue) {
        lower = [self.slider positionForValue:self.slider.sliderValue];
        upper = [self.slider positionForValue:self.slider.centerValue];
    } else {
        lower = [self.slider positionForValue:self.slider.centerValue];
        upper = [self.slider positionForValue:self.slider.sliderValue];
    }
    CGContextFillRect(ctx, CGRectMake(lower, 0, upper - lower, self.bounds.size.height));
    
    // 3) add a highlight over the track
    CGRect highlight = CGRectMake(cornerRadius/2, self.bounds.size.height/2,
                                  self.bounds.size.width - cornerRadius, self.bounds.size.height/2);
    UIBezierPath *highlightPath = [UIBezierPath bezierPathWithRoundedRect:highlight
                                                             cornerRadius:highlight.size.height * self.slider.curvaceousness / 2.0];
    CGContextAddPath(ctx, highlightPath.CGPath);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.4].CGColor);
    CGContextFillPath(ctx);
    
    // 4) inner shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2.0), 3.0, [UIColor grayColor].CGColor);
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokePath(ctx);
    
    // 5) outline the track
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    
    
}

@end
