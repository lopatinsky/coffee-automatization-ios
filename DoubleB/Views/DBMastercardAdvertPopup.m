//
//  DBMastercardAdvertPopup.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMastercardAdvertPopup.h"
#import "UIColor+Brandbook.h"

@interface DBMastercardAdvertPopup ()

@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger maxCount;
@property (nonatomic) NSInteger accumulatedMugCount;

@property (strong, nonatomic) UILabel *advertLabel;

@property(nonatomic, copy) void(^completionHandler)();

@end

@implementation DBMastercardAdvertPopup

- (instancetype)initWithCurrentProgress:(NSInteger)count
                               maxCount:(NSInteger)maxCount
                      completionHandler:(void (^)())handler{
    self = (DBMastercardAdvertPopup *)[[[NSBundle mainBundle] loadNibNamed:@"DBMastercardAdvertPopup" owner:self options:nil] firstObject];
    
    self.count = count;
    self.maxCount = maxCount;
    self.completionHandler = handler;
    
    [self configureTotalCountLabel:count];
    [self configureProgressViewWithMaxCount:maxCount count:count];
    [self configureAdvertMessageLabel];
    
    self.accumulatedLabel.hidden = YES;
    self.mugCountLabel.hidden = YES;
    self.mugImageView.hidden = YES;
    self.hintLabel.hidden = YES;
    
    
    return self;
}

- (instancetype)initWithCurrentProgress:(NSInteger)count
                               maxCount:(NSInteger)maxCount
                    accumulatedMugCount:(NSInteger)mugCount
                      completionHandler:(void (^)())handler{
    self = (DBMastercardAdvertPopup *)[[[NSBundle mainBundle] loadNibNamed:@"DBMastercardAdvertPopup" owner:self options:nil] firstObject];
    
    self.count = count;
    self.maxCount = maxCount;
    self.accumulatedMugCount = mugCount;
    self.completionHandler = handler;
    
    [self configureTotalCountLabel:count];
    [self configureProgressViewWithMaxCount:maxCount count:count];
    
    self.accumulatedLabel.text =  NSLocalizedString(@"Вы накопили:", nil);
    self.mugCountLabel.text = [NSString stringWithFormat:@"x %d", (int)mugCount];
    self.hintLabel.text = NSLocalizedString(@"Чтобы получить напиток в подарок, измените тип оплаты на экране заказа", nil);
    
    return self;
}


- (void)awakeFromNib{
    [self.confirmButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.progressContentView.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 7.f;
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderWidth:1.1f];
    [self.layer setBorderColor:[[UIColor db_separatorColor] CGColor]];
}

- (void)configureTotalCountLabel:(NSInteger)count{
    NSMutableAttributedString *totalCountText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: NSLocalizedString(@"У вас %d %@.", nil), (int)count, NSLocalizedString([self selectAppropriateWordForm:count], nil)]];
    NSString *pattern = @"[0-9]";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:totalCountText.string options:0 range:NSMakeRange(0, totalCountText.length)];
    NSTextCheckingResult *match = matches[0];
    if(match){
        [totalCountText addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:self.totalCountLabel.font.pointSize]
                               range:NSMakeRange(match.range.location, totalCountText.length - match.range.location)];
    }
    
    [self.totalCountLabel setAttributedText:totalCountText];
}

- (void)configureProgressViewWithMaxCount:(NSInteger)maxCount count:(NSInteger)count{
    int separatorWidth = 2.0;
    double contentWidth = self.progressContentView.frame.size.width;
    double contentHeight = self.progressContentView.frame.size.height;
    double progressItemWidth = (contentWidth - (maxCount - 1) * separatorWidth) / maxCount;
    double progressItemHeight = 5.0;
    
    for(int i = 0; i < maxCount; i++){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * (progressItemWidth + separatorWidth), (contentHeight - progressItemHeight) / 2, progressItemWidth, progressItemHeight)];
        
        if(i < count)
            view.backgroundColor = [UIColor db_defaultColor];
        else
            view.backgroundColor = [UIColor db_backgroundColor];
        
        [self.progressContentView addSubview:view];
    }
}

- (void)configureAdvertMessageLabel{
    self.advertLabel = [[UILabel alloc] init];
    CGRect rect = self.progressContentView.frame;
    rect.origin.y += 15;
    rect.size.height = self.separatorView.frame.origin.y - rect.origin.y - 15;
    self.advertLabel.frame = rect;
    self.advertLabel.numberOfLines = 3;
    self.advertLabel.textAlignment = NSTextAlignmentCenter;
    self.advertLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.f];
    self.advertLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Копите баллы, оплачивая покупки картой Mastercard, и получайте каждый %d напиток в подарок.", nil), self.maxCount + 1];
    
    [self addSubview:self.advertLabel];
}

- (IBAction)confirmButtonClick:(id)sender{
    self.completionHandler();
    
    [GANHelper analyzeEvent:@"confirm_button_click" category:@"Promo_info_popup"];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer{
    CGPoint touch = [recognizer locationInView:self];
    
    if(CGRectContainsPoint(self.totalCountLabel.frame, touch)){
        [GANHelper analyzeEvent:@"points_count_click" category:@"Promo_info_popup"];
    }
    
    if(CGRectContainsPoint(self.progressContentView.frame, touch)){
        [GANHelper analyzeEvent:@"progress_click" category:@"Promo_info_popup"];
    }
    
    if((CGRectContainsPoint(self.mugImageView.frame, touch) || CGRectContainsPoint(self.mugCountLabel.frame, touch)) && self.accumulatedMugCount > 0){
        [GANHelper analyzeEvent:@"mug_count_click" category:@"Promo_info_popup"];
    }
    
    if(CGRectContainsPoint(self.hintLabel.frame, touch) && !self.hintLabel.hidden){
        [GANHelper analyzeEvent:@"free_beverage_hint_click" category:@"Promo_info_popup"];
    }
    
    if(CGRectContainsPoint(self.advertLabel.frame, touch) && !self.advertLabel.hidden){
        [GANHelper analyzeEvent:@"promo_description_click" category:@"Promo_info_popup"];
    }
}

- (NSString *)selectAppropriateWordForm:(NSInteger)number{
    if(number >= 10 && number <= 20)
        return @"баллов";
    
    NSString *result = @"";
    if(number % 10 == 1){
        result = @"балл";
    }
    if(number % 10 >= 2 && number % 10 <= 4){
        result = @"балла";
    }
    if((number % 10 >= 5 && number % 10 <= 9) || (number % 10 == 0)){
        result = @"баллов";
    }
    
    return result;
}


@end
