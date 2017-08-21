//
//  TargetViewController.h
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-14.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMakeExpression.h"

@interface TargetViewController : NSViewController

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) CMakeExpression *target;

@end
