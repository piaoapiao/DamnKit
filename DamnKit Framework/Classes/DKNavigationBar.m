//
//  DKNavigationBar.m
//  DamnKit
//
//  Created by Adrian on 12.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import "DKNavigationBar.h"

#pragma mark Colorspace Conversion

/*
 
 This function converts colors in grayscale colorspace (created
 using [UIColor colorWithWhite:alpha:]) to the proper HSB colorspace,
 so we can perform super-ultra-advanced color corrections and calculations
 by modifying brightness, saturation and opacity.
 
*/

static UIColor * DKHSBCompatibleColor(UIColor *fromColor) {
    
    CGFloat colorOriginalHue, colorOriginalSaturation, colorOriginalBrightness, colorOriginalAlpha;
    BOOL success = [fromColor getHue:&colorOriginalHue saturation:&colorOriginalSaturation brightness:&colorOriginalBrightness alpha:&colorOriginalAlpha];
    
    if(!success) {
        CGFloat colorOriginalWhite;
        BOOL success2 = [fromColor getWhite:&colorOriginalWhite alpha:&colorOriginalAlpha];
        if(success2) {
            colorOriginalHue = 0;
            colorOriginalSaturation = 0;
            colorOriginalBrightness = colorOriginalWhite;
        } else {
            colorOriginalHue = 0;
            colorOriginalSaturation = 0;
            colorOriginalBrightness = 1;
        }
    }
    
    return [UIColor colorWithHue:colorOriginalHue saturation:colorOriginalSaturation brightness:colorOriginalBrightness alpha:colorOriginalAlpha];
    
}

#pragma mark - Metrics Calculation

/*
 
 This function calculates the (most probable) navigation bar
 height based on its position and metrics.
 
 */

static CGFloat DKCalculateNavigationBarHeight(UIBarPosition position, UIBarMetrics metrics) {
    if(position == UIBarPositionAny || position == UIBarPositionTop || position == UIBarPositionBottom) {
        if(metrics == UIBarMetricsDefault) {
            return 44.0f;
        } else if(metrics == UIBarMetricsDefaultPrompt) {
            return 74.0f;
        } else if(metrics == UIBarMetricsLandscapePhone) {
            return 32.0f;
        } else if(metrics == UIBarMetricsLandscapePhonePrompt) {
            return 74.0f;
        } else {
            return 0.0f;
        }
    } else if(position == UIBarPositionTopAttached) {
        CGFloat normalHeight = DKCalculateNavigationBarHeight(UIBarPositionTop, metrics);
        return normalHeight + 20.0f;
    } else {
        return 0.0f;
    }
}

/*
 
 This function calculates most probable bar metrics based on
 the given size of navigatio bar view and its position.
 
*/

static UIBarMetrics DKCalculateNavigationBarMetrics(CGSize navigationBarSize, UIBarPosition barPosition) {
    if(navigationBarSize.height == DKCalculateNavigationBarHeight(barPosition, UIBarMetricsDefault)) {
        return UIBarMetricsDefault;
    } else if(navigationBarSize.height == DKCalculateNavigationBarHeight(barPosition, UIBarMetricsDefaultPrompt)) {
        return UIBarMetricsDefaultPrompt;
    } else if(navigationBarSize.height == DKCalculateNavigationBarHeight(barPosition, UIBarMetricsLandscapePhone)) {
        return UIBarMetricsLandscapePhone;
    } else if(navigationBarSize.height == DKCalculateNavigationBarHeight(barPosition, UIBarMetricsLandscapePhonePrompt)) {
        return UIBarMetricsLandscapePhonePrompt;
    } else {
        return UIBarMetricsDefault;
    }
}

#pragma mark - Rendering

/*
 
 This function is discussed in .h file.
 
*/

