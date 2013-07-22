//
//  VBAppDelegate.m
//  FacebookAccountMe
//
//  Created by Vitaly Berg on 22.07.13.
//  Copyright (c) 2013 Vitaly Berg. All rights reserved.
//

#import "VBAppDelegate.h"

#import "VBViewController.h"

@implementation VBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    VBViewController *vc = [[VBViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
