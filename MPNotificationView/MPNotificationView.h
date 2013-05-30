//
//  MPNotificationView.h
//  Moped
//
//  Created by Engin Kurutepe on 1/2/13.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPNotificationView;
@protocol MPNotificationViewDelegate;

extern NSString *kMPNotificationViewTapReceivedNotification;

typedef void (^MPNotificationSimpleAction)(MPNotificationView * view);

@interface MPNotificationView : UIView

@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UILabel *detailTextLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) IBOutlet id<MPNotificationViewDelegate> delegate;

@property (nonatomic) NSTimeInterval duration;

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                            andDuration:(NSTimeInterval)duration;

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                            andDuration:(NSTimeInterval)duration;

+ (MPNotificationView *) notifyWithText:(NSString*)text
                              andDetail:(NSString*)detail;

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                               duration:(NSTimeInterval)duration
                          andTouchBlock:(MPNotificationSimpleAction)block;

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                               duration:(NSTimeInterval)duration
                          andTouchBlock:(MPNotificationSimpleAction)block;

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                          andTouchBlock:(MPNotificationSimpleAction)block;

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                               duration:(NSTimeInterval)duration
                                   type:(NSString *)type
                          andTouchBlock:(MPNotificationSimpleAction)block;


+ (void)registerNibNameOrClass:(id)nibNameOrClass
        forNotificationsOfType:(NSString *)type;
+ (void) showNextNotification;


@end

@protocol MPNotificationViewDelegate <NSObject>

@optional
- (void)didTapOnNotificationView:(MPNotificationView *)notificationView;

@end
