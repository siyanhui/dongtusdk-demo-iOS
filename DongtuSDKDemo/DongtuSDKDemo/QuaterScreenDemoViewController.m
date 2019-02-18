//
//  QuaterScreenDemoViewController.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//
#import <DongtuSDK/DongtuSDK.h>

#import "QuaterScreenDemoViewController.h"
#import "DTWebStickerCell.h"
#import "Masonry.h"
#import "DTBaseMessageCell.h"
#import "DTTextMessageCell.h"
#import "DTImageMessageCell.h"
//#import "UIImageView+WebCache.h"
#import "DTMessage.h"
#import "UIViewController+HUD.h"

@interface QuaterScreenDemoViewController ()<UITableViewDelegate, UITableViewDataSource, InputToolBarViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>{
    NSMutableArray *messagesArray;
    NSMutableArray *picturesArray;
    BOOL showingTrending;
    BOOL loadingMore;
    BOOL loadingFinished;
    int pageSize;
    int trendingPage;
    int searchPage;
    NSString *key;
}

@end

@implementation QuaterScreenDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageSize = 20;
    trendingPage = 1;
    searchPage = 1;
    self.title = @"联想搜索";
    self.view.backgroundColor = [UIColor whiteColor];
    
    loadingFinished = false;
//    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)]];
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
    
    _collectionViewContainer = [[UIView alloc] init];
    _collectionViewContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionViewContainer];
    [_collectionViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.inputToolBar.mas_top);
        make.height.equalTo(@105);
    }];
    _collectionViewContainer.hidden = true;
    
    _loadingView = [UIView new];
    _loadingView.backgroundColor = [UIColor whiteColor];
    [_collectionViewContainer addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionViewContainer.mas_top).with.offset(1);
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.bottom.equalTo(self.collectionViewContainer.mas_bottom).with.offset(-1);
    }];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingView addSubview:_loadingIndicator];
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    _emptyLabel = [UILabel new];
    _emptyLabel.text = @"没有表情";
    _emptyLabel.backgroundColor = [UIColor clearColor];
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.font = [UIFont systemFontOfSize:17];
    [_loadingView addSubview:_emptyLabel];
    [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY);
    }];
    _emptyLabel.hidden = true;
    
    _reloadButton = [UIButton new];
    [_reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [_reloadButton setTitleColor:[UIColor colorWithWhite:100.0 / 255 alpha:1.0] forState:UIControlStateNormal];
    _reloadButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    [_reloadButton addTarget:self action:@selector(reloadFailData) forControlEvents:UIControlEventTouchUpInside];
    _reloadButton.layer.cornerRadius = 2;
    _reloadButton.layer.borderWidth = 1;
    _reloadButton.layer.borderColor = [UIColor colorWithWhite:225.0 / 255 alpha:1.0].CGColor;
    [_loadingView addSubview:_reloadButton];
    [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY);
    }];
    _reloadButton.hidden = true;
    
    _sepeLine1 = [[UIView alloc] init];
    _sepeLine1.backgroundColor = [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [_collectionViewContainer addSubview:_sepeLine1];
    [_sepeLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionViewContainer.mas_top);
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.height.equalTo(@1);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(100, 100);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 6;
    _emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 375, 104) collectionViewLayout:flowLayout];
    _emojiCollectionView.backgroundColor = [UIColor whiteColor];
    [_emojiCollectionView registerClass:[DTWebStickerCell class] forCellWithReuseIdentifier:@"emojiCell"];
    _emojiCollectionView.delegate = self;
    _emojiCollectionView.dataSource = self;

    [self.collectionViewContainer addSubview:_emojiCollectionView];
    [_emojiCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.bottom.equalTo(self.collectionViewContainer.mas_bottom);
        make.height.equalTo(@104);
    }];
    
    _collectionViewSepe = [[UIView alloc] init];
    _collectionViewSepe.backgroundColor = [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [self.collectionViewContainer addSubview:_collectionViewSepe];
    [_collectionViewSepe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.top.equalTo(self.collectionViewContainer.mas_top);
        make.height.equalTo(@1);
    }];
    
    messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    picturesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.collectionViewContainer bringSubviewToFront:_loadingView];
    [_loadingIndicator startAnimating];
    
    [_inputToolBar didTouchEmojiDown:_inputToolBar.emojiButton];
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
            
        case DTMessageTypeWebSticker:
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


#pragma mark UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return picturesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DTWebStickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCell" forIndexPath:indexPath];
    
    if (indexPath.row < picturesArray.count) {
        DTGif *picture = picturesArray[indexPath.row];
        [cell setData:picture];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < picturesArray.count) {
        DTGif *picture = picturesArray[indexPath.row];
        CGFloat width = 100 / picture.size.height * picture.size.width;
        return CGSizeMake(width, 100);
    }
    return CGSizeMake(100, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < picturesArray.count) {
        DTWebStickerCell *cell = (DTWebStickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.emojiImageView.userInteractionEnabled) {
            return;
        }
        DTMessage *message = [[DTMessage alloc] initWithMessageType:DTMessageTypeWebSticker messageContent:@"" gifData:picturesArray[indexPath.row]];
        [self appendAndDisplayMessage:message];
        
        [_inputToolBar didTouchEmojiDown:_inputToolBar.emojiButton];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _emojiCollectionView) {
        if (!loadingMore) {
            CGPoint offSet = _emojiCollectionView.contentOffset;
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            if (offSet.x + width  > _emojiCollectionView.contentSize.width + 30) {
                NSLog(@"==========loading next page");
                loadingMore = true;
                [self loadNextPage];
            }
        }
    }
}

