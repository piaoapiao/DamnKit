//
//  DKToolbar.m
//  DamnKit
//
//  Created by Adrian on 16.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import "DKToolbar.h"

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
 
 This function calculates the (most probable) toolbar
 size based on its position and metrics.
 
*/

static CGFloat DKCalculateToolbarHeight(UIBarPosition position, UIBarMetrics metrics) {
    if(position == UIBarPositionAny || position == UIBarPositionTop || position == UIBarPositionBottom) {
        if(metrics == UIBarMetricsDefault) {
            return 44.0f;
        } else if(metrics == UIBarMetricsLandscapePhone) {
            return 32.0f;
        } else {
            return 0.0f;
        }
    } else {
        return 0.0f;
    }
}

/*
 
 This function calculates most probable bar metrics based on
 the given size of navigatio bar view and its position.
 
*/

static UIBarMetrics DKCalculateToolbarMetrics(CGSize toolbarSize, UIBarPosition barPosition) {
    if(toolbarSize.height == DKCalculateToolbarHeight(barPosition, UIBarMetricsDefault)) {
        return UIBarMetricsDefault;
    } else if(toolbarSize.height == DKCalculateToolbarHeight(barPosition, UIBarMetricsLandscapePhone)) {
        return UIBarMetricsLandscapePhone;
    } else {
        return UIBarMetricsDefault;
    }
}

#pragma mark - Rendering

/*
 
 This function is discussed in .h file.
 
*/

UIImage * DKRenderResizableToolbarBackgroundImage(NSArray *gradientColors, NSArray *gradientColorLocations, NSArray *topSeparators, NSArray *bottomSeparators) {
    
    // size calculation
    
    CGSize imageSize = CGSizeMake(2, 44);
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
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
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, CGRectGetMinX(imageRect), CGRectGetMinY(imageRect) + 0.5 + idx);
        CGContextAddLineToPoint(context, CGRectGetMaxX(imageRect), CGRectGetMinY(imageRect) + 0.5 + idx);
        CGContextStrokePath(context);
    }];
    
    // draw bottom separators
    
    [bottomSeparators enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, CGRectGetMinX(imageRect), CGRectGetMaxY(imageRect) - 0.5 - idx);
        CGContextAddLineToPoint(context, CGRectGetMaxX(imageRect), CGRectGetMaxY(imageRect) - 0.5 - idx);
        CGContextStrokePath(context);
    }];
    
    // obtain and return the image
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake((CGFloat)(topSeparators.count), 0, (CGFloat)(bottomSeparators.count), 0) resizingMode:UIImageResizingModeStretch];
    
}

/*
 
 This function is discussed in .h file.
 
*/

UIImage * DKRenderResizableToolbarShadow(UIColor *shadowColor, CGFloat bottomColorOpacity, CGFloat shadowHeight) {
    
    // set up colors
    
    UIColor *fixedColor = DKHSBCompatibleColor(shadowColor);
    
    CGFloat colorOriginalHue, colorOriginalSaturation, colorOriginalBrightness, colorOriginalAlpha;
    [fixedColor getHue:&colorOriginalHue saturation:&colorOriginalSaturation brightness:&colorOriginalBrightness alpha:&colorOriginalAlpha];
    
    UIColor *topColor = [UIColor colorWithRed:colorOriginalHue green:colorOriginalSaturation blue:colorOriginalBrightness alpha:0.000];
    UIColor *bottomColor = [UIColor colorWithHue:colorOriginalHue saturation:colorOriginalSaturation brightness:colorOriginalBrightness alpha:bottomColorOpacity];
    
    // size calculation
    
    CGSize imageSize = CGSizeMake(2, shadowHeight);
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    // gradient creation
    
    CGFloat gradientLocations[] = {0.0, 1.0};
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
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    
}

/*
 
 This is an internal function for generating the gradient
 and separator colors based only on the tintColor.
 
*/

