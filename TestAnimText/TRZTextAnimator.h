//
//  TRZTextAnimator.h
//  TestAnimText
//
//  Created by Fernando Pereira on 10/11/17.
//  Copyright © 2017 Troezen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PTKTextAnimatorType) {
    PTKTextAnimatorTypeDefault,
    PTKTextAnimatorTypeWiggle,
};

@interface TRZTextAnimator : NSObject
@property (nonatomic, nonnull) NSAttributedString*                  text;
@property (nonatomic, nonnull) UIColor*                             defaultColor;
@property (nonatomic) PTKTextAnimatorType                           type;
@property (nonatomic) NSInteger                                     wiggleRepeatCount;
@property (nonatomic) CGFloat                                       fractionOfLettersToWiggle;
@property (nonatomic) BOOL                                          centerLayer;
@property (nonatomic,nonnull) NSDictionary<NSNumber*,NSNumber*>*    indexForLettersToWiggle;
@property (nonatomic) NSTimeInterval                                wiggleAnimationDuration;

- (nonnull instancetype) initWithReferenceUIView:(nonnull UIView*)view;
- (void) doAnimationWithCompletion:(void (^_Nullable)(void)) completion;
- (void) show;
- (void) destroy;

@end

