//
//  PositionsCollectionViewController.h
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import <UIKit/UIKit.h>
#import "PositionsViewControllerProtocol.h"

@interface PositionsCollectionViewController : UICollectionViewController <PositionsViewControllerProtocol>

+ (instancetype)createViewController;

@end
