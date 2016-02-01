//
//  DBCustomItem.h
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBCustomItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *urlString;

- (instancetype)initWithTitle:(NSString *)title andURLString:(NSString *)urlString;

@end
