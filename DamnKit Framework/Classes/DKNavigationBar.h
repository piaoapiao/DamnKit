//
//  DKNavigationBar.h
//  DamnKit
//
//  Created by Adrian on 12.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import <UIKit/UIKit.h>


//////////////////////////////////////////
//              FUNCTIONS               //
//////////////////////////////////////////


/*
 
 Generates a new resizable navigation bar background image.
 
 @param gradientColors - An array of colors which will be used to generate the main gradient
 @param gradientColorLocations - The location of colors. Each location must correspond to a color in gradientColors
 @param topSeparators - An array of colors which will be used to draw 1pt separators on top of the navigation bar. The colors will be drawn downwards.
 @param bottomSeparators - An array of colors which will be used to draw 1pt separators at the bottom of the navigation bar. The colors will be drawn upwards.
 
 Sample usage:
 
 DKRender...Image(@[ [UIColor colorWithWhite:0.900 alpha:1.000], [UIColor colorWithWhite:0.800 alpha:0.800] ], // draw a gradient with these colors ...
                  @[ @(0.0), @(1.0) ], // .. with these locations (0.0 = top, 1.0 = bottom) ...
                  @[ [UIColor colorWithWhite:1.000 alpha:1.000]; ], // ... then draw one top separator (white) ...
                  @[ [UIColor colorWithWhite:0.400 alpha:0.700], [UIColor colorWithWhite:1.000 alpha:0.800] ]); // ... and two bottom separators (darker separator will be drawn lower).
 
*/

extern UIImage * DKRenderResizableNavigationBarBackgroundImage(NSArray *gradientColors, NSArray *gradientColorLocations, NSArray *topSeparators, NSArray *bottomSeparators);


/*
 
 Generates a new resizable navigation bar shadow image.
 
 @param shadowColor - The color of the shadow (typically [UIColor blackColor])
 @param topColorOpacity - The opacity at the top of the gradient (bottom is always 0.0)
 @param shadowHeight - The height of the shadow
 
 Sample usage:
 
 DKRender...Shadow([UIColor blackColor], // use the black color ...
                   0.150, // ... with top opacity of 0.15 ...
                   3.0); // ... and the shadow hast to be 3pt high
 
*/

extern UIImage * DKRenderResizableNavigationBarShadow(UIColor *shadowColor, CGFloat topColorOpacity, CGFloat shadowHeight);

@interface DKNavigationBar : UINavigationBar


@end
