//
//  SubscriptionViewControllerProtocol.h
//  DoubleB
//
//  Created by Balaban Alexander on 26/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SubscriptionViewControllerDelegate <NSObject>

- (void)subscriptionViewControllerWillDissappear;

@end

@protocol SubscriptionViewControllerProtocol <NSObject>

@property (nonatomic, strong) UIViewController<SubscriptionViewControllerDelegate> *delegate;

@end