UIImage * DKRenderResizableNavigationBarBackgroundImage(NSArray *gradientColors, NSArray *gradientColorLocations, NSArray *topSeparators, NSArray *bottomSeparators) {
    
    // size calculation
    
    CGSize imageSize = CGSizeMake(2.0f, 64.0f);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    
    // convert the arguments to CG-friendly values
    
    CGFloat *floatGradientLocations = malloc(gradientColorLocations.count * sizeof(CGFloat));
    if (floatGradientLocations == NULL) return nil;
    
    [gradientColorLocations enumerateObjectsUsingBlock:^(NSNumber *location, NSUInteger idx, BOOL *stop) {
        floatGradientLocations[idx] = [location floatValue];
    }];
    
    NSMutableArray *cgGradientColors = [NSMutableArray arrayWithCapacity:gradientColors.count];
    
    [gradientColors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        cgGradientColors[idx] = (__bridge id)([color CGColor]);
    }];
    
    // gradient creation
    
    CGColorSpaceRef gradientColorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(gradientColorSpace, (__bridge CFArrayRef)cgGradientColors, floatGradientLocations);
    
    free(floatGradientLocations);
    
    // begin image context
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw gradient
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(imageRect), CGRectGetMinY(imageRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(imageRect), CGRectGetMaxY(imageRect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, imageRect);
    CGContextClip(context);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(gradientColorSpace);
    
    // draw top separators
    
    [topSeparators enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextMoveToPoint(context, CGRectGetMinX(imageRect), CGRectGetMinY(imageRect) + 0.5f + (CGFloat)idx);
        CGContextAddLineToPoint(context, CGRectGetMaxX(imageRect), CGRectGetMinY(imageRect) + 0.5f + (CGFloat)idx);
        CGContextStrokePath(context);
    }];
    
    // draw bottom separators
    
    [bottomSeparators enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextMoveToPoint(context, CGRectGetMinX(imageRect), CGRectGetMaxY(imageRect) - 0.5f - (CGFloat)idx);
        CGContextAddLineToPoint(context, CGRectGetMaxX(imageRect), CGRectGetMaxY(imageRect) - 0.5f - (CGFloat)idx);
        CGContextStrokePath(context);
    }];
    
    // obtain and return the image
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake((CGFloat)(topSeparators.count), 0.0f, (CGFloat)(bottomSeparators.count), 0.0f) resizingMode:UIImageResizingModeStretch];
    
}

/*
 
 This function is discussed in .h file.
 
*/

UIImage * DKRenderResizableNavigationBarShadow(UIColor *shadowColor, CGFloat topColorOpacity, CGFloat shadowHeight) {
    
    // set up colors
    
    UIColor *fixedColor = DKHSBCompatibleColor(shadowColor);
    
    CGFloat colorOriginalHue, colorOriginalSaturation, colorOriginalBrightness, colorOriginalAlpha;
    [fixedColor getHue:&colorOriginalHue saturation:&colorOriginalSaturation brightness:&colorOriginalBrightness alpha:&colorOriginalAlpha];
    
    UIColor *topColor = [UIColor colorWithHue:colorOriginalHue saturation:colorOriginalSaturation brightness:colorOriginalBrightness alpha:topColorOpacity];
    UIColor *bottomColor = [UIColor colorWithRed:colorOriginalHue green:colorOriginalSaturation blue:colorOriginalBrightness alpha:0.000];
    
    // size calculation
    
    CGSize imageSize = CGSizeMake(2.0f, shadowHeight);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    
    // gradient creation
    
    CGFloat gradientLocations[] = {0.0f, 1.0f};
    NSArray *gradientColors = @[ (__bridge id)(topColor.CGColor), (__bridge id)(bottomColor.CGColor) ];
    
    CGColorSpaceRef gradientColorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(gradientColorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    // begin image context
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw gradient
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(imageRect), CGRectGetMinY(imageRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(imageRect), CGRectGetMaxY(imageRect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, imageRect);
    CGContextClip(context);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(gradientColorSpace);
    
    // obtain and return the image
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f) resizingMode:UIImageResizingModeStretch];
    
}

/*
 
 This is an internal function for generating the gradient
 and separator colors based only on the tintColor.
 
*/

