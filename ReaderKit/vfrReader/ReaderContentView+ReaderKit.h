//
//  UIView+ReaderKitHook.h
//  ReaderKit
//
//  Created by Eusoft on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <vfrReader/ReaderContentView.h>
#import "REKMagnifierView.h"

@interface ReaderContentView (ReaderKit)
@property (nonatomic, strong) REKMagnifierView *magnifierView;
@property (nonatomic) int magniferLongPressCount;
@property (nonatomic, strong) ReaderContentPage *contentPage;
@end
