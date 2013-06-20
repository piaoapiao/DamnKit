//
//  AKMapsViewController.m
//  DamnKit
//
//  Created by Adrian on 15.06.2013.
//  Copyright (c) 2013 Adrian Kashivskyy. All rights reserved.
//

#import "AKMapsViewController.h"

@interface AKMapsViewController ()

@property MKMapView *mapView;

@end

@implementation AKMapsViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor =[UIColor colorWithWhite:0.9 alpha:1];
    self.edgesForExtendedLayout = UIExtendedEdgeAll;
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    UIColor *color = [UIColor colorWithWhite:0.950 alpha:1.000]; // default
//    UIColor *color = [UIColor colorWithHue:0.988 saturation:0.328 brightness:0.996 alpha:1.000]; // pink
//    UIColor *color = [UIColor colorWithHue:0.543 saturation:0.379 brightness:0.945 alpha:1.000]; // blue
//    UIColor *color = [UIColor colorWithHue:0.271 saturation:0.463 brightness:0.872 alpha:1.000]; // green
//    UIColor *color = [UIColor colorWithHue:0.146 saturation:0.502 brightness:0.988 alpha:1.000]; // yellow
//    UIColor *color = [UIColor colorWithHue:0.743 saturation:0.316 brightness:0.914 alpha:1.000]; // purple
//    UIColor *color = [UIColor colorWithHue:0.031 saturation:0.513 brightness:1.000 alpha:1.000]; // red
//    UIColor *color = [UIColor colorWithHue:0.097 saturation:0.561 brightness:1.000 alpha:1.000]; // orange
//    UIColor *color = [UIColor colorWithHue:0.550 saturation:0.246 brightness:0.937 alpha:1.000]; // ocean
//    UIColor *color = [UIColor colorWithWhite:0.300 alpha:1.000]; // darker
    self.navigationController.navigationBar.barTintColor = color;
    
    self.toolbarItems = @[ [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:nil action:nil] ];
    self.navigationController.toolbarHidden = NO;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Map View";
}

@end
