//
//  MyNotificationView.m
//  MPNotificationViewTest
//
//  Created by 利辺羅 on 2013/04/12.
//  Copyright (c) 2013年 Moped Inc. All rights reserved.
//

#import "MyNotificationView.h"

@implementation MyNotificationView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [UIView animateWithDuration:0.3
                              delay:0.2
                            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                         animations:^{
                             self.textLabel.alpha = 0.5;
                             self.detailTextLabel.alpha = 0.5;
                         }
                         completion:NULL];
    }
    
    return self;
}

@end

