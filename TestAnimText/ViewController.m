//
//  ViewController.m
//  TestAnimText
//
//  Created by Fernando Pereira on 10/11/17.
//  Copyright © 2017 Troezen. All rights reserved.
//

#import "ViewController.h"
#import "TRZTextAnimator.h"
@import CoreText;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *test1;

@property (nonatomic) TRZTextAnimator* animator1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.animator1 show];

}

- (TRZTextAnimator*) animator1 {
    if ( !_animator1 ) {
        _animator1 = [[TRZTextAnimator alloc] initWithReferenceUIView:self.test1];
        UIFont* font = [UIFont systemFontOfSize:75.0];
        
        NSArray *fontFeatureSettings = @[
                                         @{UIFontFeatureTypeIdentifierKey: @(kStylisticAlternativesType),
                                           UIFontFeatureSelectorIdentifierKey: @(2)},
                                         @{UIFontFeatureTypeIdentifierKey: @(kContextualAlternatesType),
                                           UIFontFeatureSelectorIdentifierKey: @(0)},
                                         ];
        
#ifdef DEBUG
        [ViewController logFont:font];
#endif
        UIFontDescriptor *originalDescriptor = [font fontDescriptor];
        UIFontDescriptor *alternateDescriptor = [originalDescriptor fontDescriptorByAddingAttributes:@{UIFontDescriptorFeatureSettingsAttribute:fontFeatureSettings}];
        
        UIFont *altFont = [UIFont fontWithDescriptor:alternateDescriptor size:font.pointSize];
        NSAttributedString* str = [[NSAttributedString alloc] initWithString:@"Welcome"
                                                                  attributes:@{NSFontAttributeName:altFont, NSForegroundColorAttributeName:[UIColor blueColor]}];
        _animator1.text = str;
        _animator1.wiggleRepeatCount = 5;
    }
    return _animator1;
}


- (IBAction)doStart:(id)sender {
    [sender setHidden:YES];
    [self.animator1 doAnimationWithCompletion:^{
        [sender setHidden:NO];
    }];
}

- (IBAction)modeChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    if ( control.selectedSegmentIndex == 0 ) {
        self.animator1.type = PTKTextAnimatorTypeDefault;
    } else {
        self.animator1.type = PTKTextAnimatorTypeWiggle;
    }
}

+ (void) logFont:(UIFont*)font {
    CFArrayRef arr = CTFontCopyFeatures((__bridge CTFontRef)font);
    NSLog(@"Array =%@",arr);
}

@end
