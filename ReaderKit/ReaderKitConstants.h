//
//  ReaderKitConstants.h
//  ReaderKit
//
//  Created by cube on 2017/3/12.
//  Copyright © 2017年 cube. All rights reserved.
//

#ifndef ReaderKitConstants_h
#define ReaderKitConstants_h

static NSString *const kNotificationReaderKitShouldShowWordCaptured = @"ReaderKitShouldShowWordCapturedNotification";
static NSString *const kNotificationReaderKitShouldClearCapturedWord = @"ReaderKitShouldClearCapturedWordNotification";
#endif /* ReaderKitConstants_h */

#ifdef _EUDIC_
#define READERKIT_OCR_LANG "eng"
#endif

#ifdef _FRHELPER_
#define READERKIT_OCR_LANG "fra"
#endif

#ifdef _DEHELPER_
#define READERKIT_OCR_LANG "deu"
#endif

#ifdef _ESHELPER_
#define READERKIT_OCR_LANG "spa"
#endif
