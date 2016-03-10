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
@property (nonatomic, strong, readonly) NSString *paymentClientId;

- (NSData *)dataForKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key;

- (void)removeForKey:(NSString *)key;
- (void)removeAll;

@end

@interface IHSecureStore (Migration)
/**
 * Migrate data from doubleb secure store (stored up to 1.12 release)
 */
- (void)migrateDataAutomationRelease112;

/**
 * Migrate iiko flag kDBVersionDependencyManagerRemovedIIkoCache stored in double secure store
 */
- (void)migrateIIkoFlagAutomationRelease112;

/**
 * Migrate data of iiko apps released from IIkoHack project
 */
- (void)migrateIIkoData;

@end
