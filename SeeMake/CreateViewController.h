//
//  CreateViewController.h
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-21.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CreateViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSTextField *nameTextField;
@property (nonatomic, weak) IBOutlet NSButton *createButton;
@property (nonatomic, readonly) BOOL buttonClicked;


@end
