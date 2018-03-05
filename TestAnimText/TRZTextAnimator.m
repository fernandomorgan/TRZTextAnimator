//
//  TRZTextAnimator.m
//  Portkey
//
//  Created by Fernando Pereira on 10/11/17.
//  Copyright © 2017 Troezen. All rights reserved.
//
//

#import "TRZTextAnimator.h"
@import CoreText;

static NSTimeInterval const kDefaultAnimationDurationStroke = 1.0;
static NSTimeInterval const kDefaultAnimationDurationExtraForFill = 2.0;

static NSTimeInterval const kWiggleAnimationTransformDurationBase = 0.4;


@interface TRZTextAnimator () <CAAnimationDelegate>
@property (nonatomic) UIView*                   referenceView;
// default animation shape
@property (nonatomic) CAShapeLayer*             pathLayer;
// letters wiggle
@property (nonatomic) NSArray<CAShapeLayer*>*   letterLayers;
@end

@implementation TRZTextAnimator

- (nonnull instancetype) initWithReferenceUIView:(nonnull UIView*)view {
    if ( self = [super init] ) {
        _centerLayer = YES;
        _referenceView = view;
        _type = PTKTextAnimatorTypeDefault;
        _defaultColor = [UIColor blackColor];
        _letterLayers = @[];
        _wiggleRepeatCount = (NSInteger)HUGE_VALF;
        _fractionOfLettersToWiggle = 1;
        _indexForLettersToWiggle = @{};
        _wiggleAnimationDuration = kWiggleAnimationTransformDurationBase;
    }
    return self;
}

- (void) setText:(NSAttributedString *)text {
    _text = text;
    [self clearLayers];
}

- (void) setCenterLayer:(BOOL)centerLayer {
    _centerLayer = centerLayer;
    [self clearLayers];
}

- (void) show {
    if ( !self.pathLayer ) {
        [self setupLayers];
    }
    [self.referenceView.layer addSublayer:self.pathLayer];
}

- (void) destroy {
    [self.pathLayer removeAllAnimations];
    [self.pathLayer removeFromSuperlayer];
    [self removeAllLetterAnimations];
    [self hideLetterLayers];
}

- (void) doAnimationWithCompletion:(void (^_Nullable)(void)) completion {
    if ( !self.pathLayer || self.letterLayers.count == 0 ) {
        [self setupLayers];
    } else {
        [self.pathLayer removeAllAnimations];
        [self removeAllLetterAnimations];
    }
    
    if ( self.type == PTKTextAnimatorTypeDefault ) {
        if ( !self.pathLayer.superlayer ) {
            [self.referenceView.layer addSublayer:self.pathLayer];
        }
        [self hideLetterLayers];
    } else {
        [self.pathLayer removeFromSuperlayer];
        [self showLetterLayers];
    }
    [self.referenceView setNeedsLayout];
    [self.referenceView layoutIfNeeded];
    
    [CATransaction begin];
    if ( completion ) {
        [CATransaction setCompletionBlock:completion];
    }
    if ( self.type == PTKTextAnimatorTypeDefault ) {
        [self.pathLayer addAnimation:self.writeAnimation forKey:@"writeAnim"];
    } else if ( self.type == PTKTextAnimatorTypeWiggle ) {
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.letterLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL shouldAnimate = NO;
            if ( self.indexForLettersToWiggle.count ) {
                NSNumber* animVal = self.indexForLettersToWiggle[@(idx)];
                shouldAnimate = (animVal && animVal.boolValue) ;
            } else {
                shouldAnimate = (self.fractionOfLettersToWiggle == 1 ) || ([self randomTo:1.0f] <= self.fractionOfLettersToWiggle);
            }
            if (shouldAnimate) {
                CAAnimation* animation = [self wiggleAnimationWithIndex:idx toLayer:layer];
                if ( animation ) {
                    [layer addAnimation:animation forKey:@"wiggle"];
                    if ( layer.sublayers.count ) {
                        CALayer* subLayer = layer.sublayers.firstObject;
                        if ( subLayer ) {
                            CAAnimation* colorAnim = [self wiggleSubLayerAnimationWithColor:layer.fillColor duration:animation.duration timeOffset:animation.timeOffset];
                            [subLayer addAnimation:colorAnim forKey:@"wiggle"];
                        }
                    }
                }
            }
        }];
    }
    [CATransaction commit];
}

#pragma --- internal methods ---

- (void) showLetterLayers {
    for ( CAShapeLayer* layer in self.letterLayers ) {
        [self.referenceView.layer addSublayer:layer];
    }
}

- (void) hideLetterLayers {
    for ( CAShapeLayer* layer in self.letterLayers ) {
        [layer removeFromSuperlayer];
    }
}

- (void) clearLayers {
    [self clearLayer:self.pathLayer];
    self.pathLayer = nil;
    for (CAShapeLayer* layer in self.letterLayers) {
        [self clearLayer:layer];
    }
    self.letterLayers = @[];
}

