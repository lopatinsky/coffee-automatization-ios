//
//  OrderPositionRowType.h
//  DoubleB
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface OrderPositionRowType : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *positionName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *positionPrice;

@end
