//
//  AppDelegate.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

#import "MMTwitterDataManager.h"

#import "MMTwitterManager.h"

#import "MMTwitterLoginViewController.h"

@import Accounts;


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Fabric with:@[[Twitter class]]];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    
    for (ACAccount *acc in accounts) {
        NSLog(@"username %@", acc.username);
    }
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSLog(@"access granted");
                NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                
                if (twitterAccounts.count > 0) {
                    NSLog(@"Account Available");
                    [[MMTwitterManager sharedManager] loginWithCompletionHandler:^(NSError *error){
                        NSLog(@"Logged In");
                    }];
                    
                } else {
                    self.window.backgroundColor = [UIColor whiteColor];
                    self.window.rootViewController.view.hidden = YES;
                    
                    NSLog(@"No Account Available");
                    // show log in view here modally
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    
                    MMTwitterLoginViewController *loginView = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
                    loginView.modalPresentationStyle = UIModalPresentationFullScreen;
                    loginView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    
                    [self.window.rootViewController presentViewController:loginView animated:NO completion:nil];
                    
                }
            }
        });
        
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
