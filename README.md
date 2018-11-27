#  动图宇宙SDK接入说明

接入**SDK**，有以下必要步骤：

1. 下载与安装
2. 获取必要的接入信息  
3. 开始集成  

## 第一步：下载与安装

### 手动导入SDK

下载当前最新版本，解压缩后获得： `DongtuSDK`， 其中包含SDK所需的资源文件`DongtuSDKResource.bundle`和库文件`DongtuSDK.framework`


### 添加系统库依赖

您除了在工程中导入 SDK 之外，还需要添加libsqlite3.0.tbd。
在build setting中添加 Other Linker Flags: -Objc


## 第二步：获取必要的接入信息

开发者将应用与SDK进行对接时,必要接入信息如下:

* `appId` - 应用的App ID
* `appSecret` - 应用的App Secret

如您暂未获得以上接入信息，可以在此[申请](http://open.biaoqingmm.com/open/register/index.html)

## 第三步：开始集成

### 0. 注册AppId&AppSecret

在 `AppDelegate` 的 `-application:didFinishLaunchingWithOptions:` 中添加：

```objectivec
// 初始化SDK
[DongTu initWithAppId:@"your app id" secret:@"your secret"];
```

### 1. 通过 `DongTu` 提供的接口查看 SDK 版本、设置用户、获取流行表情、搜索表情

- 查看 SDK 版本

```objectivec
/**
获取 SDK 的版本的方法

@return SDK 的版本
*/
+ (NSString *)version;
```

- 设置用户

说明：可设置用户id、姓名、电话、邮箱、地址、性别及其他信息

```objectivec
/**
设置app本地用户信息

@param user 用户信息构造的DTUser对象 (详见DTUser.h)
*/
+(void)setUser:(DTUser *)user;
```

- 流行动图

```objectivec
/**
获取流行表情数据静态方法

@param page 页数
@param pageSize 一页数据的数量
@param completionHandler 回调处理
*/
+ (void)trendingGifsAt:(int)page
          withPageSize:(int)pageSize
     completionHandler:(void (^ __nonnull)(NSArray< DTGif *> * __nullable gifs, DTError * __nullable error))completionHandler;

```

- 搜索动图

```objectivec
/**
获取搜索表情数据

@param key 搜索关键词
@param bypass 是否越过白名单 YES:搜索所有词；NO:只搜索白名单内的词
@param page 页数
@param pageSize 一页数据的数量
@param completionHandler 回调处理
*/
+ (void)searchGifsWithKey:(NSString * _Nullable)key
       bypassKeyWhiteList:(BOOL)bypass
                       At:(int)page
             withPageSize:(int)pageSize
        completionHandler:(void (^ __nonnull)(NSString * __nonnull searchKey, NSArray< DTGif *> *__nullable gifs, DTError * __nullable error))completionHandler;

/**
获取搜索表情数据 (默认只搜索白名单内的词)

@param key 搜索关键词
@param page 页数
@param pageSize 一页数据的数量
@param completionHandler 回调处理
*/
+ (void)searchGifsWithKey:(NSString * _Nullable)key
                       At:(int)page
             withPageSize:(int)pageSize
        completionHandler:(void (^ __nonnull)(NSString * __nonnull searchKey, NSArray< DTGif *> *__nullable gifs, DTError * __nullable error))completionHandler;
        
```

### 2. 通过`DTThumbImageView`展示 `DongTu`接口返回的动图

```objectivec
/**
设置图片数据函数

@param urlString 图片url
*/
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString;

/**
设置图片数据函数

@param urlString 图片url
@param handler 函数回调
*/
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString completHandler:(void (^_Nullable)(BOOL success))handler;
```

例：键盘或弹窗展示图片列表

<img src="http://static.dongtu.com/apiplus_ios_preview1.png" height = "400" alt="图片名称" align=center />


### 3. 通过`DTImageView`展示 `DTGif` 

说明：
- 有版权的图片，控件底部会展示版权信息
- 控件会拦截点击事件，进入图片详情页或者图片版权详情页

```objectivec
/**
设置图片数据函数

@param urlString 图片url
@param gifId 图片id
*/
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString gifId:(NSString * _Nonnull)gifId;

/**
设置图片数据函数

@param urlString 图片url
@param gifId 图片id
@param handler 函数回调
*/
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString gifId:(NSString * _Nonnull)gifId completHandler:(void (^_Nullable)(BOOL success))handler;
```

例：展示图片消息

<img src="http://static.dongtu.com/apiplus_ios_preview2.png" height = "400" alt="图片名称" align=center />


### IM 消息发送、接收并解析展示示例 （以环信为例）

- 发送消息
```objectivec

//1.准备发送的图片
DTGif *gif = imagesArray[index];   

//2.构造消息的扩展信息
NSDictionary *msgData = @{WEBSTICKER_URL: gif.mainImage,                     //图片url
                          WEBSTICKER_IS_GIF: (gif.isAnimated ? @"1" : @"0"), //图片是否是动图
                          WEBSTICKER_ID: gif.imageId,                        //图片id
                          WEBSTICKER_WIDTH: @((float)gif.size.width),        //图片宽度
                          WEBSTICKER_HEIGHT: @((float)gif.size.height)};     //图片高度
                          
NSDictionary *extDic = @{TEXT_MESG_TYPE:TEXT_MESG_WEB_TYPE,                  //消息类型
                         TEXT_MESG_DATA:msgData
                        };

//3.DTGif的text字段作为发送的文字内容
NSString *sendStr = [@"[" stringByAppendingFormat:@"%@]", gif.text];  

//4.构造消息
EMMessage *message = [EaseSDKHelper sendTextMessage:sendStr
                                                 to:self.conversation.conversationId
                                        messageType:[self _messageTypeFromConversationType]
                                         messageExt:extDic];

//5.发送消息
[[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
    if (!aError) {
        [weakself _refreshAfterSentMessage:aMessage];
    } else {
        [weakself.tableView reloadData];
    }
}];

```

- 接收并解析展示消息
```objectivec

//1.接收并解析消息
NSDictionary *ext = message.ext;
self.mmExt = ext;
CGSize size = CGSizeZero;
if([ext[TEXT_MESG_TYPE] isEqualToString: TEXT_MESG_WEB_TYPE]) {  //判断消息类型
    NSDictionary *msgData = ext[TEXT_MESG_DATA];
    float height = [msgData[WEBSTICKER_HEIGHT] floatValue];
    float width = [msgData[WEBSTICKER_WIDTH] floatValue];
    size = CGSizeMake(width, height);      
}
self.gifSize = size;   //图片尺寸


//2.计算图片展示size
CGSize imageSize = [DTImageView sizeForImageSize:CGSizeMake(model.gifSize.width, model.gifSize.height)               
                                      imgMaxSize:CGSizeMake(200, 150)];


//3.展示消息
if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {             //判断消息类型
    NSDictionary *msgData = model.mmExt[TEXT_MESG_DATA];                            //解析消息扩展
    NSString *webStickerUrl = msgData[WEBSTICKER_URL];
    NSString *webStickerId = msgData[WEBSTICKER_ID];
    self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
    self.bubbleView.imageView.errorImage = [UIImage imageNamed:@"mm_emoji_error"];
    [self.bubbleView.imageView setImageWithDTUrl:webStickerUrl gifId:webStickerId]; //展示消息
}

```
