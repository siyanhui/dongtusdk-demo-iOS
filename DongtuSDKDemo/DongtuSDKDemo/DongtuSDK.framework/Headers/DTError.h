//
//  DTError.h
//  DongTuAPIPlus
//
//  Created by Isan Hu on 2018/11/15.
//  Copyright © 2018 Isan Hu. All rights reserved.
//

//10001: 参数错误  （会提示具体的参数错误）
//TODO key相关的错误信息会单独列出来
//20001:网络错误
//20002:网络已断开，请检查网络
//404:  未知接口
//40001: @"签名秘钥不匹配"
//500 : 接口调用失败




#import <Foundation/Foundation.h>

@interface DTError : NSObject

/**
 错误码
 */
@property (nonatomic) NSInteger errorCode;

/**
 错误信息
 */
@property (nullable, nonatomic, retain) NSString *errorMessage;

@end
