//
//  AKApplicationDelegate.m
//  DamnKit
//
//  Created by Adrian on 14.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import "AKApplicationDelegate.h"
#import "AKMapsViewController.h"

@implementation AKApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[DKWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    AKMapsViewController *mapsViewController = [[AKMapsViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[DKNavigationBar class] toolbarClass:[UIToolbar class]];
    [navigationController setViewControllers:@[ mapsViewController ]];
    
    [self.window setRootViewController:navigationController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setWindowCornerRadii:3.00f];
    [self.window makeKeyAndVisible];
    
//    UIImage *backgroundImage = DKRenderResizableNavigationBarBackgroundImage(@[ [UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor purpleColor] ],
//                                                                 @[ @(0.0), @(0.2), @(0.4), @(0.6), @(0.8), @(1.0) ],
//                                                                             @[ [UIColor colorWithWhite:1.0 alpha:1.0], [UIColor blackColor], [UIColor greenColor] ],
//                                                                 @[ [UIColor colorWithWhite:0.4 alpha:0.4], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor], [UIColor colorWithWhite:1.0 alpha:0.7], [UIColor yellowColor] ]);
//    
//    UIImage *shadowImage = DKRenderResizableNavigationBarShadow([UIColor blackColor], 0.1, 3);
    
//    [[DKNavigationBar appearance] setBackgroundImage:backgroundImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
//    [[DKNavigationBar appearance] setShadowImage:shadowImage];
    //[navigationController.navigationBar setTranslucent:NO];
    
    return YES;
    
}

@end
