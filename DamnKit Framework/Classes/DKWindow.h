//
//  DKWindow.h
//  DamnKit
//
//  Created by Adrian on 14.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


//////////////////////////////////////////
//         TYPEDEFS & CONSTANTS         //
//////////////////////////////////////////


/*
 
 Standard corner radii used in iOS 6 and earlier.
 
 Default value: 3.0f
 
*/
 
extern CGFloat DKWindowStandardCornerRadii;


//////////////////////////////////////////


@interface DKWindow : UIWindow


//////////////////////////////////////////
//              PROPERTIES              //
//////////////////////////////////////////


/*
 
 Setting this property recreates the rounded corners
 effect from iOS 6 and earlier.
 
 If you want to have exact same radii, pass
 DKWindowStandardCornerRadii constant.
 
*/

@property (nonatomic, assign) CGFloat windowCornerRadii;


@end
