//
//  AppDelegate.m
//  TestAnimText
//
//  Created by Fernando Pereira on 10/11/17.
//  Copyright © 2017 Troezen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

/*

CTLineRef line = CTLineCreateWithAttributedString( attStr ) ;

CFArrayRef runArray = CTLineGetGlyphRuns(line);

//&lt;/span /> for each RUN
&lt;/span />for&lt;/span /> (CFIndex runIndex = 0&lt;/span />; runIndex &lt;&lt;/span /> CFArrayGetCount(runArray); runIndex++)
{
    //&lt;/span /> Get FONT for this run
    &lt;/span />   CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
    CTFontRef runFont =
    CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
    
    //&lt;/span /> for each GLYPH in run
    &lt;/span />   for&lt;/span /> (CFIndex runGlyphIndex = 0&lt;/span />;
                                    runGlyphIndex &lt;&lt;/span /> CTRunGetGlyphCount(run); runGlyphIndex++)
    {
        //&lt;/span /> get Glyph & Glyph-data
        &lt;/span />        CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1&lt;/span />);
        CGGlyph glyph;
        CGPoint position;
        CTRunGetGlyphs(run, thisGlyphRange, &glyph);
        CTRunGetPositions(run, thisGlyphRange, &position);
        
        //&lt;/span /> Render it
        &lt;/span />        {
            CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
            
            CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
            CGContextSetTextMatrix(X, textMatrix);
            
            CGContextSetFont(X, cgFont);
            CGContextSetFontSize(X, CTFontGetSize(runFont));
            CGContextSetRGBFillColor(X, 1&lt;/span />.0&lt;/span />, 1&lt;/span />.0&lt;/span />, 1&lt;/span />.0&lt;/span />, 0&lt;/span />.5&lt;/span />);
            CGContextShowGlyphsAtPositions(X, &glyph, &position, 1&lt;/span />);
            CFRelease(cgFont);
        }
        
        //&lt;/span /> Get PATH of outline & stroke outline
        &lt;/span />        {
            CGPathRef path = CTFontCreatePathForGlyph(runFont, glyph, NULL);
            CGMutablePathRef pT = CGPathCreateMutable();
            CGAffineTransform T =
            CGAffineTransformMakeTranslation(position.x, position.y);
            CGPathAddPath(pT, &T, path);
            
            CGContextAddPath(X, pT);
            CGContextSetStrokeColorWithColor(X, [UIColor yellowColor].CGColor);
            CGContextSetLineWidth(X, atLeastOnePixel);
            CGContextStrokePath(X);
            CGPathRelease(path);
            CGPathRelease(pT);
        }
        
        //&lt;/span /> draw blue bounding box
        &lt;/span />        {
            CGRect glyphRect = CTRunGetImageBounds(run, X, thisGlyphRange);
            
            CGContextSetLineWidth(X, atLeastOnePixel);
            CGContextSetStrokeColorWithColor(X, [UIColor blueColor ].CGColor);
            CGContextStrokeRect(X, glyphRect);
        }
        
        //&lt;/span /> release things
        &lt;/span />   }
}
CFRelease(line);
 
 */
