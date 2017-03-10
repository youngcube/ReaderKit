//
//  UIView+ReaderKitHook.h
//  ReaderKit
//
//  Created by Eusoft on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <vfrReader/ReaderContentView.h>
#import "EUMagnifierView.h"


@interface ReaderContentView (ReaderKitHook)

@property (nonatomic, strong) EUMagnifierView *magnifierView;
@property (nonatomic) int magniferLongPressCount;
@property (nonatomic, strong) ReaderContentPage *contentPage;

@end
