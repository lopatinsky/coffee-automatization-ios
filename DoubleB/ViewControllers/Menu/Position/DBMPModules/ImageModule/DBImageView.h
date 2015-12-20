//
//  DBImageView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBImageView : UIImageView
@property (strong, nonatomic) UIImage *dbImage;
@property (strong, nonatomic) NSURL *dbImageUrl;

@property (nonatomic) BOOL hasImage;
@end
