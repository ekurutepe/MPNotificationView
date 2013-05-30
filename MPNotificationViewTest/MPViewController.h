//
//  MPViewController.h
//  MPNotificationViewTest
//
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNotificationView.h"

@interface MPViewController : UIViewController<MPNotificationViewDelegate>

-(IBAction) enqueueNotification1:(id)sender;
-(IBAction) enqueueNotification2:(id)sender;
-(IBAction) enqueueNotification3:(id)sender;
-(IBAction) enqueueNotification4:(id)sender;
-(IBAction) enqueueNotification5:(id)sender;
-(IBAction) showNextNotification:(id)sender;


@end
