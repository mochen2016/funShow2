//
//  CustomNetworking.h
//  WanbuIOS
//
//  Created by wy on 16/6/14.
//  Copyright © 2016年 Sun Beibei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define CustomAppLog(s, ... ) NSLog( @"[%@ in line %d]------网络请求日志----->%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define CustomAppLog(s, ... )
#endif

/**
 *  下载进度
 *
 *  @param bytesRead      已下载的大小
 *  @param totalBytesRead 文件总大小
 */
typedef void (^CustomDownloadProgress)(int64_t bytesRead,int64_t totalBytesRead);
typedef CustomDownloadProgress CustomGetProgress;
typedef CustomDownloadProgress CustomPostProgress;

/**
 *  上传进度
 *
 *  @param bytesWritten       已上传的大小
 *  @param totalBytesWritten  总上传大小
 */
typedef void (^CustomUploadProgress)(int64_t bytesWritten,int64_t totalBytesWritten);


typedef NS_ENUM(NSUInteger, CustomResponseType) {
    kCustomResponseTypeData = 0, //默认
    kCustomResponseTypeJSON,
    kCustomResponseTypeXML,
};


typedef NS_ENUM(NSUInteger, CustomRequestType) {
    kCustomRequestTypePlainText = 0, //默认
    kCustomRequestTypeJSON ,
};


typedef NS_ENUM(NSInteger, CustomNetworkStatus) {
    kCustomNetworkStatusUnknown = -1, //未知
    kCustomNetworkStatusNotReachable = 0,//无网络
    kCustomNetworkStatusReachableViaWWAN ,//2,3,4G
    kCustomNetworkStatusReachableViaWiFi, //wifi
};

@class NSURLSessionTask;

typedef NSURLSessionTask CustomURLSessionTask;
/**
 * 请求成功回调block 默认在主线程中
 *
 *  @param response 为NSDictionary，NSArray，NSString三种类型
 */
typedef void(^CustomResponseSuccess)(id response);
/**
 *  请求失败回调block 默认在主线程中
 *
 *  @param error error description
 */
typedef void(^CustomResponseFail)(NSError *error);

#pragma mark - 

@interface CustomNetworking : NSObject

/**
 *  获取当前网络连接状态
 *
 *  @return CustomNetworkStatus，默认为kCustomNetworkStatusUnknown
 */
+ (CustomNetworkStatus)currentNetworkReachabilityStatus;

/**
*  网络状态变化监测
*
*  @param block
*/
+ (void)detectNetwork:(void(^)(CustomNetworkStatus status))block;


/**
 *  Log开关，全局通用，对所有请求有效
 *
 *  @param yesOrNo 默认是YES
 */
+ (void)setLogger:(BOOL)yesOrNo;


/**
 *	设置请求超时时间，默认为30秒，对单个请求有效
 *
 *	@param timeout 超时时间
 */
+ (void)setTimeout:(NSTimeInterval)timeout;


/**
 *  配置请求、响应等格式，全局通用，对所有请求有效
 *
 *  @param requestType 请求格式，默认为PlainText
 *  @param responseType 响应格式，默认为data
 *  @param shouldAutoEncode YES or NO,默认为NO，是否自动encode url
 *  @param shouldCallbackOnCancelRequest 当取消请求时，是否要回调，默认为YES
 */
+ (void)configRequestType:(CustomRequestType)requestType responseType:(CustomResponseType)responseType shouldAutoEncodeUrl:(BOOL)shouldAutoEncode callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest;


/**
 *  配置请求头，对所有请求有效，默认为空
 *
 *  @param httpHeaders 固定参数设置
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;


/**
 *  恢复全部默认配置
 */
+ (void)setDefaultsConfig;

/**
 *	取消所有请求
 */
+ (void)cancelAllRequest;

/**
 *  取消某个请求，根据请求的url，也可直接调用sessionTask的cancel方法取消请求。
 *	@param url 请求的url
 */
+ (void)cancelRequestWithURL:(NSString *)url;


/**
 *  GET请求接口1
 *
 *  @param url     接口路径
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回CustomURLSessionTask对象,可直接调用cancel取消请求
 */
+ (CustomURLSessionTask *)getWithUrl:(NSString *)url success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail;


/**
 *  GET请求接口2
 *
 *  @param url     接口路径
 *  @param params  接口中所需要的拼接参数
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回CustomURLSessionTask对象，可直接调用cancel取消请求
 */
+ (CustomURLSessionTask *)getWithUrl:(NSString *)url params:(id)params success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail;

/**
 *  GET请求接口3
 *
 *  @param url      接口路径
 *  @param params   接口中所需要的拼接参数
 *  @param progress 接口请求进度progress
 *  @param success  接口成功请求到数据的回调
 *  @param fail     接口请求数据失败的回调
 *
 *  @return 返回CustomURLSessionTask对象，可直接调用cancel取消请求
 */
+ (CustomURLSessionTask *)getWithUrl:(NSString *)url params:(id)params progress:(CustomGetProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail;


/**
 *  POST请求接口1
 *
 *  @param url     接口路径
 *  @param params  接口中所需的参数
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回CustomURLSessionTask的对象中有可取消请求的API
 */
+ (CustomURLSessionTask *)postWithUrl:(NSString *)url params:(id)params success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail;

/**
 *  POST请求接口2
 *
 *  @param url      接口路径
 *  @param params   接口中所需的参数
 *  @param progress 接口请求进度
 *  @param success  接口成功请求到数据的回调
 *  @param fail     接口请求数据失败的回调
 *
 *  @return CustomURLSessionTask对象
 */
+ (CustomURLSessionTask *)postWithUrl:(NSString *)url params:(id)params progress:(CustomPostProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail;


/**
 *	图片上传接口
 *
 *	@param image		图片对象
 *	@param url			上传图片的接口路径，如/path/images/
 *	@param filename		给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 *	@param name			与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 *	@param mimeType		默认为image/jpeg
 *	@param parameters	参数
 *	@param progress		上传进度
 *	@param success		上传成功回调
 *	@param fail			上传失败回调
 *
 *	@return
 */
+ (CustomURLSessionTask *)uploadWithImage:(UIImage *)image url:(NSString *)url filename:(NSString *)filename name:(NSString *)name mimeType:(NSString *)mimeType parameters:(id)parameters progress:(CustomUploadProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail;


/**
 *	上传文件操作
 *
 *	@param url              上传路径
 *	@param uploadingFile	待上传文件的路径
 *	@param progress			上传进度
 *	@param success			上传成功回调
 *	@param fail				上传失败回调
 *
 *	@return
 */
+ (CustomURLSessionTask *)uploadFileWithUrl:(NSString *)url uploadingFile:(NSString *)uploadingFile progress:(CustomUploadProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail;


/**
 *  下载文件
 *
 *  @param url           下载URL
 *  @param saveToPath    下载到哪个路径下
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 */
+ (CustomURLSessionTask *)downloadWithUrl:(NSString *)url saveToPath:(NSString *)saveToPath progress:(CustomDownloadProgress)progressBlock success:(CustomResponseSuccess)success failure:(CustomResponseFail)failure;


@end
