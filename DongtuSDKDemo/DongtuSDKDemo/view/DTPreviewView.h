//
//  PreviewView.h
//  bqss-demo
//
//  Created by isan on 04/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DongtuSDK/DongtuSDK.h>
@protocol PreviewViewDelegate;

@interface DTPreviewView : UIView
@property(weak, nonatomic) id<PreviewViewDelegate> delegate;
@property (nonatomic, strong) UIView *maskView;
@property(strong, nonatomic) UIView *sepeLine1;
@property(strong, nonatomic) UIView *sepeLine2;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) DTThumbImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) DTGif *messageData;


- (void)setPreviewMessageData:(DTGif *)data;
@end

@protocol PreviewViewDelegate <NSObject>
- (void)cancelPreView;
- (void)sendPreviewMessageWith:(DTGif *)data;
@end
