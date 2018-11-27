//
//  EmojiCell.h
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DongtuSDK/DongtuSDK.h>


@interface DTWebStickerCell : UICollectionViewCell
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property(strong, atomic) DTThumbImageView *emojiImageView;
@property(strong, atomic) DTGif *picture;

- (void)setData: (DTGif *)webSticker;
@end
