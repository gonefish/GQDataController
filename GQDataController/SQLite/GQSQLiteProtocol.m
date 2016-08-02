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
    NSURLRequest *request = [self request];
    
    NSString *sqlitePath = request.URL.path;
    NSString *query = @"";
    
    sqlite3 *sqlite3Database;
    
    BOOL openRel = sqlite3_open([sqlitePath UTF8String], &sqlite3Database);
    
    if (openRel == SQLITE_OK) {
        
        sqlite3_stmt *stmt;
        
        BOOL prepareRel = sqlite3_prepare_v2(sqlite3Database, [query UTF8String], -1, &stmt, NULL);
        
        NSMutableArray *resultArray = [NSMutableArray array];
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSMutableDictionary *rowDictionary = [NSMutableDictionary dictionary];
            
            int totalColumns = sqlite3_column_count(stmt);
            
            for (int i = 0; i < totalColumns; i++) {
                
                [rowDictionary removeAllObjects];
                
                // 获取column的名字
                char *columnName = sqlite3_column_name(stmt, i);
                
                NSString *keyName = [NSString stringWithUTF8String:columnName];
                
                id value = nil;
                
                // 获取column的类型
                int type = sqlite3_column_type(stmt, i);
                
                if (type == SQLITE_INTEGER) {
                    long columnInt64 = (long)sqlite3_column_int64(stmt, i);
                    
                    value = [NSNumber numberWithLong:columnInt64];
                    
                } else if (type == SQLITE_FLOAT) {
                    double columnDouble = sqlite3_column_double(stmt, i);
                    
                    value = [NSNumber numberWithDouble:columnDouble];
                    
                } else if (type == SQLITE3_TEXT) {
                    const char *columnText = (const char *)sqlite3_column_text(stmt, i);
                    
                    if (columnText) {
                        value = [NSString stringWithUTF8String:columnText];
                    } else {
                        value = @"";
                    }
                }
                
                if (keyName && value) {
                    [rowDictionary setObject:value forKey:keyName];
                }
            }
            
            [resultArray addObject:rowDictionary];
        }
        
        sqlite3_finalize(stmt);
        
        if ([NSJSONSerialization isValidJSONObject:resultArray]) {
            
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                                                                      statusCode:200
                                                                     HTTPVersion:@"HTTP/1.1"
                                                                    headerFields:@{@"Content-Type":@"application/json"}];
            
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:resultArray options:0 error:nil];
            
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:responseData];
            [self.client URLProtocolDidFinishLoading:self];
            
        } else {
            [self.client URLProtocol:self didFailWithError:nil];
        }
    }
    
    sqlite3_close(sqlite3Database);
    
}

- (void)stopLoading
{
    
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end
