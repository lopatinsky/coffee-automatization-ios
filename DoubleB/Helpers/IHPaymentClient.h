//
//  IHPaymentClient.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 04.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface IHPaymentClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