static UIImage * DKRenderResizableTintedNavigationBarBackgroundImage(UIColor *tintColor) {
    
    // set up colors
    
    
    UIColor *fixedColor = DKHSBCompatibleColor(tintColor);
    
    CGFloat topOriginalHue, topOriginalSaturation, topOriginalBrightness, topOriginalAlpha;
    [fixedColor getHue:&topOriginalHue saturation:&topOriginalSaturation brightness:&topOriginalBrightness alpha:&topOriginalAlpha];
    
    CGFloat topModifiedHue = topOriginalHue;
    CGFloat topModifiedSaturation = (topOriginalSaturation > 0.2f) ? topOriginalSaturation - 0.2f : 0.0f;
    CGFloat topModifiedBrightness = (topOriginalBrightness < 0.7f) ? topOriginalBrightness + 0.3f : 1.0f;
    CGFloat topModifiedAlpha = (topOriginalAlpha > 0.05f) ? topOriginalAlpha - 0.05f : 0.0f;
    
    UIColor *tintedTopColor = [UIColor colorWithHue:topModifiedHue saturation:topModifiedSaturation brightness:topModifiedBrightness alpha:topModifiedAlpha];
    
    // bottom gradient color
    
    CGFloat bottomOriginalHue, bottomOriginalSaturation, bottomOriginalBrightness, bottomOriginalAlpha;
    [fixedColor getHue:&bottomOriginalHue saturation:&bottomOriginalSaturation brightness:&bottomOriginalBrightness alpha:&bottomOriginalAlpha];
    
    CGFloat bottomModifiedHue = bottomOriginalHue;
    CGFloat bottomModifiedSaturation = bottomOriginalSaturation;
    CGFloat bottomModifiedBrightness = bottomOriginalBrightness;
    CGFloat bottomModifiedAlpha = (bottomOriginalAlpha > 0.15f) ? bottomOriginalAlpha - 0.15f : 0.0f;
    
    UIColor *tintedBottomColor = [UIColor colorWithHue:bottomModifiedHue saturation:bottomModifiedSaturation brightness:bottomModifiedBrightness alpha:bottomModifiedAlpha];
    
    // 1st top separator
    
    CGFloat firstTopSeparatorOriginalHue, firstTopSeparatorOriginalSaturation, firstTopSeparatorOriginalBrightness, firstTopSeparatorOriginalAlpha;
    [fixedColor getHue:&firstTopSeparatorOriginalHue saturation:&firstTopSeparatorOriginalSaturation brightness:&firstTopSeparatorOriginalBrightness alpha:&firstTopSeparatorOriginalAlpha];
    
    CGFloat firstTopSeparatorModifiedHue = firstTopSeparatorOriginalHue;
    CGFloat firstTopSeparatorModifiedSaturation = (firstTopSeparatorOriginalSaturation > 0.3f) ? firstTopSeparatorOriginalSaturation - 0.3f : 0.0f;
    CGFloat firstTopSeparatorModifiedBrightness = (firstTopSeparatorOriginalBrightness < 0.6f) ? firstTopSeparatorOriginalBrightness + 0.6f : 1.0f;
    CGFloat firstTopSeparatorModifiedAlpha = (firstTopSeparatorOriginalAlpha > 0.3f) ? firstTopSeparatorOriginalAlpha - 0.3f : 1.0f;
    
    UIColor *tintedFirstTopSeparatorColor = [UIColor colorWithHue:firstTopSeparatorModifiedHue saturation:firstTopSeparatorModifiedSaturation brightness:firstTopSeparatorModifiedBrightness alpha:firstTopSeparatorModifiedAlpha];
    
    // 1st bottom separator (light)
    
    CGFloat firstBottomSeparatorOriginalHue, firstBottomSeparatorOriginalSaturation, firstBottomSeparatorOriginalBrightness, firstBottomSeparatorOriginalAlpha;
    [fixedColor getHue:&firstBottomSeparatorOriginalHue saturation:&firstBottomSeparatorOriginalSaturation brightness:&firstBottomSeparatorOriginalBrightness alpha:&firstBottomSeparatorOriginalAlpha];
    
    CGFloat firstBottomSeparatorModifiedHue = firstBottomSeparatorOriginalHue;
    CGFloat firstBottomSeparatorModifiedSaturation = (firstBottomSeparatorOriginalSaturation > 0.4f) ? firstBottomSeparatorOriginalSaturation - 0.4f : 0.0f;
    CGFloat firstBottomSeparatorModifiedBrightness = (firstBottomSeparatorOriginalBrightness < 0.6f) ? firstBottomSeparatorOriginalBrightness + 0.4f : 1.0f;
    CGFloat firstBottomSeparatorModifiedAlpha = (firstBottomSeparatorOriginalAlpha > 0.55f) ? firstBottomSeparatorOriginalAlpha - 0.55f : 0.0f;
    
    UIColor *tintedFirstBottomSeparatorColor = [UIColor colorWithHue:firstBottomSeparatorModifiedHue saturation:firstBottomSeparatorModifiedSaturation brightness:firstBottomSeparatorModifiedBrightness alpha:firstBottomSeparatorModifiedAlpha];
    
    // 2nd bottom separator (dark)
    
    CGFloat secondBottomSeparatorOriginalHue, secondBottomSeparatorOriginalSaturation, secondBottomSeparatorOriginalBrightness, secondBottomSeparatorOriginalAlpha;
    [fixedColor getHue:&secondBottomSeparatorOriginalHue saturation:&secondBottomSeparatorOriginalSaturation brightness:&secondBottomSeparatorOriginalBrightness alpha:&secondBottomSeparatorOriginalAlpha];
    
    CGFloat secondBottomSeparatorModifiedHue = secondBottomSeparatorOriginalHue;
    CGFloat secondBottomSeparatorModifiedSaturation = secondBottomSeparatorOriginalSaturation;
    CGFloat secondBottomSeparatorModifiedBrightness = (secondBottomSeparatorOriginalBrightness > 0.4f) ? secondBottomSeparatorOriginalBrightness - 0.4f : 0.0f;
    CGFloat secondBottomSeparatorModifiedAlpha = (secondBottomSeparatorOriginalAlpha > 0.2f) ? secondBottomSeparatorOriginalAlpha - 0.2f : 0.0f;
    
    UIColor *tintedSecondBottomSeparatorColor = [UIColor colorWithHue:secondBottomSeparatorModifiedHue saturation:secondBottomSeparatorModifiedSaturation brightness:secondBottomSeparatorModifiedBrightness alpha:secondBottomSeparatorModifiedAlpha];
    
    // obtain and return the image
    
    UIImage *image = DKRenderResizableNavigationBarBackgroundImage(@[ tintedTopColor, tintedBottomColor ], @[ @(0.1f), @(1.0f) ], @[ tintedFirstTopSeparatorColor ], @[ tintedSecondBottomSeparatorColor, tintedFirstBottomSeparatorColor ]);
    
    return image;
    
}

