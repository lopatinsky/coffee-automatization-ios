//
//  DBShippingAutocompleteView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBShippingAutocompleteView;
@class DBShippingAddress;

@protocol DBShippingAutocompleteViewDelegate <NSObject>
@required
- (void)db_shippingAutocompleteView:(DBShippingAutocompleteView *)view didSelectAddress:(DBShippingAddress *)address;
@end

@interface DBShippingAutocompleteView : UIView
@property (weak, nonatomic) id<DBShippingAutocompleteViewDelegate> delegate;

- (void)showOnView:(UIView *)view topOffset:(NSInteger)offset;
- (void)hide;
@end
