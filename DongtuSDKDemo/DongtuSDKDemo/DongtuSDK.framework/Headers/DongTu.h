//
//  DongTu.h
//  DongTuAPIPlus
//
//  Created by Isan Hu on 2018/8/9.
//  Copyright © 2018 Isan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTUser.h"
#import "DTGif.h"
#import "DTError.h"

@interface DongTu : NSObject

/**
 初始化

 @param appid 申请的 appid
 @param secret 申请的 secret
 */
+ (void)initWithAppId:(NSString *)appid secret:(NSString *)secret;

/**
 获取 SDK 的版本的方法

 @return SDK 的版本
 */
+ (NSString *)version;


/**
 设置app本地用户信息
 
 @param user 用户信息构造的DTUser对象
 */
+(void)setUser:(DTUser *)user;

/**
 获取流行表情数据静态方法
 
 @param page 页数
 @param pageSize 一页数据的数量
 @param completionHandler 回调处理
 */
+ (void)trendingGifsAt:(int)page
          withPageSize:(int)pageSize
     completionHandler:(void (^ __nonnull)(NSArray< DTGif *> * __nullable gifs, DTError * __nullable error))completionHandler;

/**
 获取搜索表情数据
 
 @param key 搜索关键词
 @param bypass 是否越过白名单 YES:搜索所有词；NO:只搜索白名单内的词
 @param page 页数
 @param pageSize 一页数据的数量
 @param completionHandler 回调处理
 */
+ (void)searchGifsWithKey:(NSString * _Nullable)key
       bypassKeyWhiteList:(BOOL)bypass
                       At:(int)page
             withPageSize:(int)pageSize
        completionHandler:(void (^ __nonnull)(NSString * __nonnull searchKey, NSArray< DTGif *> *__nullable gifs, DTError * __nullable error))completionHandler;

/**
 获取搜索表情数据 (默认只搜索白名单内的词)
 
 @param key 搜索关键词
 @param page 页数
 @param pageSize 一页数据的数量
 @param completionHandler 回调处理
 */
+ (void)searchGifsWithKey:(NSString * _Nullable)key
                       At:(int)page
             withPageSize:(int)pageSize
        completionHandler:(void (^ __nonnull)(NSString * __nonnull searchKey, NSArray< DTGif *> *__nullable gifs, DTError * __nullable error))completionHandler;
@end

