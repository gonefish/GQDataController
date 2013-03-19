//
//  GQDataController.m
//  GQDataContrller
//
//  Created by 钱国强 on 12-12-9.
//  Copyright (c) 2012年 gonefish@gmail.com. All rights reserved.
//

#import "GQDataController.h"
#import "AFNetworking.h"

@interface GQDataController ()
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSDictionary *requestArgs;
@property (nonatomic, assign) NSInteger retryIndex;
@property (nonatomic, strong) id magicObject;
@end

@implementation GQDataController
@synthesize delegate = _delegate;
@synthesize lock = _lock;
@synthesize httpClient = _httpClient;
@synthesize requestArgs = _requestArgs;
@synthesize retryIndex = _retryIndex;
@synthesize magicObject = _magicObject;

+ (id)sharedDataController
{
    static NSMutableDictionary *_sharedInstances = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstances = [[NSMutableDictionary alloc] init];
    });
    
    NSRecursiveLock *classLock = [[NSRecursiveLock alloc] init];
    
    [classLock lock];
    
    GQDataController *aDataController = nil;
    
    NSString *keyName = NSStringFromClass([self class]);
    
    aDataController = [_sharedInstances objectForKey:keyName];
    
    if (aDataController == nil) {
        aDataController = [[self alloc] init];
        
        [_sharedInstances setObject:aDataController
                             forKey:keyName];
    }
    
    [classLock unlock];
    
    return aDataController;
}

- (id)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.lock = [[NSRecursiveLock alloc] init];
    self.retryIndex = 0;
    
    NSArray *baseURLs = [self requestBaseURL];
    
    if ([baseURLs count] > 0) {
        self.httpClient = [AFHTTPClient clientWithBaseURL:[baseURLs objectAtIndex:self.retryIndex]];
    } else {
        self.httpClient = [[AFHTTPClient alloc] init];
        
        NSLog(@"Don't found baseURL");
    }
    
    switch ([self responseDataType]) {
        case GQResponseDataTypeJSON:
            [self.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
            
            [self.httpClient setDefaultHeader:@"Accept"
                                        value:@"application/json, text/json, text/javascript"];
            
            break;
        case GQResponseDataTypePLIST:
            [self.httpClient registerHTTPOperationClass:[AFPropertyListRequestOperation class]];
            
            [self.httpClient setDefaultHeader:@"Accept"
                                        value:@"application/x-plist"];

            break;
        case GQResponseDataTypeXML:
            [self.httpClient registerHTTPOperationClass:[AFXMLRequestOperation class]];
            
            [self.httpClient setDefaultHeader:@"Accept"
                                        value:@"application/xml, text/xml"];
            break;
        default:
            // AFHTTPRequestOperation
            break;
    }
    
    return self;
}

- (id)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.delegate = aDelegate;
    
    return self;
}

- (void)requestWithArgs:(NSDictionary *)args
{    
    self.requestArgs = args;
    
    // 取消原来的请求
    [self.httpClient cancelAllHTTPOperationsWithMethod:[self requestMethod]
                                                  path:[self requestPath]];
    
    NSString *method = [self requestMethod];
    
    SEL requestSel = NSSelectorFromString([NSString stringWithFormat:@"%@Path:parameters:success:failure:", [method lowercaseString]]);
    
    if ([self.httpClient respondsToSelector:requestSel]) {
        NSMethodSignature *sig = [self.httpClient methodSignatureForSelector:requestSel];
        if (sig) {
            NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
            [invo setTarget:self.httpClient];
            [invo setSelector:requestSel];
            
            NSString *p1 = [self requestPath];
            
            void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"%@", responseObject);
                
                switch ([self responseDataType]) {
                    case GQResponseDataTypeJSON:
                        self.magicObject = responseObject;
                        
                        break;
                    case GQResponseDataTypePLIST:
                        self.magicObject = responseObject;
                        
                        break;
                    default:
                        // AFHTTPRequestOperation
                        break;
                }
                
                if (self.delegate
                    && [self.delegate respondsToSelector:@selector(loadingDataFinished:)]) {
                    
                    [self.delegate performSelector:@selector(loadingDataFinished:)
                                        withObject:self];
                }
            };
            
            void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error){
                NSLog(@"%@", error);
                
                // 失败重试
                if (self.retryIndex < [[self requestBaseURL] count]) {
                    self.retryIndex++;
                    
                    [self requestWithArgs:self.requestArgs];
                } else {
                    if (self.delegate
                        && [self.delegate respondsToSelector:@selector(loadingData:failedWithError:)]) {
                        
                        [self.delegate performSelector:@selector(loadingData:failedWithError:)
                                            withObject:self
                                            withObject:error];
                    }
                }
            };
            
            [invo setArgument:&p1 atIndex:2];
            
            NSDictionary *newArgs = [self buildRequestArgs:args];
            [invo setArgument:&newArgs atIndex:3];
            
            [invo setArgument:&successBlock atIndex:4];
            
            [invo setArgument:&failureBlock atIndex:5];
            
            [invo invoke];
        } else {
//            return nil;
        }
    }
}

