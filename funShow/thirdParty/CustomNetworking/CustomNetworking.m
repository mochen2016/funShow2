//
//  CustomNetworking.m
//  WanbuIOS
//
//  Created by wy on 16/6/14.
//  Copyright © 2016年 Sun Beibei. All rights reserved.
//

#import "CustomNetworking.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

#define DEFAULT_TIMEOUT 30.0f //请求超时默认时间

static BOOL _shouldLogger = YES;
static BOOL _shouldAutoEncode = NO;
static BOOL _shouldCallbackOnCancelRequest = YES;
static CustomResponseType  _responseType = kCustomResponseTypeData;
static CustomRequestType   _requestType = kCustomRequestTypePlainText;
static CustomNetworkStatus _networkStatus = kCustomNetworkStatusUnknown;
static NSMutableArray *_requestTasks;
static NSDictionary *_httpHeaders = nil;
static NSTimeInterval _timeoutInterval = DEFAULT_TIMEOUT;

@implementation CustomNetworking

+ (void)setDefaultsConfig {
    _shouldLogger = YES;
    _shouldAutoEncode = NO;
    _requestType = kCustomRequestTypePlainText;
    _responseType = kCustomResponseTypeData;
    _shouldCallbackOnCancelRequest = YES;
    _timeoutInterval = DEFAULT_TIMEOUT;
    _httpHeaders = nil;
}

+ (CustomNetworkStatus)currentNetworkReachabilityStatus {
    return [self toCustomNetworkStatus:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus];
}

+ (CustomNetworkStatus)toCustomNetworkStatus:(AFNetworkReachabilityStatus)status {
    CustomNetworkStatus customStatus = kCustomNetworkStatusUnknown;
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            customStatus = kCustomNetworkStatusUnknown;
            break;
        case AFNetworkReachabilityStatusNotReachable:
            customStatus = kCustomNetworkStatusNotReachable;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            customStatus = kCustomNetworkStatusReachableViaWWAN;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            customStatus = kCustomNetworkStatusReachableViaWiFi;
            break;
    }
    return customStatus;
}

+ (void)detectNetwork:(void (^)(CustomNetworkStatus))block {
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        _networkStatus = [self toCustomNetworkStatus:status];
        
        if (block) {
            block(_networkStatus);
        }
    }];
}

+ (void)setLogger:(BOOL)yesOrNo {
    _shouldLogger = yesOrNo;
}

+ (void)setTimeout:(NSTimeInterval)timeout {
    _timeoutInterval = timeout;
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_requestTasks == nil) {
            _requestTasks = [[NSMutableArray alloc] init];
        }
    });
    
    return _requestTasks;
}

+ (void)cancelAllRequest {
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(CustomURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[CustomURLSessionTask class]]) {
                [task cancel];
            }
        }];
        
        [[self allTasks] removeAllObjects];
    };
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (url == nil || url.length == 0) {
        return;
    }
    
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(CustomURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[CustomURLSessionTask class]]
                && [task.currentRequest.URL.absoluteString isEqualToString:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}

+ (void)configRequestType:(CustomRequestType)requestType responseType:(CustomResponseType)responseType shouldAutoEncodeUrl:(BOOL)shouldAutoEncode callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest {
    _requestType = requestType;
    _responseType = responseType;
    _shouldAutoEncode = shouldAutoEncode;
    _shouldCallbackOnCancelRequest = shouldCallbackOnCancelRequest;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    _httpHeaders = httpHeaders;
}

+ (CustomURLSessionTask *)getWithUrl:(NSString *)url success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    return [self getWithUrl:url params:nil success:success fail:fail];
}

+ (CustomURLSessionTask *)getWithUrl:(NSString *)url params:(id)params success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    return [self getWithUrl:url params:params progress:nil success:success fail:fail];
}

+ (CustomURLSessionTask *)getWithUrl:(NSString *)url params:(id)params progress:(CustomGetProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    return [self requestWithUrl:url httpMedth:@"GET" params:params progress:progress success:success fail:fail];
}

+ (CustomURLSessionTask *)postWithUrl:(NSString *)url params:(id)params success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    return [self postWithUrl:url params:params progress:nil success:success fail:fail];
}

+ (CustomURLSessionTask *)postWithUrl:(NSString *)url params:(id)params progress:(CustomPostProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    return [self requestWithUrl:url httpMedth:@"POST" params:params progress:progress success:success fail:fail];
}

+ (CustomURLSessionTask *)requestWithUrl:(NSString *)url httpMedth:(NSString *)httpMethod params:(id)params progress:(CustomDownloadProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    
    AFHTTPSessionManager *manager = [self getSessionManagerWithURL:url];
    
    if (_shouldAutoEncode) {
        url = [self encodeUrl:url];
    }
    
    if ([NSURL URLWithString:url] == nil) {
        CustomAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return nil;
    }
    
    CustomURLSessionTask *session = nil;
    if ([httpMethod isEqualToString:@"GET"]) {
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject callback:success];
            [[self allTasks] removeObject:task];
            [self logWithSuccessResponse:responseObject url:url params:params];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error fail:fail];
            [self logWithFailError:error url:url params:params];
        }];

    }else if ([httpMethod isEqualToString:@"POST"]) {
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject callback:success];
            [[self allTasks] removeObject:task];
            [self logWithSuccessResponse:responseObject url:url params:params];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error fail:fail];
            [self logWithFailError:error url:url params:params];
        }];
    }
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

