//
//  DongTu.h
//
//  Created by Isan Hu on 2018/8/9.
//  Copyright © 2018 Isan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTUser.h"
#import "DTGif.h"

/**
 Dongtu Delegate
 */
@protocol DongtuDelegate <NSObject>

@required
/**
 *  the delegate method handles the tap of gif
 */
- (void)didSelectGif:(DTGif *)gif;

@end


@interface Dongtu : NSObject

/**
 *  DongTu Singleton
 */
+ (nonnull instancetype)sharedInstance;


/**
 * DongTu Delegate
 */
@property (nonatomic, weak, nullable) id<DongtuDelegate> delegate;

/**
 *  initialize SDK
 *  Apply for appId and secret： http://open.biaoqingmm.com/open/register/index.html
 *  @param appid  the unique app id that assigned to your app
 *  @param secret the unique app secret that assigned to your app
 */
- (void)initWithAppId:(NSString *)appid secret:(NSString *)secret;

/**
 *  get the current version of SDK
 *
 *  @return the current version of SDK
 */
- (nonnull NSString *)version;


/**
 set user infomation
 */
- (void)setUser:(DTUser *)user;


/**
 *  trigger the function of `popup` (as user typing SDK try to find the emojis that matching the content that user inputs)
 
 *  @param attachedView a view that the prompts show right above
 *  @param input       input control
 */
- (void)shouldShowSearchPopupAboveView:(nonnull UIView *)attachedView
                            withInput:(nonnull UIResponder <UITextInput> *)input;

/**
 dismiss `popup`
 */
- (void)dismissSearchPopup;

/**
 trigger search gif window
 */
- (void)triggerSearchGifWindow;

@end

