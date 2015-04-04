//
//  DBMastercardAdvertProgressView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMastercardAdvertProgressView.h"
#import "UIColor+Brandbook.h"
#import "DBMastercardPromo.h"

@implementation DBMastercardAdvertProgressView

- (instancetype)initWithDelegate:(id<DBMasterCardAdvertProgressViewDelegate>)delegate;{
    DBMastercardAdvertProgressView *dbMastercardAdvertProgressView = [[[NSBundle mainBundle] loadNibNamed:@"DBMastercardAdvertProgressView" owner:self options:nil] firstObject];
    
    dbMastercardAdvertProgressView.advertDelegate = delegate;
    
    return dbMastercardAdvertProgressView;
}

- (void)awakeFromNib{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.progressContentView.backgroundColor = [UIColor clearColor];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    separatorView.backgroundColor = [UITableView new].separatorColor;
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:separatorView];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self setupData];
}

- (void)updateData{
    [self.progressContentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self.mugImageView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self setupData];
}

- (void)setupData{
    DBMastercardPromo *promo = [DBMastercardPromo sharedInstance];
    
    int count = (int)promo.promoMaxPointsCount;
    int separatorWidth = 2.0;
    double contentWidth = self.progressContentView.frame.size.width;
    double contentHeight = self.progressContentView.frame.size.height;
    double progressItemWidth = (contentWidth - (count - 1) * separatorWidth) / count;
    double progressItemHeight = 5.0;
    
    for(int i = 0; i < count; i++){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * (progressItemWidth + separatorWidth), (contentHeight - progressItemHeight) / 2, progressItemWidth, progressItemHeight)];
        
        if(i < promo.promoCurrentPointsCount)
            view.backgroundColor = [UIColor db_defaultColor];
        else
            view.backgroundColor = [UIColor db_backgroundColor];
        
        [self.progressContentView addSubview:view];
    }
    
    if(promo.promoCurrentMugCount > 0){
        [self.mugImageView templateImageWithName:@"mug"];
        int rad = 8;
        UILabel *mugCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mugImageView.frame.size.width - rad*2, -6, rad*2, rad*2)];
        mugCountLabel.layer.cornerRadius = rad;
        mugCountLabel.layer.masksToBounds = YES;
        mugCountLabel.textColor = [UIColor whiteColor];
        mugCountLabel.backgroundColor = [UIColor blackColor];
        mugCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.f];
        mugCountLabel.textAlignment = NSTextAlignmentCenter;
        mugCountLabel.text = [NSString stringWithFormat:@"%d", (int)promo.promoCurrentMugCount];
        [self.mugImageView addSubview:mugCountLabel];
    } else {
        self.mugImageView.image = [UIImage imageNamed:@"mug_gray"];
    }
}

- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer{
    if([self.advertDelegate respondsToSelector:@selector(db_mastercardAdvertProgressViewClick:)]){
        [self.advertDelegate db_mastercardAdvertProgressViewClick:self];
    }
    
    CGPoint touch = [recognizer locationInView:self];
    if(CGRectContainsPoint(self.progressContentView.frame, touch)){
        [GANHelper analyzeEvent:@"mastercard_promo_progress_click" category:@"Menu_screen"];
    }
    if(CGRectContainsPoint(self.mugImageView.frame, touch)){
        [GANHelper analyzeEvent:@"mastercard_promo_mug_click" category:@"Menu_screen"];
    }
}

@end
