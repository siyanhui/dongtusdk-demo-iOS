//
//  MMMessage.h
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DongtuSDK/DongtuSDK.h>

typedef NS_ENUM(NSUInteger, DTMessageType) {
    /*!
     Text message or photo-text message
     */
    DTMessageTypeText = 1,
    
    /*!
     big emoji message
     */
    DTMessageTypeImage = 2,
    
};

@interface DTMessage : NSObject

@property(nonatomic, assign) DTMessageType messageType;

/**
 *  text content of message
 */
@property(nonatomic, strong) NSString *messageContent;
/**
 *  the ext of message
 */
@property(nonatomic, strong) DTGif *gifData;

@property(nonatomic) CGSize pictureSize;

@property(nonatomic, strong) NSString *pictureString;


- (id)initWithMessageType:(DTMessageType)messageType messageContent:(NSString *)messageContent gifData: (DTGif *)gifData;


- (id)initWithMessageType:(DTMessageType)messageType messageContent:(NSString *)messageContent pictureString:(NSString *)pictureString pictureSize:(CGSize)pictureSize;


@end
