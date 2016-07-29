//
//  GQHTTPStub.m
//  Pods
//
//  Created by QianGuoqiang on 16/7/29.
//
//

#import "GQHTTPStub.h"

@implementation GQHTTPStub

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *localJSONPath = [request valueForHTTPHeaderField:@"X-GQHTTPStub"];
    
    if (localJSONPath > 0
        && [[NSFileManager defaultManager] fileExistsAtPath:localJSONPath]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startLoading
{
    NSURLRequest *request = [self request];
    
    NSString *localJSONPath = [[self request] valueForHTTPHeaderField:@"X-GQHTTPStub"];
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{@"Content-Type":@"application/json"}];
    
    NSError *error;
    
    NSData *responseData = [NSData dataWithContentsOfFile:localJSONPath
                                                  options:0
                                                    error:&error];
    
    if (error == nil) {
        [NSThread sleepForTimeInterval:0.5];
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:responseData];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
       [self.client URLProtocol:self didFailWithError:error];
    }
}

- (void)stopLoading
{
    
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end
