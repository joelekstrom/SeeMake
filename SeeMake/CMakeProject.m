//
//  CMakeProject.m
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-07.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "CMakeProject.h"
#include "cmListFileLexer.h"
#import "CMakeExpression.h"

@interface CMakeProject()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<CMakeExpression *> *expressions;

@end

@implementation CMakeProject

- (instancetype)initWithURL:(NSURL *)URL
{
    if (self = [super init]) {
        [self parseFileAtURL:[CMakeProject findCMakeListsAtURL:URL]];
        for (CMakeExpression *expression in self.expressions) {
            if ([expression.identifier isEqualToString:@"project"]) {
                self.name = expression.arguments.firstObject;
                break;
            }
        }
    }
    return self;
}

- (void)parseFileAtURL:(NSURL *)fileURL
{
    NSString *path = fileURL.path;
    const char *cStringPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    cmListFileLexer *lexer = cmListFileLexer_New();
    cmListFileLexer_BOM BOM = cmListFileLexer_BOM_UTF8;
    cmListFileLexer_SetFileName(lexer, cStringPath, &BOM);

    self.expressions = @[];
    CMakeExpression *expression = nil;
    while ((expression = [self parseExpressionWithLexer:lexer])) {
        self.expressions = [self.expressions arrayByAddingObject:expression];
    }
}

- (CMakeExpression *)parseExpressionWithLexer:(cmListFileLexer *)lexer
{
    CMakeExpression *expression = nil;
    cmListFileLexer_Token *token = NULL;

    while ((token = cmListFileLexer_Scan(lexer))) {
        if (token->type == cmListFileLexer_Token_Space || token->type == cmListFileLexer_Token_Newline)
            continue;
         else if (token->type == cmListFileLexer_Token_ParenLeft) {
            expression.arguments = [self parseArgumentsWithLexer:lexer];
            break;
         } else {
             NSAssert(expression == nil, @"an expression should get a single identifier");
             expression = [[CMakeExpression alloc] init];
             expression.identifier = [[NSString alloc] initWithCString:token->text encoding:NSUTF8StringEncoding];
         }
    }
    return expression;
}

- (NSArray *)parseArgumentsWithLexer:(cmListFileLexer *)lexer
{
    NSMutableArray<NSString *> *arguments = [NSMutableArray new];
    cmListFileLexer_Token *token = NULL;
    while ((token = cmListFileLexer_Scan(lexer))) {
        if (token->type == cmListFileLexer_Token_Space || token->type == cmListFileLexer_Token_Newline)
            continue;
        else if (token->type == cmListFileLexer_Token_ParenRight)
            break;
        else
            [arguments addObject:[[NSString alloc] initWithCString:token->text encoding:NSUTF8StringEncoding]];
    }
    return [arguments copy];
}

+ (BOOL)projectExistsAtURL:(NSURL *)URL
{
    return [self findCMakeListsAtURL:URL] != nil;
}

+ (NSURL *)findCMakeListsAtURL:(NSURL *)URL
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:URL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
        NSLog(@"Unhandled Error: %@", error);
        return NO;
    }];

    for (NSURL *URL in enumerator) {
        if ([URL.lastPathComponent isEqualToString:@"CMakeLists.txt"]) {
            return URL;
        }
    }
    return nil;
}

@end
