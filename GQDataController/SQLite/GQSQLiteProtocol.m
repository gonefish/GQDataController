//
//  GQSQLiteProtocol.m
//  Pods
//
//  Created by QianGuoqiang on 16/8/2.
//
//

#import "GQSQLiteProtocol.h"
#import <sqlite3.h>

@implementation GQSQLiteProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [[[request URL] scheme] isEqualToString:@"gqsqlite"];
}

- (void)startLoading
{
    
}

- (void)stopLoading
{
    
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end
