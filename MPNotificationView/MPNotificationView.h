//
//  MPNotificationView.h
//  Moped
//
//  Created by Engin Kurutepe on 1/2/13.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPNotificationView : UIView

@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, strong) UILabel * detailTextLabel;
@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic) NSTimeInterval duration;

+ (MPNotificationView*) notifyWithText:(NSString*)text
                                detail:(NSString*)detail
                                 image:(UIImage*)image
            andDuration:(NSTimeInterval)duration;
+ (MPNotificationView*) notifyWithText:(NSString*)text andDetail:(NSString*)detail andDuration:(NSTimeInterval)duration;
+ (MPNotificationView*) notifyWithText:(NSString*)text andDetail:(NSString*)detail;

@end
