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

- (void)testIsTranslucentByDefault {
    DKNavigationBar *bar = [[DKNavigationBar alloc] initWithFrame:CGRectZero];
    XCTAssertTrue(bar.translucent, @"DKNavigationBar should be translucent by default");
}

- (void)testAppearanceProxyCompatability {
    
    UIColor *barTintColor = [UIColor redColor];
    UIColor *tintColor = [UIColor greenColor];
    
    NSShadow *titleTextShadow = [[NSShadow alloc] init];
    [titleTextShadow setShadowColor:[UIColor colorWithWhite:0.000 alpha:0.900]];
    [titleTextShadow setShadowOffset:CGSizeMake(0, -4)];
    
    UIFont *titleTextFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
    
    NSDictionary *titleTextAtts = @{ NSFontAttributeName : titleTextFont, NSForegroundColorAttributeName : tintColor, NSShadowAttributeName : titleTextShadow };
    
    UIImage *shadowImage = DKRenderResizableNavigationBarShadow([UIColor blueColor], 1, 5);
    
    DKNavigationBar *barApp = [DKNavigationBar appearanceWhenContainedIn:[_DKNavigationBarTestsAppearanceContainingNavigationController class], nil];
    
    [barApp setBarTintColor:barTintColor];
    [barApp setTintColor:tintColor];
    [barApp setTitleTextAttributes:titleTextAtts];
    [barApp setShadowImage:shadowImage];
    
    _DKNavigationBarTestsAppearanceContainingNavigationController *navCtrlr = [[_DKNavigationBarTestsAppearanceContainingNavigationController alloc] initWithNavigationBarClass:[DKNavigationBar class] toolbarClass:[UIToolbar class]];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.rootViewController = navCtrlr;
    [window makeKeyAndVisible];
    
    UIColor *barTintColor2 = [navCtrlr.navigationBar barTintColor];
    XCTAssertEqualObjects(barTintColor, barTintColor2, @"barTintColor should be preserved by UIAppearance proxy");
    
    UIColor *tintColor2 = [navCtrlr.navigationBar tintColor];
    XCTAssertEqualObjects(tintColor, tintColor2, @"tintColor should be preserved by UIAppearance proxy");
    
    NSDictionary *titleTextAtts2 = [navCtrlr.navigationBar titleTextAttributes];
    XCTAssertEqualObjects(titleTextAtts, titleTextAtts2, @"titleTextAttributes should be preserved by UIAppearance proxy");
    
    UIImage *shadowImage2 = [navCtrlr.navigationBar shadowImage];
    XCTAssertEqualObjects(shadowImage, shadowImage2, @"shadowImage should be preserved by UIAppearance proxy");
    
}

@end