+ (CustomURLSessionTask *)uploadFileWithUrl:(NSString *)url uploadingFile:(NSString *)uploadingFile progress:(CustomUploadProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    if ([NSURL URLWithString:uploadingFile] == nil) {
        CustomAppLog(@"uploadingFile无效，无法生成URL。请检查待上传文件是否存在");
        return nil;
    }
    
    if ([NSURL URLWithString:url] == nil) {
        CustomAppLog(@"URLString无效，无法生成URL。可能是URL中有中文或特殊字符，请尝试Encode URL");
        return nil;
    }
    
    AFHTTPSessionManager *manager = [self getSessionManagerWithURL:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    CustomURLSessionTask *session = [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
        [self successResponse:responseObject callback:success];
        if (error) {
            [self handleCallbackWithError:error fail:fail];
            [self logWithFailError:error url:response.URL.absoluteString params:nil];
        } else {
            [self logWithSuccessResponse:responseObject url:response.URL.absoluteString params:nil];
        }
    }];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

+ (CustomURLSessionTask *)uploadWithImage:(UIImage *)image url:(NSString *)url filename:(NSString *)filename name:(NSString *)name mimeType:(NSString *)mimeType parameters:(id)parameters progress:(CustomUploadProgress)progress success:(CustomResponseSuccess)success fail:(CustomResponseFail)fail {
    if (_shouldAutoEncode) {
        url = [self encodeUrl:url];
    }
    
    if ([NSURL URLWithString:url] == nil) {
        CustomAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return nil;
    }
    
    AFHTTPSessionManager *manager = [self getSessionManagerWithURL:url];
    CustomURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allTasks] removeObject:task];
        [self successResponse:responseObject callback:success];
        [self logWithSuccessResponse:responseObject url:url params:parameters];
    
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allTasks] removeObject:task];
        [self handleCallbackWithError:error fail:fail];
        [self logWithFailError:error url:url params:nil];
    }];
    
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

+ (CustomURLSessionTask *)downloadWithUrl:(NSString *)url saveToPath:(NSString *)saveToPath progress:(CustomDownloadProgress)progressBlock success:(CustomResponseSuccess)success failure:(CustomResponseFail)failure {
    if ([NSURL URLWithString:url] == nil) {
        CustomAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return nil;
    }
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self getSessionManagerWithURL:url];
    CustomURLSessionTask *session = nil;
    session = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL URLWithString:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
    
        if (error == nil) {
            if (success) {
                success(filePath.absoluteString);
            }
            if (_shouldLogger) {
                CustomAppLog(@"Download success for url %@",url);
            }
        } else {
            [self handleCallbackWithError:error fail:failure];
            if (_shouldLogger) {
                CustomAppLog(@"Download fail for url %@, reason : %@",url,[error description]);
            }
        }
    }];
    
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

#pragma mark - Private
+ (AFHTTPSessionManager *)getSessionManagerWithURL:(NSString *)url {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    switch (_requestType) {
        case kCustomRequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        }
        case kCustomRequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    switch (_responseType) {
        case kCustomResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case kCustomResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case kCustomResponseTypeData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    for (NSString *key in _httpHeaders.allKeys) {
        if (_httpHeaders[key] != nil) {
            [manager.requestSerializer setValue:_httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json", @"text/html",@"text/json",@"text/plain",@"text/javascript",@"text/xml",@"image/*"]];
    manager.requestSerializer.timeoutInterval = _timeoutInterval;
    manager.operationQueue.maxConcurrentOperationCount = 3;

    /**
     *  https 证书
     */
    if ([self isHttpsRequest:url]) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        manager.securityPolicy = securityPolicy;
    }
    
    /**
     *  设置默认超时
     */
    _timeoutInterval = DEFAULT_TIMEOUT;
    
    return manager;
}


+ (BOOL)isHttpsRequest:(NSString *)url {
    NSString *const flag = @"http";
    NSRange httpRange = [url rangeOfString:flag];
    if (httpRange.location == NSNotFound) {
        return NO;
    }
    NSUInteger loc = httpRange.location + httpRange.length;
    NSString *s = [url substringWithRange:NSMakeRange(loc, 1)];
    if ([s isEqualToString:@"s"]) {
        return YES;
    }
    return NO;
}


+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    if (_shouldLogger) {
        CustomAppLog(@"\nRequest success, URL: %@\n params:%@\n response:%@\n\n",url,params,[self tryToParseData:response]);
    }
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(id)params {
    if (_shouldLogger) {
        NSString *format = @" params: ";
        if (params == nil || ![params isKindOfClass:[NSDictionary class]]) {
            format = @"";
            params = @"";
        }
        
        if ([error code] == NSURLErrorCancelled) {
            CustomAppLog(@"\nRequest was canceled mannully, URL: %@ %@%@\n\n",url,format,params);
        } else {
            CustomAppLog(@"\nRequest error, URL: %@ %@%@\n errorInfos:%@\n\n",url,format,params,[error localizedDescription]);
        }

    }
}

+ (NSString *)encodeUrl:(NSString *)url {
    NSString *charactersToEscape = @":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    if (encodedUrl) {
        return encodedUrl;
    }
    return url;
}

+ (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            id response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            if (error) {
#if __has_feature(objc_arc)
                return [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
#else
                return [[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
#endif
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

+ (void)successResponse:(id)responseData callback:(CustomResponseSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
//        success(responseData);
    }
}

+ (void)handleCallbackWithError:(NSError *)error fail:(CustomResponseFail)fail {
    if ([error code] == NSURLErrorCancelled) {
        if (_shouldCallbackOnCancelRequest) {
            if (fail) {
                fail(error);
            }
        }
    } else {
        if (fail) {
            fail(error);
        }
    }
}

@end
