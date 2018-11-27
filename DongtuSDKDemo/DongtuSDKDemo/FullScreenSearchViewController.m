//
//  FullScreenSearchViewController.m
//  bqss-demo
//
//  Created by isan on 04/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import <DongtuSDK/DongtuSDK.h>
#import "FullScreenSearchViewController.h"
#import "SVPullToRefresh.h"
//#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "DTWebStickerCell.h"
#import "DTMessage.h"
#import "DTPreviewView.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+HUD.h"
@interface FullScreenSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate, PreviewViewDelegate, TagsViewDelegate>{
    NSMutableArray *picturesArray;
    BOOL loadingMore;
    BOOL loadingFinished;
    BOOL showingTrending;
    int pageSize;
    int trendingPage;
    int searchPage;
    NSString *key;
    
    DTPreviewView *emojiPreview;
}

@end

@implementation FullScreenSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"搜索";
    self.view.backgroundColor = [UIColor whiteColor];
    
    pageSize = 20;
    trendingPage = 1;
    searchPage = 1;
    loadingFinished = false;
    
    NSInteger topSafeMargin = 0;
    if (@available(iOS 11.0, *)) {
        topSafeMargin = self.view.safeAreaInsets.top;
    }
    _searchContainer = [UIView new];
    _searchContainer.backgroundColor = [UIColor colorWithWhite:242.0 / 255 alpha:1.0];
    [self.view addSubview:_searchContainer];
    [_searchContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).with.offset(topSafeMargin);
        make.height.equalTo(@52);
    }];

    _sepeLine1 = [[UIView alloc] init];
    _sepeLine1.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [_searchContainer addSubview:_sepeLine1];
    [_sepeLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_top);
        make.left.equalTo(self.searchContainer.mas_left);
        make.right.equalTo(self.searchContainer.mas_right);
        make.height.equalTo(@1);
    }];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.searchBarStyle = UISearchBarStyleProminent;
    _searchBar.backgroundImage = [UIImage imageNamed:@"bg_242"];
    _searchBar.placeholder = @"搜索感兴趣的图片";
    _searchBar.tintColor = [UIColor blueColor];
    _searchBar.barTintColor = self.searchContainer.backgroundColor;
    
    UITextField *searchField = [_searchBar valueForKey:@"searchField"];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.cornerRadius = 4.0;
    }
    
    _searchBar.delegate = self;
    [self.searchContainer addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchContainer.mas_left).with.offset(5);
        make.right.equalTo(self.searchContainer.mas_right).with.offset(-5);
        make.height.equalTo(@50);
        make.centerY.equalTo(self.searchContainer.mas_centerY);
    }];
    
    _sepeLine2 = [[UIView alloc] init];
    _sepeLine2.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [self.searchContainer addSubview:_sepeLine2];
    [_sepeLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.searchContainer.mas_bottom).with.offset(-1);
        make.left.equalTo(self.searchContainer.mas_left);
        make.right.equalTo(self.searchContainer.mas_right);
        make.height.equalTo(@1);
    }];
    
    _loadingView = [UIView new];
    _loadingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingView addSubview:_loadingIndicator];
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY).with.offset(-64);
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
        make.centerY.equalTo(self.loadingView.mas_centerY).with.offset(-64);
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
        make.centerY.equalTo(self.loadingView.mas_centerY).with.offset(-64);
    }];
    _reloadButton.hidden = true;
    
    //    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)]];
    
    UICollectionViewFlowLayout *hotWordFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth = (screenWidth - 20 * 2 - 20 * 2) / 3;
    hotWordFlowLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 12 + 20 + 12);
    hotWordFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    hotWordFlowLayout.minimumInteritemSpacing = 2;
    hotWordFlowLayout.minimumLineSpacing = 12;
    hotWordFlowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    _collectionViewContainer = [[UIView alloc] init];
    _collectionViewContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionViewContainer];
    [_collectionViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    itemWidth = (screenWidth - 20 * 2 - 20 * 2) / 3;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.minimumLineSpacing = 12;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    _emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 375, 104) collectionViewLayout:flowLayout];
    _emojiCollectionView.backgroundColor = [UIColor whiteColor];
    [_emojiCollectionView registerClass:[DTWebStickerCell class] forCellWithReuseIdentifier:@"emojiCell"];
    _emojiCollectionView.delegate = self;
    _emojiCollectionView.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    [_emojiCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadNextPage];
    }];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [customView addSubview:indicator];
    indicator.center = customView.center;
    [indicator startAnimating];
    customView.backgroundColor = [UIColor clearColor];
    [_emojiCollectionView.infiniteScrollingView setCustomView:customView forState:SVInfiniteScrollingStateLoading];
    
    [self.collectionViewContainer addSubview:_emojiCollectionView];
    [_emojiCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.bottom.equalTo(self.collectionViewContainer.mas_bottom);
        make.top.equalTo(self.collectionViewContainer.mas_top);
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
    
    picturesArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self showTrending];
}


- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    NSInteger topSafeMargin = 0;
    if (@available(iOS 11.0, *)) {
        topSafeMargin = self.view.safeAreaInsets.top;
    }
    [_searchContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).with.offset(topSafeMargin);
        make.height.equalTo(@52);
    }];
}


#pragma mark: UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
    [self settagsView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
}

- (void)search {
    NSString *text = [self.searchBar.text stringByTrimmingCharactersInSet:NSMutableCharacterSet.whitespaceCharacterSet];
    if (text != nil && text.length > 0) {
        [self searchEmojisWith:text];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:true];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:true];
    if (indexPath.row < picturesArray.count) {
        DTWebStickerCell *cell = (DTWebStickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.emojiImageView.userInteractionEnabled) {
            return;
        }
        DTGif *messageData = picturesArray[indexPath.row];
        [[self emojiPreview] setPreviewMessageData:messageData];
    }
}

#pragma mark: PreViewDelegate
- (void)cancelPreView {
    [emojiPreview removeFromSuperview];
    emojiPreview = nil;
}

- (void)sendPreviewMessageWith:(DTGif *)data {
    DTMessage *message = [[DTMessage alloc] initWithMessageType:DTMessageTypeWebSticker messageContent:@"" gifData:data];
    NSDictionary *userInfo = @{@"message": message};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageNotification" object:nil userInfo:userInfo];
    
    NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [vcs removeLastObject];
    [self.navigationController setViewControllers:vcs animated:true];
}

- (NSData *)createImageDataWithImage:(NSArray *)images duration:(float) duration {
    int numFrame = (int)(images.count);
    NSMutableData *data = [[NSMutableData alloc] init];
    CGImageDestinationRef animatedGif = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, kUTTypeGIF, numFrame, NULL);
    
    int loopCount = 0;
    NSDictionary *gifProperties = @{ (NSString *)kCGImagePropertyGIFDictionary: @{ (NSString *)kCGImagePropertyGIFLoopCount : @(loopCount) } };
    CGImageDestinationSetProperties(animatedGif, (__bridge CFDictionaryRef) gifProperties);
    float singleDu = duration / numFrame;
    for (int index = 0; index < numFrame; index++) {
        
        CGImageRef cgImage = ((UIImage *)images[index]).CGImage;
        float duration = singleDu;
        NSDictionary *frameProperties = @{ (NSString *)kCGImagePropertyGIFDictionary: @{ (NSString *)kCGImagePropertyGIFDelayTime : @(duration) } };
        CGImageDestinationAddImage(animatedGif, cgImage, (__bridge CFDictionaryRef)frameProperties);
        
    }
    
    BOOL result = CGImageDestinationFinalize(animatedGif);
    CFRelease(animatedGif);
    if (result) {
        return data;
    } else {
        return nil;
    }
}

#pragma mark: TagsViewDelegate
- (void)didClickedTagButton:(UIButton *)button {
    NSString *tagName = button.titleLabel.text;
    self.searchBar.text = tagName;
    [self searchEmojisWith:tagName];
}

- (void)clearHistoryButtonClicked {
    [self clearHistoryData];
    [_tagsView setViewWithTags:@[]];
}


#pragma mark: 数据接口相关
- (void)showTrending {
    [picturesArray removeAllObjects];
    [_emojiCollectionView setContentOffset:CGPointMake(0, 0)];
    _collectionViewContainer.hidden = false;
    _loadingIndicator.hidden = false;
    [_loadingIndicator startAnimating];
    showingTrending = true;
    loadingFinished = false;
    trendingPage = 1;
    [_collectionViewContainer bringSubviewToFront:_loadingView];
    _emojiCollectionView.infiniteScrollingView.enabled = true;
    [self.view endEditing:true];
    _emptyLabel.hidden = true;
    _loadingIndicator.hidden = false;
    [self loadTrendingGifs];
}

