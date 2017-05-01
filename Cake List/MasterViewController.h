//
//  MasterViewController.h
//  Cake List
//
//  Created by Stewart Hart on 19/05/2015.
//  Copyright (c) 2015 Stewart Hart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController

- (NSString *) md5:(NSString *) input;
- (NSData *) loadImage:(NSString *) url;

@end

