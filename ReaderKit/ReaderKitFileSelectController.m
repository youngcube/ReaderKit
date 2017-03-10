//
//  ReaderKitFileSelectController
//  ReaderKit
//
//  Created by cube on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import "ReaderKitFileSelectController.h"
#import <vfrReader/ReaderViewController.h>
@import FolioReaderKit;

@interface ReaderKitFileSelectController () < UITableViewDelegate, UITableViewDataSource, ReaderViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *fileList;
@property (nonatomic, copy) NSString *documentRoot;
@end

@implementation ReaderKitFileSelectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshFileList];
    [self.tableView reloadData];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)commonInit
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.fileList = [NSMutableArray array];
}

#pragma mark - File Selector

- (void)refreshFileList
{
    [self.fileList removeAllObjects];
    if (!_documentRoot)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentRoot = [paths firstObject];
    }
    
    [self emulateAndAddFile:self.documentRoot];
    
    NSArray *guidePdf = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    for (NSString *path in guidePdf) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [self.fileList addObject:path];
        }
    }
}

- (void)emulateAndAddFile:(NSString *)rootPath
{
    NSArray *tmpArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
    
    for (NSString *item in tmpArr) {
        NSString* itemPath = [rootPath stringByAppendingPathComponent:item];
        NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil];
        NSString *fileType = [attribs objectForKey:NSFileType];
        if (NSFileTypeDirectory == fileType)
        {
            [self emulateAndAddFile:itemPath];
        }
        else
        {
            if (NSFileTypeSymbolicLink == fileType)
            {
                itemPath = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:itemPath error:nil];
            }
            if ([@".docx.xlsx.pptx.pdf.key.zip.numbers.zip.pages.zip.txt.rtf.rtfd.epub" rangeOfString:[[itemPath pathExtension] lowercaseString]].location != NSNotFound) {
                [self.fileList addObject:itemPath];
            }
        }
    }
}

- (void)openFilePath:(NSString *)filePath
{
    if ([@".epub" rangeOfString:[[filePath pathExtension] lowercaseString]].location != NSNotFound)
    {
        FolioReaderConfig *config = [[FolioReaderConfig alloc] init];
        [FolioReader presentReaderWithParentViewController:self withEpubPath:filePath andConfig:config shouldRemoveEpub:NO animated:YES];
    }
    else
    {
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
        if (!document) {
            return;
        }
        ReaderViewController *fileView = [[ReaderViewController alloc] initWithReaderDocument:document];
        fileView.delegate = self;
        [self presentViewController:fileView animated:YES completion:nil];
    }
}

#pragma mark - vfr Delegate
- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[self.fileList objectAtIndex:indexPath.row] lastPathComponent];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *filePath = [self.fileList objectAtIndex:indexPath.row];
    [self openFilePath:filePath];
}

@end
