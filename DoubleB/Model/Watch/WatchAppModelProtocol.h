//
//  DBWatchAppModelProtocol.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WatchAppModelProtocol <NSObject>

- (NSDictionary *)plistRepresentation;
+ (id)createWithPlistRepresentation:(NSDictionary *)plistDict;

@end
