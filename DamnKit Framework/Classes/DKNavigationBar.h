//
//  DKNavigationBar.h
//  DamnKit
//
//  Created by Adrian on 12.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!

 @brief Generates a new resizable navigation bar background image.
 
 @param gradientColors An array of colors which will be used to generate the main gradient.
 @param gradientColorLocations The location of colors. Each location must correspond to a color in gradientColors.
 @param topSeparators An array of colors which will be used to draw 1pt separators on top of the navigation bar. The colors will be drawn downwards.
 @param bottomSeparators An array of colors which will be used to draw 1pt separators at the bottom of the navigation bar. The colors will be drawn upwards.

 @return New resizable navigation bar background image.
 
*/

extern UIImage * DKRenderResizableNavigationBarBackgroundImage(NSArray *gradientColors, NSArray *gradientColorLocations, NSArray *topSeparators, NSArray *bottomSeparators) NS_AVAILABLE_IOS(7_0);


/*!
 
 @brief Generates a new resizable navigation bar shadow image.
 
 @param shadowColor The color of the shadow
 @param topColorOpacity The opacity at the top of the gradient
 @param shadowHeight The height of the shadow
 
 @return New resizable navigation bar shadow image.
 
*/

extern UIImage * DKRenderResizableNavigationBarShadow(UIColor *shadowColor, CGFloat topColorOpacity, CGFloat shadowHeight) NS_AVAILABLE_IOS(7_0);


/*!
 
 @class DKNavigationBar
 
 @brief A subclass of the damn UINavigationBar, which allows designers to fulfill their dreams and create beautiful-looking semi-transparent navigation bars for their apps.
 
*/

NS_CLASS_AVAILABLE_IOS(7_0) @interface DKNavigationBar : UINavigationBar

// nothing here (yet)

@end
