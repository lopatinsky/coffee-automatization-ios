//
//  IHSecureStore.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 12.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHSecureStore : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *clientId;

@end
