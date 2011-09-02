//
//  DetailViewController.h
//  NavigationBasedAppFirst
//
//  Created by 金城 拓実 on 11/09/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UITableViewController {
    NSString *statusId;
    NSMutableArray *statuses;
}

@property(nonatomic, retain) NSString *statusId;
@property(nonatomic, retain) NSMutableArray *statuses;

@end