static UIImage * DKRenderResizableTintedToolbarBackgroundImage(UIColor *tintColor) {
    
    // set up colors
    
    
    UIColor *fixedColor = DKHSBCompatibleColor(tintColor);
    
    CGFloat topOriginalHue, topOriginalSaturation, topOriginalBrightness, topOriginalAlpha;
    [fixedColor getHue:&topOriginalHue saturation:&topOriginalSaturation brightness:&topOriginalBrightness alpha:&topOriginalAlpha];
    
    CGFloat topModifiedHue = topOriginalHue;
    CGFloat topModifiedSaturation = (topOriginalSaturation > 0.2) ? topOriginalSaturation - 0.2 : 0.0;
    CGFloat topModifiedBrightness = (topOriginalBrightness < 0.7) ? topOriginalBrightness + 0.3 : 1.0;
    CGFloat topModifiedAlpha = (topOriginalAlpha > 0.05) ? topOriginalAlpha - 0.05 : 0.0;
    
    UIColor *tintedTopColor = [UIColor colorWithHue:topModifiedHue saturation:topModifiedSaturation brightness:topModifiedBrightness alpha:topModifiedAlpha];
    
    // bottom gradient color
    
    CGFloat bottomOriginalHue, bottomOriginalSaturation, bottomOriginalBrightness, bottomOriginalAlpha;
    [fixedColor getHue:&bottomOriginalHue saturation:&bottomOriginalSaturation brightness:&bottomOriginalBrightness alpha:&bottomOriginalAlpha];
    
    CGFloat bottomModifiedHue = bottomOriginalHue;
    CGFloat bottomModifiedSaturation = bottomOriginalSaturation;
    CGFloat bottomModifiedBrightness = bottomOriginalBrightness;
    CGFloat bottomModifiedAlpha = (bottomOriginalAlpha > 0.15) ? bottomOriginalAlpha - 0.15 : 0.0;
    
    UIColor *tintedBottomColor = [UIColor colorWithHue:bottomModifiedHue saturation:bottomModifiedSaturation brightness:bottomModifiedBrightness alpha:bottomModifiedAlpha];
    
    // 1st top separator
    
    CGFloat firstTopSeparatorOriginalHue, firstTopSeparatorOriginalSaturation, firstTopSeparatorOriginalBrightness, firstTopSeparatorOriginalAlpha;
    [fixedColor getHue:&firstTopSeparatorOriginalHue saturation:&firstTopSeparatorOriginalSaturation brightness:&firstTopSeparatorOriginalBrightness alpha:&firstTopSeparatorOriginalAlpha];
    
    CGFloat firstTopSeparatorModifiedHue = firstTopSeparatorOriginalHue;
    CGFloat firstTopSeparatorModifiedSaturation = (firstTopSeparatorOriginalSaturation > 0.3) ? firstTopSeparatorOriginalSaturation - 0.3 : 0.0;
    CGFloat firstTopSeparatorModifiedBrightness = (firstTopSeparatorOriginalBrightness < 0.6) ? firstTopSeparatorOriginalBrightness + 0.6 : 1.0;
    CGFloat firstTopSeparatorModifiedAlpha = (firstTopSeparatorOriginalAlpha > 0.3) ? firstTopSeparatorOriginalAlpha - 0.3 : 1.0;
    
    UIColor *tintedFirstTopSeparatorColor = [UIColor colorWithHue:firstTopSeparatorModifiedHue saturation:firstTopSeparatorModifiedSaturation brightness:firstTopSeparatorModifiedBrightness alpha:firstTopSeparatorModifiedAlpha];
    
    // 1st bottom separator (light)
    
    CGFloat firstBottomSeparatorOriginalHue, firstBottomSeparatorOriginalSaturation, firstBottomSeparatorOriginalBrightness, firstBottomSeparatorOriginalAlpha;
    [fixedColor getHue:&firstBottomSeparatorOriginalHue saturation:&firstBottomSeparatorOriginalSaturation brightness:&firstBottomSeparatorOriginalBrightness alpha:&firstBottomSeparatorOriginalAlpha];
    
    CGFloat firstBottomSeparatorModifiedHue = firstBottomSeparatorOriginalHue;
    CGFloat firstBottomSeparatorModifiedSaturation = (firstBottomSeparatorOriginalSaturation > 0.4) ? firstBottomSeparatorOriginalSaturation - 0.4 : 0.0;
    CGFloat firstBottomSeparatorModifiedBrightness = (firstBottomSeparatorOriginalBrightness < 0.6) ? firstBottomSeparatorOriginalBrightness + 0.4 : 1.0;
    CGFloat firstBottomSeparatorModifiedAlpha = (firstBottomSeparatorOriginalAlpha > 0.55) ? firstBottomSeparatorOriginalAlpha - 0.55 : 0.0;
    
    UIColor *tintedFirstBottomSeparatorColor = [UIColor colorWithHue:firstBottomSeparatorModifiedHue saturation:firstBottomSeparatorModifiedSaturation brightness:firstBottomSeparatorModifiedBrightness alpha:firstBottomSeparatorModifiedAlpha];
    
    // 2nd bottom separator (dark)
    
    CGFloat secondBottomSeparatorOriginalHue, secondBottomSeparatorOriginalSaturation, secondBottomSeparatorOriginalBrightness, secondBottomSeparatorOriginalAlpha;
    [fixedColor getHue:&secondBottomSeparatorOriginalHue saturation:&secondBottomSeparatorOriginalSaturation brightness:&secondBottomSeparatorOriginalBrightness alpha:&secondBottomSeparatorOriginalAlpha];
    
    CGFloat secondBottomSeparatorModifiedHue = secondBottomSeparatorOriginalHue;
    CGFloat secondBottomSeparatorModifiedSaturation = secondBottomSeparatorOriginalSaturation;
    CGFloat secondBottomSeparatorModifiedBrightness = (secondBottomSeparatorOriginalBrightness > 0.4) ? secondBottomSeparatorOriginalBrightness - 0.4 : 0.0;
    CGFloat secondBottomSeparatorModifiedAlpha = (secondBottomSeparatorOriginalAlpha > 0.2) ? secondBottomSeparatorOriginalAlpha - 0.2 : 0.0;
    
    UIColor *tintedSecondBottomSeparatorColor = [UIColor colorWithHue:secondBottomSeparatorModifiedHue saturation:secondBottomSeparatorModifiedSaturation brightness:secondBottomSeparatorModifiedBrightness alpha:secondBottomSeparatorModifiedAlpha];
    
    // obtain and return the image
    
    UIImage *image = DKRenderResizableToolbarBackgroundImage(@[ tintedTopColor, tintedBottomColor ], @[ @(0.1), @(1.0) ], @[ tintedSecondBottomSeparatorColor, tintedFirstBottomSeparatorColor ], @[ tintedFirstTopSeparatorColor ]);
    
    return image;
    
}

