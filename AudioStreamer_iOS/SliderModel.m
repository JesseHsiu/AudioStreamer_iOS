//
//  SliderModel.m
//  sliderTest
//
//  Created by Sander Valstar on 2/16/15.
//  Copyright (c) 2015 Sander Valstar. All rights reserved.
//

#import "SliderModel.h"
#import "SliderKnobLayer.h"
#import "SliderTrackLayer.h"
#import "SliderCenterPointLayer.h"

@implementation SliderModel{
    
    SliderTrackLayer* trackLayer;
    SliderCenterPointLayer* centerPointLayer;
    SliderKnobLayer* knobLayer;
    
    float knobWidth;
    float centerPointHeight;
    float centerPointWidth;
    float useableTrackLength;
    
    CGPoint previousTouchPoint;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
- (void)SETTER:(TYPE)PROPERTY { \
    if (_##PROPERTY != PROPERTY) { \
    _##PROPERTY = PROPERTY; \
    [self UPDATER]; \
    } \
}

GENERATE_SETTER(trackHighlightColor, UIColor*, setTrackHighlightColor, redrawLayers)

GENERATE_SETTER(trackColor, UIColor*, setTrackColor, redrawLayers)

GENERATE_SETTER(curvaceousness, float, setCurvaceousness, redrawLayers)

GENERATE_SETTER(knobColor, UIColor*, setKnobColor, redrawLayers)

GENERATE_SETTER(maximumValue, float, setMaximumValue, setLayerFrames)

GENERATE_SETTER(minimumValue, float, setMinimumValue, setLayerFrames)

GENERATE_SETTER(sliderValue, float, setSlidervalue, setLayerFrames)

GENERATE_SETTER(centerValue, float, setCenterValue, setLayerFrames)

- (void) redrawLayers
{
    [knobLayer setNeedsDisplay];
    [centerPointLayer setNeedsDisplay];
    [trackLayer setNeedsDisplay];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        self.maximumValue = 1.0f;
        self.minimumValue = -1.0f;
        self.centerValue = 0.0f;
        self.sliderValue = 0.0f;
        
        self.trackHighlightColor = [UIColor colorWithRed:0.0 green:0.45 blue:0.94 alpha:1.0];
        self.trackColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.knobColor = [UIColor whiteColor];
        self.centerPointColor = [UIColor darkGrayColor];
        _curvaceousness = 1.0;
        
        trackLayer = [SliderTrackLayer layer];
        trackLayer.slider = self;
        [self.layer addSublayer:trackLayer];
        
        centerPointLayer = [SliderCenterPointLayer layer];
        centerPointLayer.slider = self;
        [self.layer addSublayer:centerPointLayer];
        
        knobLayer = [SliderKnobLayer layer];
        knobLayer.slider = self;
        [self.layer addSublayer:knobLayer];
        
        [self setLayerFrames];
    }
    
    return self;
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{

    previousTouchPoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(knobLayer.frame, previousTouchPoint)) {
        NSLog(@"Knob touched");
        knobLayer.highlighted = YES;
        [knobLayer setNeedsDisplay];
        return YES;
    }
    return NO;
}

#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint touchPoint = [touch locationInView:self];
    
    // 1. determine by how much the user has dragged
    float delta = touchPoint.x - previousTouchPoint.x;
    float valueDelta = (_maximumValue - _minimumValue) * delta / useableTrackLength;
    
    previousTouchPoint = touchPoint;

    self.sliderValue += valueDelta;
    self.sliderValue = BOUND(self.sliderValue, self.maximumValue, self.minimumValue);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self setLayerFrames];
    
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    NSLog(@"Knob released");
    knobLayer.highlighted = NO;
    [knobLayer setNeedsDisplay];
}




-(void)setLayerFrames{
    knobWidth = self.bounds.size.height;
    centerPointHeight = self.bounds.size.height;
    centerPointWidth = 2;
    
    useableTrackLength = self.bounds.size.width - knobWidth;
    
    trackLayer.frame = CGRectInset(self.bounds, 0, self.bounds.size.height/3.5);
    [trackLayer setNeedsDisplay];
    
//    centerPointLayer.frame = CGRectMake(useableTrackLength/2, 0, 10, knobWidth+10);
    float centerPoint = [self positionForValue: self.centerValue];
    centerPointLayer.frame = CGRectMake(centerPoint - centerPointWidth/2, (self.bounds.size.height-centerPointHeight)/2, centerPointWidth, centerPointHeight);
    //centerPointLayer.frame = CGRectInset(self.bounds, 10, knobWidth+10);
    [centerPointLayer setNeedsDisplay];
    
    float knobCenter = [self positionForValue: self.sliderValue];
    knobLayer.frame = CGRectMake(knobCenter - knobWidth/2, 0, knobWidth, knobWidth);
    [knobLayer setNeedsDisplay];
    
}


- (float) positionForValue:(float)value
{
    return useableTrackLength * (value - self.minimumValue) /
    (self.maximumValue - self.minimumValue) + (knobWidth / 2);
}

@end
