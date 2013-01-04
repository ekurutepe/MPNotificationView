//
//  MPViewController.m
//  MPNotificationViewTest
//
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import "MPViewController.h"
#import "MPNotificationView.h"

@interface MPViewController ()

@end

@implementation MPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) enqueueNotification1:(id)sender
{
    [MPNotificationView notifyWithText:@"Hello World!" andDetail:@"This is a test"];
}

-(IBAction) enqueueNotification2:(id)sender
{
    [MPNotificationView notifyWithText:@"Lorem Ipsum" andDetail:@"dolor sit amet"];
}

-(IBAction) enqueueNotification3:(id)sender
{
    [MPNotificationView notifyWithText:@"Grumpy wizards" andDetail:@"make a toxic brew for the jovial queen"];
}

@end
