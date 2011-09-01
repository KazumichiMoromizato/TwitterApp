//
//  NavigationBasedAppFirstAppDelegate.h
//  NavigationBasedAppFirst
//
//  Created by 金城 拓実 on 11/09/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBasedAppFirstAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