#pragma mark - 


@interface DKNavigationBar ()

@property UINavigationBar *storageNavigationBar;

@property UIImageView *customlyAddedBackgroundImageView;

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force;
- (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force;

- (void)setBarTintColor:(UIColor *)barTintColor usingForce:(BOOL)force;
- (UIColor *)barTintColorUsingForce:(BOOL)force;

- (void)fixShadowImageViewBackgroundColor;

- (void)setNeedsUpdateAppearance;

- (void)prepareForSuperLayoutSubviews;

- (void)applyInitialChangesInNavigationBarAppearance;
- (void)applyChangesInNavigationBarStructure;
- (void)applyDefaultAppearance;

- (void)generateAndApplyNewDefaultBackgroundImagesWithTintColor:(UIColor *)color;

@end

#pragma mark - 

@implementation DKNavigationBar

#pragma mark Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    // create the storage nav bar
    
    self.storageNavigationBar = [[UINavigationBar alloc] initWithFrame:frame];
    
    // do some initial work and set the defaults
    
    [self applyInitialChangesInNavigationBarAppearance];
    [self applyDefaultAppearance];
    
    return self;
}

#pragma mark - Appearance Application & Storage

/*
 
 Applying background image to the 'live' instance of DKNavigationBar will result
 in no ability to control the navigation bar opacity and translucency levels.
 
 That's why those images must be stored in a separate UINavigationBar.
 
 If that behavior (no way to increase translucent navigation bar's alpha)
 will change in the future releases, the below methods may be modified/removed.
 
 As of iOS 7 Beta 1 (11A4372q) there was no change of that behavior.
 
*/

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundImage:backgroundImage forBarPosition:barPosition barMetrics:barMetrics usingForce:NO];
}

