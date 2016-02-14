//
//  DBMenuSearchBarView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBMenuSearchBarView : UIView
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

+ (DBMenuSearchBarView *)create;
@end