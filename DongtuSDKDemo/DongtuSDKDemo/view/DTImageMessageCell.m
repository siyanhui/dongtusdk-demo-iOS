//
//  MMChatViewImageCell.m
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "DTImageMessageCell.h"
#import "UIImage+GIF.h"
@implementation DTImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setView];
    }
    
    return self;
}

- (void)setView {
    [super setView];
    _pictureView = [[DTImageView alloc] initWithFrame:CGRectZero];
    _pictureView.layer.masksToBounds = YES;
    [self.messageView addSubview:_pictureView];
    
    self.messageBubbleView.hidden = true;
}

- (void)set:(DTMessage *)messageData {
    [super set:messageData];
//    self.pictureView.image = [UIImage imageNamed:@"mm_emoji_loading"];
    [self.pictureView setImageWithDTUrl:messageData.gifData.mainImage gifId:messageData.gifData.imageId];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize messageSize = self.messageView.frame.size;
    CGSize size = [DTImageView sizeForImageSize:self.messageModel.gifData.size imgMaxSize:imageMaxSize];
    self.pictureView.frame = CGRectMake(messageSize.width - size.width - CONTENT_RIGHT_MARGIN, (messageSize.height - size.height) / 2, size.width, size.height);
}

-(void)prepareForReuse {
    [super prepareForReuse];
    [_pictureView prepareForReuse];
}



@end
