//
//  IHMenu.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Venue;
@class DBMenuPosition;


@interface DBMenu : NSObject

@property(nonatomic, readonly) BOOL hasNestedCategories;
@property(nonatomic, readonly) BOOL hasImages;

+ (instancetype)sharedInstance;

- (NSArray *)getMenu;

- (NSArray *)getMenuForVenue:(Venue *)venue;

- (NSArray *)getMenuForVenue:(Venue *)venue remoteMenu:(void (^)(BOOL success, NSArray *categories))remoteMenuCallback;
- (void)updateMenuForVenue:(Venue *)venue remoteMenu:(void (^)(BOOL success, NSArray *categories))remoteMenuCallback;

- (void)synchronizeWithResponseMenu:(NSArray *)responseMenu;

//Synchronize menu position with position(all user actions)
- (void)syncWithPosition:(DBMenuPosition *)position;

- (void)saveMenuToDeviceMemory;
- (void)clearMenu;
- (DBMenuPosition *)findPositionWithId:(NSString *)positionId;

@end
