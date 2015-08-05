//
//  IHCategoryTableViewController.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuCategory;

@interface CategoriesTVController : UITableViewController

@property (nonatomic, strong) DBMenuCategory *parent;
@property (nonatomic) BOOL shouldProcessNotificationAfterLoading;

@end
