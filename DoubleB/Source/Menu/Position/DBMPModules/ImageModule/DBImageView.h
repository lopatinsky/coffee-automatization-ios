//
//  DBImageView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBImageViewNoImageType) {
    DBImageViewNoImageTypeImage = 0,
    DBImageViewNoImageTypeText
};

@interface DBImageView : UIImageView
@property (strong, nonatomic) UIImage *dbImage;
@property (strong, nonatomic) NSURL *dbImageUrl;

@property (nonatomic) DBImageViewNoImageType noImageType;

@property (nonatomic) BOOL hasImage;
@end
