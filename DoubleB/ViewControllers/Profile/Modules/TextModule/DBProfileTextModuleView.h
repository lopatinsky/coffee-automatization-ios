//
//  DBProfileNameModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModuleView.h"

@interface DBProfileTextModuleView : DBModuleView

@property (strong, nonatomic) UIImage *moduleImage;

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *textPlaceholder;

@end
