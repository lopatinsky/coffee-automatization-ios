//
//  DBDataManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* Superclass for all managers that hold and cache data
*/
@interface DBDataManager : NSObject

/**
 * Defaults key for external level of whole manager data. Needs to override in subclass
 */
+ (NSString *)db_managerStorageKey;


/**
 * Get value from manager storage by key
 */
+ (id)valueForKey:(NSString *)key;

/**
 * Save value to manager storage by key
 */
+ (void)setValue:(id)value forKey:(NSString *)key;

/**
 * clear manager storage
 */
+ (void)removeAllValues;

@end
