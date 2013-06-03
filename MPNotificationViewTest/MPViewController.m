//
//  MPViewController.m
//  MPNotificationViewTest
//
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import "MPViewController.h"
#import "MyNotificationView.h"

@interface MPViewController ()

@end

@implementation MPViewController

+ (void)initialize
{
    [MPNotificationView registerNibNameOrClass:@"CustomNotificationView"
                        forNotificationsOfType:@"Custom"];
    [MPNotificationView registerNibNameOrClass:[MyNotificationView class]
                        forNotificationsOfType:@"Blinking"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapReceivedNotificationHandler:)
                                                 name:kMPNotificationViewTapReceivedNotification
                                               object:nil];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) enqueueNotification1:(id)sender
{
    MPNotificationView *notification = [MPNotificationView notifyWithText:@"Hello World!" andDetail:@"This is a test"];
    notification.delegate = self;
}

-(IBAction) enqueueNotification2:(id)sender
{

    [MPNotificationView notifyWithText:@"Moped Dog:"
                                detail:@"I have no idea what I'm doing..."
                                 image:[UIImage imageNamed:@"mopedDog.jpeg"]
                           andDuration:5.0];
}

-(IBAction) enqueueNotification3:(id)sender
{
    [MPNotificationView notifyWithText:@"Grumpy wizards"
                                detail:@"make a toxic brew for the jovial queen"
                         andTouchBlock:^(MPNotificationView *notificationView) {
                             NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
    }];
}

-(IBAction) enqueueNotification4:(id)sender
{

    [MPNotificationView notifyWithText:@"Custom notification"
                                detail:@"loaded from a registered Nib file"
                                 image:[UIImage imageNamed:@"mopedDog.jpeg"]
                              duration:2.0
                                  type:@"Custom"
                         andTouchBlock:^(MPNotificationView *notificationView) {
                             NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
    }];
}


- (IBAction)enqueueNotification5:(id)sender
{
    [MPNotificationView notifyWithText:@"Custom notification"
                                detail:@"instantiated from a registered Class"
                                 image:[UIImage imageNamed:@"mopedDog.jpeg"]
                              duration:2.0
                                  type:@"Blinking"
                         andTouchBlock:^(MPNotificationView *notificationView) {
                             NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
                         }];
}

- (IBAction)showNextNotification:(id)sender
{
    [MPNotificationView showNextNotification];
}

- (void)didTapOnNotificationView:(MPNotificationView *)notificationView
{
    NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
}

- (void)tapReceivedNotificationHandler:(NSNotification *)notice
{
    MPNotificationView *notificationView = (MPNotificationView *)notice.object;
    if ([notificationView isKindOfClass:[MPNotificationView class]])
    {
        NSLog( @"Received touch for notification with text: %@", ((MPNotificationView *)notice.object).textLabel.text );
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
