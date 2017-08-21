//
//  TargetViewController.m
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-14.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "TargetViewController.h"
#import "CMakeExpression.h"

@interface TargetViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, strong) NSArray<NSArray<NSString *>*> *pathComponents;

@end

@implementation TargetViewController

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return _target.arguments.count - 1;
    } else {

    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        NSString *file = _target.arguments[index + 1];
        return [NSURL fileURLWithPath:file relativeToURL:self.baseURL];
    }
    return nil;
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return ![self outlineView:outlineView isGroupItem:item];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSURL *fileURL = (NSURL *)item;
    NSTableCellView *fileCell = [outlineView makeViewWithIdentifier:@"FileCell" owner:self];
    fileCell.imageView.image = [[NSWorkspace sharedWorkspace] iconForFile:fileURL.path];
    fileCell.textField.stringValue = fileURL.lastPathComponent;
    return fileCell;
}


@end