- (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return [self backgroundImageForBarPosition:barPosition barMetrics:barMetrics usingForce:NO];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force {
    if(force) {
        [super setBackgroundImage:backgroundImage forBarPosition:barPosition barMetrics:barMetrics];
    } else {
        
        [self.storageNavigationBar setBackgroundImage:backgroundImage forBarPosition:barPosition barMetrics:barMetrics];
        
        [self setNeedsUpdateAppearance];
    }
}

- (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force {
    if(force) {
        return [super backgroundImageForBarPosition:barPosition barMetrics:barMetrics];
    } else {
        return [self.storageNavigationBar backgroundImageForBarPosition:barPosition barMetrics:barMetrics];
    }
}

/*
 
 The below methods are here to make sure that tint colors are set
 to the 'storing' navigation bar, because self requires some tweaks
 and forbids setting tintColor and barTintColor to itself.
 
 Again, if the behavior of control over the opacity will change in future
 releases, these methods (along with storage instance) may be modified/removed.
 
*/

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self setBarTintColor:barTintColor usingForce:NO];
}

- (UIColor *)barTintColor {
    return [self barTintColorUsingForce:NO];
}

- (void)setBarTintColor:(UIColor *)barTintColor usingForce:(BOOL)force {
    if(force) {
        [super setBarTintColor:barTintColor];
    } else {
        [self.storageNavigationBar setBarTintColor:barTintColor];
        [self generateAndApplyNewDefaultBackgroundImagesWithTintColor:barTintColor];
        [self setNeedsUpdateAppearance];
    }
}

- (UIColor *)barTintColorUsingForce:(BOOL)force {
    if(force) {
        return [super barTintColor];
    } else {
        return [self.storageNavigationBar barTintColor];
    }
}

#pragma mark - Shadow Image View Fix

/*
 
 There is a bug in UINavigationBar, which displays the shadowImage in a
 UIImageView, which has backgroundColor set to [UIColor colorWithWhite:0 alpha:0.3]
 by default and this imageView can't be accessed via the standard API.
 
 If this bug is fixed in the future releases, the below method will be removed.
 
 As of iOS 7 Beta 1 (11A4372q) the bug is present.
 
*/

- (void)fixShadowImageViewBackgroundColor {
    
    // some defentive checks
    
    if(self.subviews.count > 0) {
        UIView *navigationBarBackgroundView = self.subviews[0];
        if([navigationBarBackgroundView isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            if(navigationBarBackgroundView.subviews.count > 1) {
                UIImageView *shadowImageView = navigationBarBackgroundView.subviews[1];
                if([shadowImageView isKindOfClass:NSClassFromString(@"UIImageView")]) {
                    [shadowImageView setBackgroundColor:[UIColor clearColor]];
                }
            }
        }
    }
    
}

#pragma mark - Applying Changes

- (void)setNeedsUpdateAppearance {
    
    // remove all added stuff, we'll add it in a second
    [self prepareForSuperLayoutSubviews];
    
    // and add the changes again
    [self applyChangesInNavigationBarStructure];
    
}

- (void)prepareForSuperLayoutSubviews {
    [self.customlyAddedBackgroundImageView removeFromSuperview];
}

/*
 
 Here's the tricky code. It inserts a new instance of UIImageView below all
 subviews of _UINavigationBarBackground (a private view responsible for
 displaying the navigation bar background).
 
 Since the navigation bar has no visible background (see -applyInitialChangesInNavigationBarAppearance),
 it gets displayed right below the navigation bar subviews.
 
 The next thing it does, it sets the real barTintColor to the UIColor with
 pattern image identical to the real background image. It's this code which
 allows the navigation bar to be translucent.
 
 In other words, setting barTintColor to [UIColor colorWithPattern:] allows
 the bar to be translucent and artificially adding a custom UIImageView below
 all subviews gives us control over the bar's opacity.
 
 And again, if the ability to control the opacity will be added in the future,
 there may be no need to dangerously play with the navigation bar's structure
 and this method (along with some others) may me modified/removed.
 
*/

- (void)applyChangesInNavigationBarStructure {
    
    UIBarPosition currentBarPosition = self.barPosition;
    UIBarMetrics currentBarMetrics = DKCalculateNavigationBarMetrics(self.bounds.size, currentBarPosition);
    
    UIImage *realBackgroundImage = [self backgroundImageForBarPosition:currentBarPosition barMetrics:currentBarMetrics usingForce:NO];
    
    self.customlyAddedBackgroundImageView = nil;
    self.customlyAddedBackgroundImageView = [[UIImageView alloc] initWithFrame:[((UIView *)([self subviews][0])) bounds]];
    self.customlyAddedBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.customlyAddedBackgroundImageView.image = realBackgroundImage;
    self.customlyAddedBackgroundImageView.opaque = NO;
    
    // here's what i was talking about
    
    [self setBarTintColor:[UIColor colorWithPatternImage:realBackgroundImage] usingForce:YES];
    
    // some defensive checks would be a great idea in a beta software
    
    if(self.subviews.count > 0) {
        UIView *navigationBarBackgroundView = self.subviews[0];
        if([navigationBarBackgroundView isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            if(navigationBarBackgroundView.subviews.count > 0) {
                UIImageView *shadowImageView = navigationBarBackgroundView.subviews[0];
                if([shadowImageView isKindOfClass:NSClassFromString(@"UIImageView")]) {
                    [navigationBarBackgroundView insertSubview:self.customlyAddedBackgroundImageView belowSubview:shadowImageView];
                }
            } else {
                [navigationBarBackgroundView insertSubview:self.customlyAddedBackgroundImageView atIndex:0];
            }
        }
    }
    
    [self fixShadowImageViewBackgroundColor];
    
}

/*
 
 Modify the navigation bar before further usage.
 
*/

- (void)applyInitialChangesInNavigationBarAppearance {
    
    // set an empty background image for all metrics
    
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault usingForce:YES];
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefaultPrompt usingForce:YES];
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhone usingForce:YES];
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhonePrompt usingForce:YES];
    
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault usingForce:YES];
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefaultPrompt usingForce:YES];
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsLandscapePhone usingForce:YES];
    [self setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsLandscapePhonePrompt usingForce:YES];
    
}

