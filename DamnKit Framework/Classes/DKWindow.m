//
//  DKWindow.m
//  DamnKit
//
//  Created by Adrian on 14.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import "DKWindow.h"

#pragma mark Constants

/*
 
 This constant is discussed in .h file.
 
*/

CGFloat DKWindowStandardCornerRadii = 3.0f;

#pragma mark - 

@interface DKWindow ()

- (void)applyWindowRoundedCorners;

- (void)setNeedsUpdateRoundedCorners;

@end

#pragma mark - 

@implementation DKWindow

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    // set some defaults
    
    self.windowCornerRadii = DKWindowStandardCornerRadii;
    self.backgroundColor = [UIColor blackColor];
    
    return self;
}

#pragma mark - Window Rounded Corners

- (void)setWindowCornerRadii:(CGFloat)windowCornerRadii {
    
    // if the same radii, gtfo
    
    if(windowCornerRadii == _windowCornerRadii) return;
    
    // update and apply the new radii
    
    _windowCornerRadii = windowCornerRadii;
    [self setNeedsUpdateRoundedCorners];
    
}

- (void)setNeedsUpdateRoundedCorners {
    
    // apply thoze cornerz!
    
    [self applyWindowRoundedCorners];
    
}

- (void)applyWindowRoundedCorners {
    
    // set the corner radii on the layer and make it mask to bounds (important!)
    
    self.layer.cornerRadius = self.windowCornerRadii;
    self.layer.masksToBounds = YES;
    
}

#pragma Subclassed Methods

- (void)layoutSubviews {
    
    // first of all, call super
    
    [super layoutSubviews];
    
    // then apply redraw rounded corners
    
    [self applyWindowRoundedCorners];
}

@end
