//
//  OutlineViewController.m
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-07.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "OutlineViewController.h"
#import "CMakeProject.h"

@interface OutlineViewController() <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, strong) NSURL *rootFolderURL;
@property (nonatomic, strong) NSDictionary *folderCache;

@property (nonatomic, weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;

@property (nonatomic, strong) CMakeProject *project;
@property (nonatomic, strong) NSArray<CMakeExpression *> *executableExpressions;

@end

@implementation OutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pathControlClicked:(NSPathControl *)sender
{
    [self presentOpenPanel];
}

- (void)presentOpenPanel
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse response) {
        if (response == NSModalResponseOK) {
            [self setRootFolderURL:openPanel.URLs.firstObject];
        }
    }];
}

- (void)setRootFolderURL:(NSURL *)rootFolderURL
{
    _rootFolderURL = rootFolderURL;
    self.pathControl.URL = rootFolderURL;

    if ([CMakeProject projectExistsAtURL:rootFolderURL]) {
        self.project = [[CMakeProject alloc] initWithURL:rootFolderURL];
        self.executableExpressions = [self.project.expressions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == 'add_executable'"]];
        [self.outlineView reloadData];
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil && self.project) {
        return 3 + self.executableExpressions.count;
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
        if (index == 0) {
            return @"Project";
        } else if (index == 1) {
            return self.project;
        } else if (index == 2) {
            return @"Targets";
        }
        return _executableExpressions[index - 3];
    }
    return nil;
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return [item isKindOfClass:[NSString class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return ![self outlineView:outlineView isGroupItem:item];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (item == self.project) {
        NSTableCellView *projectCell = [outlineView makeViewWithIdentifier:@"ProjectCell" owner:self];
        projectCell.textField.stringValue = self.project.name;
        return projectCell;
    } else if ([self outlineView:outlineView isGroupItem:item]) {
        NSTableCellView *headerView = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        headerView.textField.stringValue = [item uppercaseString];
        return headerView;
    } else {
        NSTableCellView *targetCell = [outlineView makeViewWithIdentifier:@"TargetCell" owner:self];
        CMakeExpression *expression = (CMakeExpression *)item;
        targetCell.textField.stringValue = expression.arguments.firstObject;
        return targetCell;
    }
}


@end