- (void) clearLayer:(CALayer*) layer {
    if (!layer) return;
    [layer removeAllAnimations];
    [layer removeFromSuperlayer];
}

- (void) setupLayers {
    CTLineRef lineRef = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef) self.text);
    CFArrayRef runArray =  CTLineGetGlyphRuns(lineRef);
    struct CGPath* letters = CGPathCreateMutable();
    NSMutableArray* indPaths = [NSMutableArray new];
    for (NSUInteger idx = 0; idx< CFArrayGetCount(runArray); idx++) {
        CTRunRef runRef = CFArrayGetValueAtIndex(runArray, idx);
        NSDictionary* dict = ( __bridge NSDictionary*)CTRunGetAttributes(runRef);
        
        CTFontRef fontRef = (__bridge CTFontRef)dict[NSFontAttributeName];
        UIColor* color = dict[NSForegroundColorAttributeName] ?: self.defaultColor;
        
        for ( NSUInteger runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(runRef); runGlyphIndex++ ) {
            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position = CGPointZero;
            
            CTRunGetGlyphs(runRef, glyphRange, &glyph);
            CTRunGetPositions(runRef, glyphRange, &position);
            
            CGPathRef letter = CTFontCreatePathForGlyph(fontRef, glyph, nil);
            if (!letter) continue;
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(position.x, position.y);
            CGPathAddPath(letters, &transform, letter);
            
            CAShapeLayer* layer = [self makePathWithLettersPath:(struct CGPath*)letter position:position color:color];
            if (layer) {
                [indPaths addObject:layer];
                CALayer* subLayer = [self makeSmallSubPathWithLettersPath:(struct CGPath*)letter];
                [layer addSublayer:subLayer];
            }
            CFRelease(letter);
        }
    }
    
    self.letterLayers = indPaths;
    self.pathLayer = [self makePathWithLettersPath:letters position:CGPointZero color:self.defaultColor];
    
    if ( self.centerLayer ) {
        CGFloat lastY = self.pathLayer.position.y + CGRectGetWidth(self.pathLayer.bounds);
        CGFloat margin = CGRectGetWidth(self.referenceView.bounds) - lastY;
        if ( margin > 0 ) {
            margin /= 2;
            self.pathLayer.position = CGPointMake(self.pathLayer.position.x + margin, self.pathLayer.position.y);
            for ( CAShapeLayer* layer in self.letterLayers ) {
                layer.position = CGPointMake(layer.position.x + margin, layer.position.y);
            }
        }
    }
}

- (CAShapeLayer*) makePathWithLettersPath:(struct CGPath*)letters position:(CGPoint)position color:(UIColor*)color{
    UIBezierPath* path = [UIBezierPath bezierPathWithCGPath:letters];
    CAShapeLayer* pathLayer = [CAShapeLayer new];
    pathLayer.anchorPoint = CGPointMake(0,1.0f);
    pathLayer.position = position;
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = color.CGColor;
    pathLayer.fillColor = color.CGColor;
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    pathLayer.masksToBounds = NO;
    return pathLayer;
}

- (CAShapeLayer*) makeSmallSubPathWithLettersPath:(struct CGPath*)letters{
    UIBezierPath* path = [UIBezierPath bezierPathWithCGPath:letters];
    CAShapeLayer* pathLayer = [CAShapeLayer new];
    pathLayer.anchorPoint = CGPointZero;
    pathLayer.position = CGPointMake(-2.0f,0);
    CGRect bigSQ = CGPathGetBoundingBox(path.CGPath);
    pathLayer.bounds = CGRectMake(0, 0, bigSQ.size.width/2, 3.0f);
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [UIColor clearColor].CGColor;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    pathLayer.masksToBounds = YES;
    return pathLayer;
}

#pragma mark --- create animations ---

- (void) removeAllLetterAnimations {
    for ( CAShapeLayer* layer in self.letterLayers ) {
        [layer removeAllAnimations];
    }
}

- (CAAnimation*) writeAnimation {
    CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = kDefaultAnimationDurationStroke;
    pathAnimation.fromValue = @(0);
    pathAnimation.toValue = @(1);
    pathAnimation.delegate = self;
    
    CAKeyframeAnimation* colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    colorAnimation.duration = pathAnimation.duration + kDefaultAnimationDurationExtraForFill;
    colorAnimation.values = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,
                             (id)[UIColor clearColor].CGColor, (id)self.defaultColor.CGColor,  nil];
    colorAnimation.keyTimes = @[@(0), @(pathAnimation.duration/colorAnimation.duration), @(1)];
    
    CAAnimationGroup* writeAnimation = [CAAnimationGroup animation];
    writeAnimation.animations = @[pathAnimation,colorAnimation];
    writeAnimation.duration = colorAnimation.duration;
    return writeAnimation;
}