#pragma mark -


@interface DKToolbar ()

@property UIToolbar *storageToolbar;

@property UIImageView *customlyAddedBackgroundImageView;
@property UIImageView *customlyAddedShadowImageView;

- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force;
- (UIImage *)backgroundImageForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force;

- (void)setBarTintColor:(UIColor *)barTintColor usingForce:(BOOL)force;
- (UIColor *)barTintColorUsingForce:(BOOL)force;

- (void)removeNativeSeparatorAndDisplayShadowImageView;

- (void)setNeedsUpdateAppearance;

- (void)prepareForSuperLayoutSubviews;

- (void)applyInitialChangesInToolbarAppearance;
- (void)applyChangesInToolbarStructure;
- (void)applyDefaultAppearance;

- (void)generateAndApplyNewDefaultBackgroundImagesWithTintColor:(UIColor *)color;

- (void)refreshCustomlyAddedShadowImageView;

@end

#pragma mark -

@implementation DKToolbar

#pragma mark Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    // create the storage nav bar
    
    self.storageToolbar = [[UIToolbar alloc] initWithFrame:frame];
    
    // do some initial work and set the defaults
    
    [self applyInitialChangesInToolbarAppearance];
    [self applyDefaultAppearance];
    
    return self;
}

#pragma mark - Appearance Application & Storage

/*
 
 Applying background image to the 'live' instance of DKToolbar will result
 in no ability to control the toolbar opacity and translucency levels.
 
 That's why those images must be stored in a separate UIToolbar.
 
 If that behavior (no way to increase translucent toolbar's alpha)
 will change in the future releases, the below methods may be modified/removed.
 
 As of iOS 7 Beta 1 (11A4372q) there was no change of that behavior.
 
*/

- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundImage:backgroundImage forToolbarPosition:barPosition barMetrics:barMetrics usingForce:NO];
}

- (UIImage *)backgroundImageForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return [self backgroundImageForToolbarPosition:barPosition barMetrics:barMetrics usingForce:NO];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force {
    if(force) {
        [super setBackgroundImage:backgroundImage forToolbarPosition:barPosition barMetrics:barMetrics];
    } else {
        
        [self.storageToolbar setBackgroundImage:backgroundImage forToolbarPosition:barPosition barMetrics:barMetrics];
        
        [self setNeedsUpdateAppearance];
    }
}

- (UIImage *)backgroundImageForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics usingForce:(BOOL)force {
    if(force) {
        return [super backgroundImageForToolbarPosition:barPosition barMetrics:barMetrics];
    } else {
        return [self.storageToolbar backgroundImageForToolbarPosition:barPosition barMetrics:barMetrics];
    }
}

