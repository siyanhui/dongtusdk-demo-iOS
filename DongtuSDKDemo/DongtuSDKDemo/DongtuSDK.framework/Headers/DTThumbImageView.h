//
//  DTThumbImageView.h
//  DongTuAPIPlusKit
//
//  Created by Isan Hu on 2018/8/9.
//  Copyright © 2018 Isan Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTThumbImageView : UIImageView

/**
 设置图片数据函数
 
 @param urlString 图片url
 */
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString;

/**
 设置图片数据函数
 
 @param urlString 图片url
 @param handler 函数回调
 */
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString completHandler:(void (^_Nullable)(BOOL success))handler;
@end
