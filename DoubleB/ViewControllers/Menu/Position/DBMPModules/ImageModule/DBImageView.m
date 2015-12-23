//
//  DBImageView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBImageView.h"

#import "UIImageView+WebCache.h"

@interface DBImageView ()
@property (strong, nonatomic) UIImageView *noImageView;
@property (strong, nonatomic) UILabel *noImageLabel;
@end

@implementation DBImageView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.noImageView = [UIImageView new];
    self.noImageView.image = [UIImage imageNamed:@"noimage_icon.png"];
    self.noImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.noImageView];
    self.noImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.noImageView alignCenterWithView:self];
    
    int size = self.frame.size.height < self.frame.size.width ? self.frame.size.height / 3 : self.frame.size.width / 3;
    [self.noImageView constrainHeight:[NSString stringWithFormat:@"%ld", (long)size]];
    [self.noImageView constrainWidth:[NSString stringWithFormat:@"%ld", (long)size]];
    self.noImageView.hidden = YES;
    
    self.noImageLabel = [UILabel new];
    self.noImageLabel.numberOfLines = 0;
    self.noImageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    self.noImageLabel.textColor = [UIColor blackColor];
    self.noImageLabel.text = NSLocalizedString(@"нет фото", nil);
    [self addSubview:self.noImageLabel];
    self.noImageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.noImageLabel alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    self.noImageLabel.hidden = YES;
    
    self.backgroundColor = [UIColor colorWithRed:235./255 green:235./255 blue:235./255 alpha:1.0f];
}

- (void)setHasImage:(BOOL)hasImage {
    _hasImage = hasImage;
    if (!hasImage) {
        self.noImageView.hidden = NO;
        self.image = nil;
    } else {
        self.noImageView.hidden = YES;
    }
}

- (void)setDbImage:(UIImage *)dbImage {
    _dbImage = dbImage;
    
    if (dbImage) {
        self.image = _dbImage;
    }
    [self setHasImage:dbImage != nil];
}

- (void)setDbImageUrl:(NSURL *)dbImageUrl {
    [self setHasImage:NO];
    
    [self sd_setImageWithURL:dbImageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && !error) {
            [self setHasImage:YES];
        } else {
            [self setHasImage:NO];
        }
    }];
}

@end
