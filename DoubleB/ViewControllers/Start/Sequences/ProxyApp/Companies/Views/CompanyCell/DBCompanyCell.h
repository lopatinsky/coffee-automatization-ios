//
//  DBCompanyCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBCompany;
@interface DBCompanyCell : UITableViewCell

- (void)configure:(DBCompany *)company;

@end
