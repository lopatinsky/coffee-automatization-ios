//
//  ExtensionDelegate.h
//  Camera Obscura Extension
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <WatchKit/WatchKit.h>

extern NSString * __nonnull const kWatchNetworkManagerOrderUpdated;

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>

- (void)updateRoot;

@end
