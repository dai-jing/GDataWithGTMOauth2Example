//
//  AppDelegate.h
//  GDataWithGTMOauth2Example
//
//  Created by Kobe Dai on 11/6/12.
//  Copyright (c) 2012 Kobe Dai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UINavigationController *navController;

@end
