//
//  DKNavigationBarTests.m
//  DamnKit
//
//  Created by Adrian on 15.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DKNavigationBar.h"

@interface _DKNavigationBarTestsAppearanceContainingNavigationController : UINavigationController @end
@implementation _DKNavigationBarTestsAppearanceContainingNavigationController @end

@interface DKNavigationBarTests : XCTestCase @end

@implementation DKNavigationBarTests

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testNavigationBarDefaultTranslucent {
    DKNavigationBar *bar = [[DKNavigationBar alloc] initWithFrame:CGRectZero];
    XCTAssertTrue(bar.translucent, @"DKNavigationBar should be translucent by default");
}

- (void)testNavigationBarDefaultBarTintColor {
    DKNavigationBar *bar = [[DKNavigationBar alloc] initWithFrame:CGRectZero];
    UIColor *color = [UIColor colorWithWhite:0.950 alpha:1.000];
    XCTAssertEqualObjects(bar.barTintColor, color, @"DKNavigationBar should have the barTintColor of (W:0.950 A:1.000) by default");
}

- (void)testNavigationBarDefaultTintColor {
    DKNavigationBar *bar = [[DKNavigationBar alloc] initWithFrame:CGRectZero];
    UIColor *color = [UIColor colorWithHue:0.571 saturation:0.107 brightness:0.514 alpha:1.000];
    XCTAssertEqualObjects(bar.tintColor, color, @"DKNavigationBar should have the tintColor of (H:0.571 S:0.107 B:0.514 A:1.000) by default");
}

- (void)testNavigationBarDefaultTitleTextAttributes {
    UIColor *defaultTitleTextGrayColor = [UIColor colorWithHue:0.571 saturation:0.107 brightness:0.514 alpha:1.000];
    NSShadow *defaultTitleTextWhiteShadow = [[NSShadow alloc] init];
    [defaultTitleTextWhiteShadow setShadowColor:[UIColor colorWithWhite:1.000 alpha:0.900]];
    [defaultTitleTextWhiteShadow setShadowOffset:CGSizeMake(0, 1)];
    UIFont *defaultTitleTextBoldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    NSDictionary *attributes = @{ NSFontAttributeName : defaultTitleTextBoldFont, NSForegroundColorAttributeName : defaultTitleTextGrayColor, NSShadowAttributeName : defaultTitleTextWhiteShadow };
    DKNavigationBar *bar = [[DKNavigationBar alloc] initWithFrame:CGRectZero];
    XCTAssertEqualObjects([bar titleTextAttributes], attributes, @"DKNavigationBar attributes should be \"default\" by default");
}

- (void)testAppearanceProxyCompatability {
    DKNavigationBar *barApp = [DKNavigationBar appearanceWhenContainedIn:[_DKNavigationBarTestsAppearanceContainingNavigationController class], nil];
    
    
    
}

@end
