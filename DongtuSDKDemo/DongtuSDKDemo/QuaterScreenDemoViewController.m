//
//  QuaterScreenDemoViewController.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "QuaterScreenDemoViewController.h"
#import "Masonry.h"
#import "DTBaseMessageCell.h"
#import "DTTextMessageCell.h"
#import "DTImageMessageCell.h"
#import "DTMessage.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+HUD.h"

#import <DongtuSDK/DongtuSDK.h>

@interface QuaterScreenDemoViewController ()<UITableViewDelegate, UITableViewDataSource, InputToolBarViewDelegate,DongtuDelegate>{
    NSMutableArray *messagesArray;
}

@end

@implementation QuaterScreenDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"联想搜索";
    self.view.backgroundColor = [UIColor whiteColor];

    _inputToolBar = [[DTInputToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50) inputType:InputTypeQuater];
    _inputToolBar.delegate = self;
    [self.view addSubview:_inputToolBar];
    
    [_inputToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(self.inputToolBar.toolbarHeight));
    }];
    
    _messagesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _messagesTableView.backgroundColor = [UIColor whiteColor];
    _messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _messagesTableView.delegate = self;
    _messagesTableView.dataSource = self;
    _messagesTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    _messagesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [_messagesTableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)]];

    [self.view addSubview:_messagesTableView];
    
    [_messagesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(64);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.inputToolBar.mas_top);
    }];
    
    messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[Dongtu sharedInstance] shouldShowSearchPopupAboveView:_inputToolBar withInput:_inputToolBar.inputTextView];
    [Dongtu sharedInstance].delegate = self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)layoutViewsWithKeyboardFrame:(CGRect)keyboardFrame {
    [_inputToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-keyboardFrame.size.height);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(self.inputToolBar.toolbarHeight));
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollViewToBottom];
    });
}

- (void)tapToDismissKeyboard {
    [self.view endEditing:true];
}

- (void)scrollViewToBottom {
    NSUInteger finalRow = MAX(0, [self.messagesTableView numberOfRowsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.messagesTableView scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
}
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTMessage *message = (DTMessage *)messagesArray[indexPath.row];
    return [DTBaseMessageCell cellHeightFor:message];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DTMessage *message = (DTMessage *)messagesArray[indexPath.row];
    NSString *reuseId = @"";
    
    DTBaseMessageCell *cell = nil;
    switch (message.messageType) {
        case DTMessageTypeText:
        {
            reuseId = @"textMessage";
            cell = (DTTextMessageCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
            if(cell == nil) {
                cell = [[DTTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            }
            
        }
            break;
            
        case DTMessageTypeImage:
        {
            reuseId = @"bigEmojiMessage";
            cell = (DTImageMessageCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
            if(cell == nil) {
                cell = [[DTImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            }
        }
            break;
    }
    [cell set:message];
    return cell;
    
    return nil;
}

#pragma mark DongtuDelegate
- (void)didSelectGif:(DTGif *)gif {
    DTMessage *message = [[DTMessage alloc] initWithMessageType:DTMessageTypeImage messageContent:@"" gifData:gif];
    [self appendAndDisplayMessage:message];
    self.inputToolBar.inputTextView.text = @"";
}

#pragma mark <InputToolBarViewDelegate>
- (void)didTouchOtherButtonDown {
    [self showToastText:@"示例按钮,无功能"];
}

- (void)didTouchEmojiButtonDown {
    [[Dongtu sharedInstance] triggerSearchGifWindow];
}

- (void)keyboardWillShowWithFrame:(CGRect)keyboardFrame {
    [self layoutViewsWithKeyboardFrame:keyboardFrame];
}

- (void)toolbarHeightDidChangedTo:(CGFloat)height {
    CGRect tableViewFrame = _messagesTableView.frame;
    CGRect toolBarFrame = _inputToolBar.frame;
    
    toolBarFrame.origin.y = CGRectGetMaxY(_inputToolBar.frame) - height;
    toolBarFrame.size.height = height;
    tableViewFrame.size.height = toolBarFrame.origin.y;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.inputToolBar.frame = toolBarFrame;
        self.messagesTableView.frame = tableViewFrame;
    } completion:^(BOOL finished) {
        
    }];
    [self scrollViewToBottom];
}

- (void)sendTextWith:(NSString *)text {
    DTMessage *message = [[DTMessage alloc] initWithMessageType:DTMessageTypeText messageContent:text pictureString:@"" pictureSize:CGSizeZero];
    [self appendAndDisplayMessage:message];
}

#pragma mark -- private
- (void)appendAndDisplayMessage:(DTMessage *)message {
    if (!message) {
        return;
    }
    [messagesArray addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:messagesArray.count - 1 inSection:0];
    if ([self.messagesTableView numberOfRowsInSection:0] != messagesArray.count - 1) {
        NSLog(@"Error, datasource and tableview are inconsistent!!");
        [self.messagesTableView reloadData];
        return;
    }
    [self.messagesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self scrollViewToBottom];
}
@end
