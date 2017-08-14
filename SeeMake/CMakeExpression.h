//
//  CMakeExpression.h
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-14.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CMakeExpression : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSArray<NSString *> *arguments;

@end
