//
//  OutlineViewController.m
//  SeeMake
//
//  Created by Joel Ekström on 2017-08-07.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "OutlineViewController.h"
#import "TargetViewController.h"
#import "CreateViewController.h"
#import "CMakeProject.h"

@interface OutlineViewController() <NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate>

@property (nonatomic, strong) NSURL *rootFolderURL;
@property (nonatomic, strong) NSDictionary *folderCache;

@property (nonatomic, weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, weak) NSTableCellView *selectedCell;
@property (nonatomic, weak) IBOutlet NSView *emptyProjectView;
@property (nonatomic, weak) IBOutlet NSButton *addTargetButton;

@property (nonatomic, strong) CMakeProject *project;
@property (nonatomic, strong) NSArray<CMakeExpression *> *executableExpressions;

@property (nonatomic, assign) NSTextField *textFieldBeingEdited;

@end

@implementation OutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootFolderURL = self.pathControl.URL;
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
    BOOL projectExists = [CMakeProject projectExistsAtURL:rootFolderURL];

    if (projectExists) {
        self.project = [[CMakeProject alloc] initWithURL:rootFolderURL];
    } else {
        self.project = nil;
    }
}

- (void)setProject:(CMakeProject *)project
{
    _project = project;
    self.outlineView.hidden = project == nil;
    self.emptyProjectView.hidden = project != nil;
    self.addTargetButton.hidden = project == nil;

    if (project) {
        [self findTargets];
        [self.outlineView reloadData];
        [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
    }
}

- (void)dismissViewController:(NSViewController *)viewController
{
    [super dismissViewController:viewController];
    if ([viewController isKindOfClass:[CreateViewController class]]) {
        CreateViewController *createViewController = (CreateViewController *)viewController;
        if (createViewController.nameTextField.stringValue.length > 0) {
            [self createProjectWithName:createViewController.nameTextField.stringValue];
        }
    }
}

- (void)createProjectWithName:(NSString *)name
{
    CMakeProject *project = [CMakeProject new];
    project.name = name;
    self.project = project;
}

- (IBAction)addTarget:(id)sender
{
    CMakeExpression *expression = [[CMakeExpression alloc] init];
    expression.identifier = @"add_executable";
    expression.arguments = @[@"Target"];
    [self.project addExpression:expression];
    [self findTargets];
    [self.outlineView reloadData];

    NSInteger row = [self.outlineView rowForItem:expression];
    [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

    NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
    [cellView.textField becomeFirstResponder];
    [cellView.textField selectText:self];
}

- (void)findTargets
{
    self.executableExpressions = [self.project.expressions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == 'add_executable'"]];
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
        targetCell.textField.delegate = self;
        return targetCell;
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
    if ([selectedItem isKindOfClass:[CMakeExpression class]]) {
        TargetViewController *targetViewController = [self.storyboard instantiateControllerWithIdentifier:@"TargetViewController"];
        targetViewController.target = selectedItem;
        targetViewController.baseURL = self.rootFolderURL;

        NSSplitViewController *parentSplitViewController = (NSSplitViewController *)self.parentViewController;
        [parentSplitViewController removeSplitViewItem:parentSplitViewController.splitViewItems.lastObject];
        [parentSplitViewController addSplitViewItem:[NSSplitViewItem splitViewItemWithViewController:targetViewController]];
    }
}

@end
