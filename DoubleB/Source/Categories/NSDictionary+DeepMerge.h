//
//  NSDictionary+DeepMerge.h
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DeepMerge)

+ (NSDictionary *)dictionaryByMerging:(NSDictionary *)dict1 with:(NSDictionary *)dict2;
- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)dict;

@end
