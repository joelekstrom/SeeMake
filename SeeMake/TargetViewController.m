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

@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSArray<NSArray<NSString *>*> *pathComponents;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSArray<NSURL *> *> *fileSystemCache;

@property (nonatomic, strong) NSMutableSet *selectedURLs;

@end

@implementation TargetViewController

#pragma mark - NSOutlineViewDataSource

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fileSystemCache = [NSMutableDictionary new];
    self.selectedURLs = [NSMutableSet new];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    item = item ?: self.baseURL;
    return [self objectsInDirectoryAtURL:item].count;
}

- (NSArray<NSURL *> *)objectsInDirectoryAtURL:(NSURL *)URL
{
    NSArray<NSURL *> *objects = self.fileSystemCache[URL];
    if (objects) {
        return objects;
    } else {
        NSArray<NSURL *> *objects = [[NSFileManager defaultManager] enumeratorAtURL:URL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil].allObjects;
        self.fileSystemCache[URL] = objects;
        return objects;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(NSURL *)item
{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:item.path isDirectory:&isDirectory];
    return isDirectory;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    item = item ?: self.baseURL;
    return [self objectsInDirectoryAtURL:item][index];
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

    if ([tableColumn.identifier isEqualToString:@"File"]) {
        NSTableCellView *fileCell = [outlineView makeViewWithIdentifier:@"FileCell" owner:self];
        fileCell.imageView.image = [[NSWorkspace sharedWorkspace] iconForFile:fileURL.path];
        fileCell.textField.stringValue = fileURL.lastPathComponent;
        return fileCell;
    } else if ([tableColumn.identifier isEqualToString:@"Checkbox"]) {
        NSButton *checkboxButton = [outlineView makeViewWithIdentifier:@"CheckboxCell" owner:self];
        checkboxButton.state = [self.selectedURLs containsObject:item] ? 1 : 0;
        return checkboxButton;
    }
    return nil;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    NSURL *URL = notification.userInfo[@"NSObject"];
    self.fileSystemCache[URL] = nil;
}

- (IBAction)checkboxButtonClicked:(NSButton *)button
{
    NSInteger row = [self.outlineView rowForView:button];
    NSURL *item = [self.outlineView itemAtRow:row];
    if ([self.selectedURLs containsObject:item]) {
        [self.selectedURLs removeObject:item];
    } else {
        [self.selectedURLs addObject:item];
    }
}

@end