/*
 
 This methods recreates the background image based
 on the new tint color.
 
*/

- (void)generateAndApplyNewDefaultBackgroundImagesWithTintColor:(UIColor *)color {
    
    UIImage *newResizableBackgroundImage = DKRenderResizableTintedNavigationBarBackgroundImage(color);
    
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefaultPrompt usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhone usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhonePrompt usingForce:NO];
    
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefaultPrompt usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsLandscapePhone usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsLandscapePhonePrompt usingForce:NO];
    
}

/*
 
 This methods creates and applies default colors
 and images to the navigation bar.
 
*/

- (void)applyDefaultAppearance {
    
    // set up the default colors
    
    UIColor *defaultBarTintColor = [UIColor colorWithWhite:0.950 alpha:1.000];
    UIColor *defaultTintColor = [UIColor colorWithHue:0.571 saturation:0.107 brightness:0.514 alpha:1.000];
    
    CGFloat defaultShadowImageTopColorOpacity = 0.1f;
    CGFloat defaultShadowImageHeight = 3.0f;
    
    // set title text attributes
    
    UIColor *defaultTitleTextGrayColor = defaultTintColor;
    
    NSShadow *defaultTitleTextWhiteShadow = [[NSShadow alloc] init];
    [defaultTitleTextWhiteShadow setShadowColor:[UIColor colorWithWhite:1.000 alpha:0.900]];
    [defaultTitleTextWhiteShadow setShadowOffset:CGSizeMake(0, 1)];
    
    UIFont *defaultTitleTextBoldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    
    [self setTitleTextAttributes:@{ NSFontAttributeName : defaultTitleTextBoldFont,
                                    NSForegroundColorAttributeName : defaultTitleTextGrayColor,
                                    NSShadowAttributeName : defaultTitleTextWhiteShadow }];
    
    // set tint colors
    
    [self setTintColor:defaultTintColor];
    [self setBarTintColor:defaultBarTintColor usingForce:NO];
    
    // set default shadow image
    
    UIImage *defaultShadowImage = DKRenderResizableNavigationBarShadow([UIColor blackColor], defaultShadowImageTopColorOpacity, defaultShadowImageHeight);
    
    [self setShadowImage:defaultShadowImage];
    
    // set translucent
    
    [self setTranslucent:YES];
    
}

/*
 
 In case of any layout changes, re-modify the navigation bar structure.
 
*/

- (void)layoutSubviews {
    
    // remove all added stuff, we'll add it in a second
    [self prepareForSuperLayoutSubviews];
    
    // properly layout subviews
    [super layoutSubviews];
    
    // and add the changes again
    [self applyChangesInNavigationBarStructure];
    
}

@end