/*
 
 The below methods are here to make sure that tint colors are set
 to the 'storing' toolbar, because self requires some tweaks
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
        [self.storageToolbar setBarTintColor:barTintColor];
        [self generateAndApplyNewDefaultBackgroundImagesWithTintColor:barTintColor];
        [self setNeedsUpdateAppearance];
    }
}

- (UIColor *)barTintColorUsingForce:(BOOL)force {
    if(force) {
        return [super barTintColor];
    } else {
        return [self.storageToolbar barTintColor];
    }
}

#pragma mark - Shadow Image View Fix

/*
 
 There is a bug in UIToolbar, which doesn't display the shadow image
 UIImageView, and leaving the native separator instead. I've filled a
 bug report and Apple seems to working on a fix.
 
 If this bug is fixed in the future releases, the below method will be removed.
 
 As of iOS 7 Beta 1 (11A4372q) the bug is present.
 
*/

- (void)removeNativeSeparatorAndDisplayShadowImageView {
    
    // defensive code doesn't harm
    
    if(self.customlyAddedShadowImageView.superview == nil) {
        if(self.subviews.count > 1) {
            UIView *separatorView = self.subviews[1];
            if(CGRectEqualToRect(separatorView.frame, CGRectMake(0, -0.5, 320, 0.5))) {
                [separatorView removeFromSuperview];
            }
            UIView *toolbarBackgroundView = self.subviews[0];
            if([toolbarBackgroundView isKindOfClass:NSClassFromString(@"_UIToolbarBackground")]) {
                if(toolbarBackgroundView.subviews.count > 1) {
                    UIView *possibleShadowImageView = toolbarBackgroundView.subviews[1];
                    if(![possibleShadowImageView isKindOfClass:[UIImageView class]]) {
                        UIImage *shadowImage = [self shadowImageForToolbarPosition:self.barPosition];
                        self.customlyAddedShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (shadowImage.size.height)*(-1), self.bounds.size.width, shadowImage.size.height)];
                        [self.customlyAddedShadowImageView setImage:shadowImage];
                        [toolbarBackgroundView addSubview:self.customlyAddedShadowImageView];
                    }
                } else {
                    UIImage *shadowImage = [self shadowImageForToolbarPosition:self.barPosition];
                    self.customlyAddedShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (shadowImage.size.height)*(-1), self.bounds.size.width, shadowImage.size.height)];
                    [self.customlyAddedShadowImageView setImage:shadowImage];
                    [toolbarBackgroundView addSubview:self.customlyAddedShadowImageView];
                }
            }
        }
    }
    
}

- (void)setShadowImage:(UIImage *)shadowImage forToolbarPosition:(UIBarPosition)topOrBottom {
    [super setShadowImage:shadowImage forToolbarPosition:topOrBottom];
    [self refreshCustomlyAddedShadowImageView];
}

- (void)refreshCustomlyAddedShadowImageView {
    UIImage *newImage = [self shadowImageForToolbarPosition:self.barPosition];
    [self.customlyAddedShadowImageView setImage:newImage];
    [self.customlyAddedShadowImageView setFrame:CGRectMake(0, (newImage.size.height)*(-1), self.bounds.size.width, newImage.size.height)];
}

#pragma mark - Applying Changes

- (void)setNeedsUpdateAppearance {
    
    // remove all added stuff, we'll add it in a second
    [self prepareForSuperLayoutSubviews];
    
    // and add the changes again
    [self applyChangesInToolbarStructure];
    
    // refresh the shadow image view
    [self refreshCustomlyAddedShadowImageView];
    
}

- (void)prepareForSuperLayoutSubviews {
    [self.customlyAddedBackgroundImageView removeFromSuperview];
    [self.customlyAddedShadowImageView removeFromSuperview];
}

/*
 
 Here's the tricky code. It inserts a new instance of UIImageView below all
 subviews of _UIToolbarBackground (a private view responsible for
 displaying the toolbar background).
 
 Since the toolbar has no visible background (see -applyInitialChangesInToolbarAppearance),
 it gets displayed right below the toolbar subviews.
 
 The next thing it does, it sets the real barTintColor to the UIColor with
 pattern image identical to the real background image. It's this code which
 allows the toolbar to be translucent.
 
 In other words, setting barTintColor to [UIColor colorWithPattern:] allows
 the bar to be translucent and artificially adding a custom UIImageView below
 all subviews gives us control over the bar's opacity.
 
 And again, if the ability to control the opacity will be added in the future,
 there may be no need to dangerously play with the toolbar's structure
 and this method (along with some others) may me modified/removed.
 
*/

