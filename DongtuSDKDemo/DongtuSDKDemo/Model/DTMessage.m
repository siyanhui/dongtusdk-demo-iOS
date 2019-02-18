//
//  MMMessage.m
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "DTMessage.h"

@implementation DTMessage

- (id)initWithMessageType:(DTMessageType)messageType messageContent:(NSString *)messageContent gifData: (DTGif *)gifData {
    self = [super init];
    if (self) {
        self.messageType = messageType;
        self.messageContent = messageContent;
        self.gifData = gifData;
    }
    return self;
}

- (id)initWithMessageType:(DTMessageType)messageType messageContent:(NSString *)messageContent {
    
    self = [super init];
    if (self) {
        self.messageType = messageType;
        self.messageContent = messageContent;
    }
    
    return self;
}

@end