- (CAAnimation*) wiggleAnimationWithIndex:(NSUInteger)index toLayer:(CALayer*)layer{
    NSArray* keyTimes = @[@(0), @(0.2f), @(0.4), @(0.6), @(0.8f), @(1)];

    CGFloat angle = 0.04f + [self randomTo:0.02f];
    NSValue* rotZero = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0.0f, 1.0f)];
    NSValue* rot1 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f)];
    NSValue* rot2 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle, angle, 0.0f, 1.0f)];
    NSValue* rot3 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle*2, -angle, 0.0f, 1.0f)];
    NSValue* rot4 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-angle, -angle, 0.0f, 1.0f)];

    CGFloat wiggleX = 0.8f + [self randomTo:0.4f];
    CGFloat wiggleY = 1.0f + [self randomTo:0.8f];
    NSValue* posZero = [NSValue valueWithCGPoint:CGPointZero];
    NSValue* pos1 = [NSValue valueWithCGPoint:CGPointMake(wiggleX/3, wiggleY/3)];
    NSValue* pos2 = [NSValue valueWithCGPoint:CGPointMake(wiggleX/2, wiggleY/2)];
    NSValue* pos3 = [NSValue valueWithCGPoint:CGPointMake(wiggleX, wiggleY)];
    NSValue* pos4 = [NSValue valueWithCGPoint:CGPointMake(2*wiggleX, wiggleY)];
    NSValue* pos5 = [NSValue valueWithCGPoint:CGPointMake(wiggleX, 2*wiggleY)];
    
    CGRect diffBounds = layer.bounds;
    diffBounds.size.height -= (0.02f + [self randomTo:0.01f]);
    diffBounds.size.width -= [self randomTo:0.03f];
    NSValue* boundsZero = [NSValue valueWithCGRect:layer.bounds];
    NSValue* boundsDiff = [NSValue valueWithCGRect:diffBounds];
    
    CAKeyframeAnimation* transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    transformAnimation.values =  @[rotZero, rot1, rot2, rot3, rot3, rot4];
    transformAnimation.keyTimes = keyTimes;
    transformAnimation.autoreverses = YES;
    transformAnimation.additive = YES;
    transformAnimation.duration = self.wiggleAnimationDuration + (NSTimeInterval)[self randomTo:0.2f];
    
    CAKeyframeAnimation* boundsAnimation = [CAKeyframeAnimation animation];
    boundsAnimation.keyPath = @"bounds";
    boundsAnimation.keyTimes = keyTimes;
    if ( index % 2  == 0 ) {
        boundsAnimation.values = @[boundsZero, boundsDiff, boundsZero, boundsZero, boundsDiff, boundsDiff];
    } else {
        boundsAnimation.values = @[boundsDiff, boundsDiff, boundsZero, boundsZero, boundsDiff, boundsDiff];
    }
    boundsAnimation.additive = NO;
    boundsAnimation.duration = transformAnimation.duration;
    
    CAKeyframeAnimation* posAnimation = [CAKeyframeAnimation animation];
    posAnimation.keyPath = @"position";
    posAnimation.keyTimes = keyTimes;
    if ( index % 2  == 0 ) {
        posAnimation.values = @[posZero,pos1,pos2,pos3,pos4,pos5];
    } else {
        posAnimation.values = @[pos1,pos3,pos5,posZero,pos4,pos2];
    }
    posAnimation.autoreverses = YES;
    posAnimation.additive = YES;
    posAnimation.duration = transformAnimation.duration;
    
    CAAnimationGroup* animation = [CAAnimationGroup animation];
    animation.animations = @[transformAnimation,posAnimation,boundsAnimation];
    animation.repeatCount = self.wiggleRepeatCount;
    animation.duration = posAnimation.duration;
    animation.timeOffset = [self randomTo:0.3f];
    return animation;
}

- (CAAnimation*) wiggleSubLayerAnimationWithColor:(CGColorRef)colorRef duration:(NSTimeInterval)duration timeOffset:(NSTimeInterval)timeOffset {
    CAKeyframeAnimation* colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    colorAnimation.duration = duration;
    colorAnimation.timeOffset = timeOffset;
    colorAnimation.repeatCount = self.wiggleRepeatCount;
    colorAnimation.values = @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor,
                              (__bridge id)colorRef, (__bridge id)colorRef, (__bridge id)colorRef,
                              (id)[UIColor clearColor].CGColor];
    colorAnimation.keyTimes = @[@(0), @(0.2f), @(0.4), @(0.6), @(0.8f), @(1)];
    return colorAnimation;
}

#pragma mark --- helper methods ---

- (CGFloat) randomTo:(CGFloat)maxVale {
    int32_t random = arc4random_uniform(100);
    return  maxVale * random / 100.0f;
}

@end