- (void)applyChangesInToolbarStructure {
    
    UIBarPosition currentBarPosition = self.barPosition;
    UIBarMetrics currentBarMetrics = DKCalculateToolbarMetrics(self.bounds.size, currentBarPosition);
    
    UIImage *realBackgroundImage = [self backgroundImageForToolbarPosition:currentBarPosition barMetrics:currentBarMetrics usingForce:NO];
    
    self.customlyAddedBackgroundImageView = nil;
    self.customlyAddedBackgroundImageView = [[UIImageView alloc] initWithFrame:[((UIView *)([self subviews][0])) bounds]];
    self.customlyAddedBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.customlyAddedBackgroundImageView.image = realBackgroundImage;
    self.customlyAddedBackgroundImageView.opaque = NO;
    
    // here's what i was talking about
    
    [self setBarTintColor:[UIColor colorWithPatternImage:realBackgroundImage] usingForce:YES];
    
    // some defensive checks would be a great idea in a beta software
    
    if(self.subviews.count > 0) {
        UIView *toolbarBackgroundView = self.subviews[0];
        if([toolbarBackgroundView isKindOfClass:NSClassFromString(@"_UIToolbarBackground")]) {
            if(toolbarBackgroundView.subviews.count > 0) {
                UIImageView *shadowImageView = toolbarBackgroundView.subviews[0];
                if([shadowImageView isKindOfClass:NSClassFromString(@"UIImageView")]) {
                    [toolbarBackgroundView insertSubview:self.customlyAddedBackgroundImageView belowSubview:shadowImageView];
                }
            } else {
                [toolbarBackgroundView insertSubview:self.customlyAddedBackgroundImageView atIndex:0];
            }
        }
    }
    
    // remove native separator and display the shadow image
    
    [self removeNativeSeparatorAndDisplayShadowImageView];
    
}

/*
 
 Modify the toolbar before further usage.
 
*/

- (void)applyInitialChangesInToolbarAppearance {
    
    // set an empty background image for all metrics
    
    [self setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault usingForce:YES];
    [self setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsLandscapePhone usingForce:YES];
    
    [self setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault usingForce:YES];
    [self setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhone usingForce:YES];
    
    // remove native separator and display the shadow image
    
    [self removeNativeSeparatorAndDisplayShadowImageView];
    
}

/*
 
 This methods recreates the background image based
 on the new tint color.
 
*/

- (void)generateAndApplyNewDefaultBackgroundImagesWithTintColor:(UIColor *)color {
    
    UIImage *newResizableBackgroundImage = DKRenderResizableTintedToolbarBackgroundImage(color);
    
    [self setBackgroundImage:newResizableBackgroundImage forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsLandscapePhone usingForce:NO];
    
    [self setBackgroundImage:newResizableBackgroundImage forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault usingForce:NO];
    [self setBackgroundImage:newResizableBackgroundImage forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhone usingForce:NO];
    
}

/*
 
 This methods creates and applies default colors
 and images to the toolbar.
 
*/

- (void)applyDefaultAppearance {
    
    // set up the default colors
    
    UIColor *defaultBarTintColor = [UIColor colorWithWhite:0.950 alpha:1.000];
    UIColor *defaultTintColor = [UIColor colorWithHue:0.571 saturation:0.107 brightness:0.514 alpha:1.000];
    
    CGFloat defaultShadowImageTopColorOpacity = 0.1f;
    CGFloat defaultShadowImageHeight = 3.0f;
    
    // set tint colors
    
    [self setTintColor:defaultTintColor];
    [self setBarTintColor:defaultBarTintColor usingForce:NO];
    
    // set default shadow image
    
    UIImage *defaultShadowImage = DKRenderResizableToolbarShadow([UIColor blackColor], defaultShadowImageTopColorOpacity, defaultShadowImageHeight);
    
    [self setShadowImage:defaultShadowImage forToolbarPosition:UIBarPositionBottom];
    
    // set translucent
    
    [self setTranslucent:YES];
    
}

/*
 
 In case of any layout changes, re-modify the toolbar structure.
 
*/

- (void)layoutSubviews {
    
    // remove all added stuff, we'll add it in a second
    [self prepareForSuperLayoutSubviews];
    
    // properly layout subviews
    [super layoutSubviews];
    
    // and add the changes again
    [self applyChangesInToolbarStructure];
    
    // refresh the shadow image view
    [self refreshCustomlyAddedShadowImageView];
    
}

@end
