//
//  DBFriendGiftPaymentModule.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFGPaymentModule.h"
#import "DBCardsManager.h"

@interface DBFGPaymentModule ()
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBFGPaymentModule

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGPaymentModule" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [self.cardImageView templateImageWithName:@"card.png"];
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)reload {
    [super reload];
    
    DBPaymentCard *defaultCard = [DBCardsManager sharedInstance].defaultCard;
    if (defaultCard) {
        NSString *cardNumber = defaultCard.pan;
        NSString *pan = [cardNumber substringFromIndex:cardNumber.length-4];
        self.titleLabel.text = [NSString stringWithFormat:@"%@ ....%@", defaultCard.cardIssuer, pan];
        self.titleLabel.textColor = [UIColor blackColor];
    } else {
        self.titleLabel.text = NSLocalizedString(@"Нет карт", nil);
        self.titleLabel.textColor = [UIColor orangeColor];
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"gift_card_choice_click" category:self.analyticsCategory];
}

@end
