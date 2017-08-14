//
//  CMakeExpression.m
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-14.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "CMakeExpression.h"

@implementation CMakeExpression

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.identifier, self.arguments];
}

@end
