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
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[DKNavigationBar class] toolbarClass:[DKToolbar class]];
    [navigationController setViewControllers:@[ mapsViewController ]];
    
    [self.window setRootViewController:navigationController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setWindowCornerRadii:3.00f];
    [self.window makeKeyAndVisible];
    
    return YES;
    
}

@end
