//
//  EmojiCell.h
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTHotTag.h"

@interface DTHotTagCell : UICollectionViewCell
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property(strong, atomic) UIImageView *emojiImageView;
@property(strong, atomic) UILabel *wordLabel;

@property(strong, atomic) DTHotTag *picture;

- (void)setData: (DTHotTag *)hotTag;
@end
