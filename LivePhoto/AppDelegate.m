//
//  AppDelegate.m
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/14.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "PhotoLibrary.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [PhotoLibrary getlibraryAuthorization];
    // Override point for customization after application launch.
    return YES;
}
/*
 <key>CFBundleDocumentTypes</key>
 <array>
 <dict>
 <key>CFBundleTypeIconFiles</key>
 <array>
 <string>copy.png</string>
 </array>
 <key>LSHandlerRank</key>
 <string>Default</string>
 <key>LSItemContentTypes</key>
 <array>
 <string>public.video</string>
 </array>
 </dict>
 </array>
 */
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"%@",url);
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
    RootViewController * rootVC = nav.viewControllers.firstObject;
    [rootVC handleShareExtensionWithPath:[[url.absoluteString componentsSeparatedByString:@"data="] lastObject]];
//    vc.groupUrl = [[url.absoluteString componentsSeparatedByString:@"data="] lastObject];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
