#  动图宇宙SDK接入说明

接入**SDK**，有以下必要步骤：

1. 下载与安装
2. 获取必要的接入信息  
3. 开始集成  

## 第一步：下载与安装

### 手动导入SDK

下载当前最新版本，解压缩后获得： `DongtuSDK`， 其中包含SDK和库文件`DongtuSDK.framework`及所需的资源文件`DongtuSDK.bundle`


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
[Dongtu initWithAppId:@"your app id" secret:@"your secret"];
```

### 1. 通过 `Dongtu` 提供的接口查看 SDK 版本、设置用户

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

### 3. 使用联想功能和GIF搜索模块

#### 设置SDK代理 
使用联想功能和GIF搜索模块前需要设置代理，以接收SDK的事件
```objectivec
[Dongtu sharedInstance].delegate = self;
```

#### 配置联想功能
```objectivec 
/**
 *  @param attachedView  联想UI放置在配置的attachedView上面
 *  @param input         联想根据配置的input输入框中的内容获取表情
 */
- (void)shouldShowSearchPopupAboveView:(nonnull UIView *)attachedView
                             withInput:(nonnull UIResponder <UITextInput> *)input;
```

#### 触发GIF搜索
```objectivec 
- (void)triggerSearchGifWindow;
```

#### 实现SDK代理方法
```objectivec 
//点击了联想UI和GIF UI中的表情图片代理
- (void)didSelectGif:(DTGif *)gif {
    
}
```


### 4. 表情显示：通过`DTImageView`展示 `DTGif`

#### 展示 `DTGif`
```objectivec
/**
 设置Gif图片数据函数

 @param urlString 图片url
 @param gifId 图片id
 */
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString gifId:(NSString * _Nonnull)gifId;

/**
 设置Gif图片数据函数

 @param urlString 图片url
 @param gifId 图片id
 @param handler 处理成功回调
 */
- (void)setImageWithDTUrl:(NSString * _Nonnull)urlString gifId:(NSString * _Nonnull)gifId completHandler:(void (^_Nullable)(BOOL success))handler;
```

### 5. IM 消息发送、接收并解析展示示例 （以环信为例）

发送`DTGIf`消息

```objectivec

-(void)sendGifMessage:(DTGif *)gif {
    //1.DTGif的text字段作为发送的文字内容
    NSString *sendStr = [@"[" stringByAppendingFormat:@"%@]", gif.text];

    //2.构造消息的扩展信息
    NSDictionary *msgData = @{@"sticker_url": gif.mainImage,                //图片url
                              @"is_gif": (gif.isAnimated ? @"1" : @"0"),    //图片是否是动图
                              @"data_id": gif.imageId,                      //图片id
                              @"w": @((float)gif.size.width),               //图片宽度
                              @"h": @((float)gif.size.height)};             //图片高度

    NSDictionary *extDic = @{@"txt_msgType":TEXT_MESG_WEB_TYPE,             //配置自定义消息类型
                             @"msg_data":msgData};                          //消息扩展

    //3.构造消息
    EMMessage *message = [EaseSDKHelper sendTextMessage:sendStr
                        to:self.conversation.conversationId
                        messageType:[self _messageTypeFromConversationType]
                        messageExt:extDic];
    
    //4.发送消息
    [self _sendMessage:message];
}

```

解析`DTGif`消息 & 展示 `DTGif`消息
  
```objectivec
//1.解析消息扩展，提取图片url和id
NSDictionary *extDic = messageModel.ext;
if (extDic != nil && [extDic[@"txt_msgType"] isEqualToString:@"webtype"]) {
    NSDictionary *msgData = extDic[@"msg_data"];
    if (msgData) {
        NSString *gifUrl = msgData[@"sticker_url"];
        NSString *gifId = msgData[@"data_id"];
        float height = [msgData[@"h"] floatValue];
        float width = [msgData[@"w"] floatValue];
    }
}

//2.展示

//计算图片展示size
CGSize imageSize = [DTImageView sizeForImageSize:CGSizeMake(width, height)               
                                      imgMaxSize:CGSizeMake(200, 150)];


//3.展示消息
imageView = [[DTImageView alloc] init];
[imageView setImageWithDTUrl:gifUrl gifId:gifId];
```

### 6. UI定制
SDK通过DTTheme提供一定程度的UI定制。具体参考类说明DTTheme。