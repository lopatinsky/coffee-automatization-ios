//
//  DBSettingsItem.h
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBSettingsItemProtocol <NSObject>

@end

@interface DBSettingsItem : NSObject <DBSettingsItemProtocol>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) UIViewController *viewController;

@end