- (NSDictionary *)buildRequestArgs:(NSDictionary *)args
{
    NSMutableDictionary *requestArgs = [args mutableCopy];
    
    // 默认添加ContextQueryString
    BOOL addContextQueryString = YES;
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(controllerAddContextQueryString:)]) {
        
        addContextQueryString = [self.delegate performSelector:@selector(controllerAddContextQueryString:)
                                                    withObject:self];
    }
    
    if (addContextQueryString == YES) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        [requestArgs setObject:[mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"]
                        forKey:@"gq_app_version"];
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        
        [requestArgs setObject:[currentDevice model]
                        forKey:@"gq_device_model"];
        
        [requestArgs setObject:[currentDevice systemVersion]
                        forKey:@"gq_device_version"];
        
        [requestArgs setObject:[NSNumber numberWithInt:[currentDevice userInterfaceIdiom]]
                        forKey:@"gq_user_interface_idiom"];

        NSArray *languages = [NSLocale preferredLanguages];
        
        if ([languages count] > 0) {
            [requestArgs setObject:[languages objectAtIndex:0]
                            forKey:@"gq_current_lang"];
        }
    }
    
    return [requestArgs copy];
}

#pragma mark - Subclass implementation

- (NSString *)requestMethod
{
    return @"GET";
}

- (GQResponseDataType)responseDataType
{
    return GQResponseDataTypeJSON;
}

- (NSArray *)requestBaseURL
{
    // 子类自己实现
    NSAssert(NO, @"require implementation");
    
    return nil;
}

- (NSString *)requestPath
{
    // 子类自己实现
    NSAssert(NO, @"require implementation");
    
    return nil;
}

#pragma mark - Key-Value Coding

- (id)valueForKey:(NSString *)key
{
    if ([self.magicObject isKindOfClass:[NSDictionary class]]) {
        return [self.magicObject valueForKey:key];
    } else if ([self.magicObject isKindOfClass:[NSArray class]]) {
        NSScanner *scan = [NSScanner scannerWithString:key];
        
        NSInteger intval;
        
        if ([scan scanInteger:&intval]) {
            if (intval <= [(NSArray *)self.magicObject count]) {
                return [(NSArray *)self.magicObject objectAtIndex:intval];
            }
        }
        
        return nil;
    } else if ([self.magicObject isKindOfClass:[NSString class]]) {
        return self.magicObject;
    } else {
        return nil;
    }
}

- (id)valueForKeyPath:(NSString *)keyPath
{
    if ([self.magicObject isKindOfClass:[NSDictionary class]]) {
        return [self.magicObject valueForKeyPath:keyPath];
    } else {
        return nil;
    }
}

#pragma mark - Utils

+ (NSString *)encodeURIComponent:(NSString *)string
{
	CFStringRef cfUrlEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL,
																			 (CFStringRef)string,NULL,
																			 (CFStringRef)@"!#$%&'()*+,/:;=?@[]",
																			 kCFStringEncodingUTF8);
	
	NSString *urlEncoded = [NSString stringWithString:(__bridge NSString *)cfUrlEncodedString];
	
	CFRelease(cfUrlEncodedString);
	
	return urlEncoded;
}

@end