- (void)loadTrendingGifs {
    self->loadingMore = true;
    __weak typeof(self) weakSelf = self;
    [DongTu trendingGifsAt:trendingPage withPageSize:pageSize completionHandler:^(NSArray<DTGif *> * _Nullable gifs, DTError * _Nullable error) {
        __strong FullScreenSearchViewController *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        
        [strongSelf.emojiCollectionView.infiniteScrollingView stopAnimating];
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
        __strong FullScreenSearchViewController *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.emojiCollectionView.infiniteScrollingView stopAnimating];
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

- (void)reloadFailData {
    [self.view bringSubviewToFront:_loadingView];
    _reloadButton.hidden = true;
    [_loadingIndicator startAnimating];
    [self showTrending];
}

#pragma mark -- private
- (DTPreviewView *)emojiPreview {
    if (emojiPreview == nil) {
        emojiPreview = [DTPreviewView new];
        emojiPreview.delegate = self;
        [self.view addSubview:emojiPreview];
        [emojiPreview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
            make.top.equalTo(self.view.mas_top).with.offset(64);
        }];
    }
    return emojiPreview;
}

- (void)settagsView {
    
    NSArray *tags = [self getSearchHistoryData];
    if (_tagsView == nil) {
        _tagsView = [DTSearchHistoryTagView new];
        _tagsView.delegate = self;
        [self.view addSubview:_tagsView];
    }
    
//        CGFloat tagsViewHeight = [TagsView heightForTags:tags];
    [_tagsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
//            make.height.equalTo(@(tagsViewHeight));
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [_tagsView setViewWithTags:tags];
    
    [self.view bringSubviewToFront:_tagsView];
}

- (void)searchEmojisWith:(NSString *)key {
    [_tagsView removeFromSuperview];
    _tagsView = nil;
    [self.view endEditing:true];
    
    loadingFinished = false;
    _emojiCollectionView.infiniteScrollingView.enabled = true;
    [picturesArray removeAllObjects];
    [_emojiCollectionView setContentOffset:CGPointMake(0, 0)];
    showingTrending = false;
    searchPage = 1;
    self->key = key;
    [_collectionViewContainer bringSubviewToFront:_loadingView];
    _emptyLabel.hidden = true;
    _loadingIndicator.hidden = false;
    [self.view endEditing:true];
    [self loadSearchGifsWithKey:key];
    [self updateSearchHistoryDataWith:key];
}

- (void)loadNextPage {
    if (!loadingMore) {
        if (loadingFinished) {
            [_emojiCollectionView.infiniteScrollingView stopAnimating];
            _emojiCollectionView.infiniteScrollingView.enabled = false;
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
}

- (void)updateSearchHistoryDataWith:(NSString *)searchWord { //保存最新的没有过期的10条
    NSString *searchHistoryPath = [[self rootPathForSearchData] stringByAppendingPathComponent:@"searchHistory.plist"];
    
    if (searchHistoryPath.length == 0) {
        return;
    }
    NSMutableArray *searchWords = [NSMutableArray new];
    [searchWords addObjectsFromArray:[NSMutableArray arrayWithContentsOfFile:searchHistoryPath]];
    for (NSString *word in searchWords) {
        if([searchWord isEqualToString:word]) {
            return;
        }
    }
    while (searchWords.count >= 10) {
        [searchWords removeLastObject];
    }
    [searchWords insertObject:searchWord atIndex:0];
    [searchWords writeToFile:searchHistoryPath atomically:YES];
}

- (NSArray *)getSearchHistoryData {
    NSString *searchHistoryPath = [[self rootPathForSearchData] stringByAppendingPathComponent:@"searchHistory.plist"];
    NSArray *searchArrays = [NSArray arrayWithContentsOfFile:searchHistoryPath];
    return searchArrays;
}

- (void)clearHistoryData {
    NSString *searchHistoryPath = [[self rootPathForSearchData] stringByAppendingPathComponent:@"searchHistory.plist"];
    [@[] writeToFile:searchHistoryPath atomically:YES];
}

- (NSString *)rootPathForSearchData {
    NSString *rootPath = [[self diskBaseStoreDirectory] stringByAppendingPathComponent:@"SearchHistoryData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return rootPath;
}

- (NSString *)diskBaseStoreDirectory {
    NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    return appSupportPaths[0];
}
@end
