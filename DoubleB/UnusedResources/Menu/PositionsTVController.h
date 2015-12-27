//
//  IHProductTableViewController.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuListViewControllerProtocol.h"

@class DBMenuCategory;

@interface PositionsTVController : UITableViewController<MenuListViewControllerProtocol>

@property (nonatomic, strong) DBMenuCategory *category;

@end
