//
//  CMakeProject.h
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-07.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMakeExpression.h"

@interface CMakeProject : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray<CMakeExpression *> *expressions;


- (instancetype)initWithURL:(NSURL *)URL;

+ (BOOL)projectExistsAtURL:(NSURL *)URL;

@end
