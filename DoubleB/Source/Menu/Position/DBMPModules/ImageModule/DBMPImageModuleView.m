//
//  DBMPImageModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMPImageModuleView.h"
#import "DBImageView.h"

#import "DBMenuPosition.h"

@interface DBMPImageModuleView ()
@property (strong, nonatomic) DBImageView *positionImageView;
@end

@implementation DBMPImageModuleView

- (instancetype)init {
    self = [super init];
    
    self.positionImageView = [DBImageView new];
    self.positionImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.positionImageView.clipsToBounds = YES;
    self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
    self.positionImageView.noImageType = [DBCompanyInfo sharedInstance].type == DBCompanyTypeMobileShop ? DBImageViewNoImageTypeText : DBImageViewNoImageTypeImage;
    [self addSubview:self.positionImageView];
    self.positionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.positionImageView constrainHeight:@"220"];
    [self.positionImageView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    return self;
}

- (CGFloat)moduleViewContentHeight {
    return 220.f;
}

- (void)setPosition:(DBMenuPosition *)position {
    _position = position;
    
    self.positionImageView.dbImageUrl = [NSURL URLWithString:position.imageUrl];
}

@end