#pragma mark <InputToolBarViewDelegate>
- (void)didTouchOtherButtonDown {
    [self showToastText:@"示例按钮,无功能"];
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

- (void)searchEmojisWith:(NSString *)key {
    [picturesArray removeAllObjects];
    [_emojiCollectionView setContentOffset:CGPointMake(0, 0)];
    showingTrending = false;
    loadingFinished = false;
    searchPage = 1;
    self->key = key;
    [_collectionViewContainer bringSubviewToFront:_loadingView];
    _emptyLabel.hidden = true;
    _loadingIndicator.hidden = false;
    [self loadSearchGifsWithKey:key];
}

- (void)searchBarBeginOperation {
    [picturesArray removeAllObjects];
    [_emojiCollectionView setContentOffset:CGPointMake(0, 0)];
    _collectionViewContainer.hidden = false;
    _loadingIndicator.hidden = false;
    [_loadingIndicator startAnimating];
    showingTrending = true;
    loadingFinished = false;
    trendingPage = 1;
    [_collectionViewContainer bringSubviewToFront:_loadingView];
    _emptyLabel.hidden = true;
    _loadingIndicator.hidden = false;
    [self loadTrendingGifs];
}

- (void)loadTrendingGifs {
    self->loadingMore = true;
    __weak typeof(self) weakSelf = self;
    [DongTu trendingGifsAt:trendingPage withPageSize:pageSize completionHandler:^(NSArray<DTGif *> * _Nullable gifs, DTError * _Nullable error) {
        __strong QuaterScreenDemoViewController *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.loadingIndicator stopAnimating];
        if(error) {
            [strongSelf showToastText:error.errorMessage];
            NSLog(@"获取trending失败");
            if (strongSelf->trendingPage == 1) {
                strongSelf->_reloadButton.hidden = false;
            }
            strongSelf->trendingPage -= 1;
            if (strongSelf->trendingPage < 1) {
                strongSelf->trendingPage = 1;
            }
        }else{
            [strongSelf.collectionViewContainer bringSubviewToFront:strongSelf.emojiCollectionView];
            if (strongSelf->trendingPage == 1) {
                [strongSelf->picturesArray removeAllObjects];
            }
            NSArray *pics = gifs;
            
            if (pics.count > 0) {
                [strongSelf->picturesArray addObjectsFromArray:pics];
                [strongSelf.emojiCollectionView reloadData];
            }else{
                strongSelf->trendingPage -= 1;
                if (strongSelf->trendingPage < 1) {
                    strongSelf->trendingPage = 1;
                }
                
                strongSelf->loadingFinished = true;
            }
            if (strongSelf->trendingPage == 5) {
                strongSelf->loadingFinished = true;
            }
        }
        strongSelf->loadingMore = false;
    }];
}

- (void)loadSearchGifsWithKey: (NSString *)key {
    self->loadingMore = true;
    __weak typeof(self) weakSelf = self;
    [DongTu searchGifsWithKey:key At:searchPage withPageSize:pageSize completionHandler:^(NSString * _Nonnull searchKey, NSArray<DTGif *> * _Nullable gifs, DTError * _Nullable error) {
        __strong QuaterScreenDemoViewController *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.loadingIndicator stopAnimating];
        if(error) {
            [strongSelf showToastText:error.errorMessage];
            NSLog(@"查询失败");
            if (strongSelf->searchPage == 1) {
                strongSelf.reloadButton.hidden = false;
                strongSelf.loadingIndicator.hidden = true;
            }
            strongSelf->searchPage -= 1;
            if (strongSelf->searchPage < 1) {
                strongSelf->searchPage = 1;
            }
        }else{
            NSArray *pics = gifs;
            if (strongSelf->searchPage == 1) {
                [strongSelf->picturesArray removeAllObjects];
                [strongSelf.emojiCollectionView setContentOffset:CGPointMake(0, 0)];
                if (pics.count <= 0) {
                    strongSelf.loadingIndicator.hidden = true;
                    strongSelf.emptyLabel.hidden = false;
                    return;
                }else{
                    [strongSelf.collectionViewContainer bringSubviewToFront:strongSelf.emojiCollectionView];
                }
            }

            if (pics.count > 0) {
                [strongSelf->picturesArray addObjectsFromArray:pics];
                [strongSelf.emojiCollectionView reloadData];
            }else{
                strongSelf->searchPage -= 1;
                if (strongSelf->searchPage < 1) {
                    strongSelf->searchPage = 1;
                }
                
                strongSelf->loadingFinished = true;
            }
            
            if (strongSelf->searchPage == 5) {
                strongSelf->loadingFinished = true;
            }
        }
        
        strongSelf->loadingMore = false;
    }];
}

- (void)searchBarEndOperation {
    _loadingIndicator.hidden = false;
    [_loadingIndicator startAnimating];
    _collectionViewContainer.hidden = true;
}

- (void)sendTextWith:(NSString *)text {
    DTMessage *message = [[DTMessage alloc] initWithMessageType:DTMessageTypeText messageContent:text];
    [self appendAndDisplayMessage:message];
}

- (void)reloadFailData {
    [self searchBarBeginOperation];
    _reloadButton.hidden = true;
}


#pragma mark -- private
- (void)loadNextPage {
    if (loadingFinished) {
        return;
    }
    if (showingTrending) {
        self->trendingPage += 1;
        [self loadTrendingGifs];
    }else{
        self->searchPage += 1;
        [self loadSearchGifsWithKey:self->key];
    }
}

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
