//
//  EmojiCell.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "DTWebStickerCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

#define BQSSTouchEndNotification    @"BQSSTouchEndNotification"
@implementation DTWebStickerCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTouchEnd) name:BQSSTouchEndNotification object:nil];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    _emojiImageView = [[DTThumbImageView alloc] init];
    _emojiImageView.backgroundColor = [UIColor clearColor];
    _emojiImageView.contentMode = UIViewContentModeScaleAspectFit;
    _emojiImageView.clipsToBounds = YES;
    [self.contentView addSubview:_emojiImageView];
    [_emojiImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadImage)]];
    _emojiImageView.userInteractionEnabled = NO;
    
    UIEdgeInsets padding = UIEdgeInsetsMake(1, 1, 1, 1);
    [_emojiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(padding);
    }];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_loadingIndicator];
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emojiImageView.mas_centerX);
        make.centerY.equalTo(self.emojiImageView.mas_centerY);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
}

- (void)setData: (DTGif *)webSticker {
    _loadingIndicator.hidden = false;
    [_loadingIndicator startAnimating];
    _emojiImageView.userInteractionEnabled = NO;
    _picture = webSticker;
    
    NSString *urlString = _picture.isAnimated ? _picture.gifThumbImage : _picture.thumbImage;
    
    __weak typeof(self) weakSelf = self;
    [self.emojiImageView setImageWithDTUrl:urlString completHandler:^(BOOL success) {
        [weakSelf.loadingIndicator stopAnimating];
        weakSelf.loadingIndicator.hidden = true;
        if (!success) {
            weakSelf.emojiImageView.image = [UIImage imageNamed:@"loading_error"];
            weakSelf.emojiImageView.userInteractionEnabled = YES;
        }
    }];
}

- (void)reloadImage {
    [self setData:_picture];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_emojiImageView sd_cancelCurrentAnimationImagesLoad];
    _emojiImageView.image = nil;
    _emojiImageView.animationImages = nil;
    _emojiImageView.userInteractionEnabled = NO;
    [_loadingIndicator stopAnimating];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleTouchEnd {
    [self.emojiImageView startAnimating];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BQSSTouchEndNotification object:nil];
}


@end
