//
//  DBMastercardAdView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMastercardAdView.h"
#import "UIColor+Brandbook.h"

@implementation DBMastercardAdView

- (instancetype)initWithDelegate:(id<DBMasterCardAdViewDelegate>)delegate onScreen:(NSString *)screen{
    DBMastercardAdView *dbMastercardAdView = [[[NSBundle mainBundle] loadNibNamed:@"DBMastercardAdView"
                                                                            owner:self options:nil] firstObject];
    
    dbMastercardAdView.advertDelegate = delegate;
    dbMastercardAdView.screen = screen;
    
    return dbMastercardAdView;
}

- (void)awakeFromNib{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Привяжи карту Mastercard и получай ", nil)
                                                                                      attributes:nil];
    
    [messageString addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:self.advertMessageLabel.font.pointSize]
                          range:[messageString.string rangeOfString:@"Mastercard"]];
    
    [messageString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"напитки в подарок", nil)
                                                                          attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:self.advertMessageLabel.font.pointSize]}]];
    
    [self.advertMessageLabel setAttributedText:messageString];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    separatorView.backgroundColor = [UIColor db_separatorColor];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:separatorView];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}


- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer{
    CGPoint touch = [recognizer locationInView:self];
    
    if(CGRectContainsPoint(self.plusImageView.frame, touch)){
        if([self.advertDelegate respondsToSelector:@selector(db_mastercardAdvertViewPlusClick:)])
            [self.advertDelegate db_mastercardAdvertViewPlusClick:self];
        
        [GANHelper analyzeEvent:@"mastercard_promo_plus_click" category:self.screen];
    } else {
        if([self.advertDelegate respondsToSelector:@selector(db_mastercardAdvertViewClick:)])
            [self.advertDelegate db_mastercardAdvertViewClick:self];
        
        if(CGRectContainsPoint(self.mastercardIconImageView.frame, touch)){
            [GANHelper analyzeEvent:@"mastercard_promo_icon_click" category:self.screen];
        } else {
            [GANHelper analyzeEvent:@"mastercard_promo_title_click" category:self.screen];
        }
    }
}

@end
