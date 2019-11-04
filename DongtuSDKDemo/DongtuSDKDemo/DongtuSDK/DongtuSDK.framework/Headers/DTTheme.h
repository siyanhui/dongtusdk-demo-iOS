//
//  DTTheme.h
//  DongTuAPIPlusKit
//
//  Created by Isan Hu on 2018/8/2.
//  Copyright © 2018 Isan Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTTheme : NSObject


/**
 DTTheme 单例
 */
+ (instancetype _Nonnull )sharedTheme;

/**
 图片左下角文字背景色
 */
@property (nonatomic, strong, nullable) UIColor *emojiTitleBgColor;

/**
 图片左下角第一个label的颜色
 */
@property (nonatomic, strong, nullable) UIColor *emojiTitle1Color;

/**
 图片左下角第二个label的颜色
 */
@property (nonatomic, strong, nullable) UIColor *emojiTitle2Color;

/**
 图片详情页navigationbar title fonts
 */
@property (nonatomic, strong, nullable) UIFont *navigationTitleFont;

/**
 图片详情页navigationbar 背景色
 */
@property (nonatomic, strong, nullable) UIColor  *navigationBarColor;

/**
 navigationbar tint color
 */
@property (nonatomic, strong, nullable) UIColor  *navigationBarTintColor;


/**
 图片详情页加载失败提示文字字体
 */
@property (nonatomic, strong, nullable) UIFont   *loadFailedLabelFont;

/**
 图片详情页加载失败提示文字颜色
 */
@property (nonatomic, strong, nullable) UIColor  *loadFailedLabelColor;

/**
 图片详情页加载失败 重新加载按钮字体
 */
@property (nonatomic, strong, nullable) UIFont   *reloadBtnFont;

/**
 图片详情页加载失败 重新加载按钮文字颜色
 */
@property (nonatomic, strong, nullable) UIColor  *reloadBtnColor;


//关于 gif keyboard
/**
 gif keyboard => 热门关键词按钮文字字体
 */
@property (nonatomic, strong, nullable) UIFont *gifKeyboardHotWordButtonTitleFont;
/**
 gif keyboard => 热门关键词按钮文字颜色
 */
@property (nonatomic, strong, nullable) UIColor *gifKeyboardHotWordButtonTitleColor;
/**
 gif keyboard => 热门关键词按钮背景颜色
 */
@property (nonatomic, strong, nullable) UIColor *gifKeyboardHotWordButtonBgColor;
/**
 gif keyboard => 热门关键词按钮边框颜色
 */
@property (nonatomic, strong, nullable) UIColor *gifKeyboardHotWordButtonBorderColor;
/**
 gif keyboard => 热门关键词按钮边框宽度
 */
@property (nonatomic, assign) CGFloat gifKeyboardHotWordButtonBorderWidth;
/**
 gif keyboard => 热门关键词按钮圆角半径
 */
@property (nonatomic, assign) CGFloat gifKeyboardHotWordButtonCornerRadius;

/**
 gif keyboard => search bar text font
 */
@property (nonatomic, strong, nullable) UIFont *gifKeyboardSearchBarTextFont;
/**
 gif keyboard => 搜索框文字颜色
 */
@property (nonatomic, strong, nullable) UIColor *gifKeyboardSearchBarTextColor;
/**
 gif keyboard => 搜索框背景颜色
 */
@property (nonatomic, strong, nullable) UIColor *gifKeyboardSearchBarBgColor;
/**
 gif keyboard => 搜索框边框颜色
 */
@property (nonatomic, strong, nullable) UIColor *gifKeyboardSearchBarBorderColor;
/**
 gif keyboard => 搜索框边框宽度
 */
@property (nonatomic, assign) CGFloat gifKeyboardSearchBarBorderWidth;
/**
 gif keyboard => 搜索框圆角半径
 */
@property (nonatomic, assign) CGFloat gifKeyboardSearchBarCornerRadius;


@end
