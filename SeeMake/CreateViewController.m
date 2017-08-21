//
//  CreateViewController.m
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-21.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "CreateViewController.h"

@interface CreateViewController ()

@end

@implementation CreateViewController

- (IBAction)createButtonClicked:(id)sender
{
    _buttonClicked = YES;
    [self.presentingViewController dismissViewController:self];
}

@end
