//
//  PopupNewsViewController.h
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import <UIKit/UIKit.h>
#import "DBPopupViewController.h"

#import "PopupNewsViewControllerProtocol.h"

@interface PopupNewsViewController : UIViewController <PopupNewsViewControllerProtocol, DBPopupViewControllerContent>

@end
