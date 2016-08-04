//
//  GQSQLiteProtocol.h
//  Pods
//
//  Created by QianGuoqiang on 16/8/2.
//
//

#import <Foundation/Foundation.h>

@interface GQSQLiteProtocol : NSURLProtocol

@end

extern NSString * const GQSQLiteURLQueryKey;
extern NSString * const GQSQLiteURLProtocolKey;

@interface NSString (GQSQLiteProtocol)

+ (instancetype)sqliteURLStringWithDatabaseName:(NSString *)databaseName sql:(NSString *)sql;

- (NSString *)stringByBindSQLiteWithParams:(NSDictionary *)params;

@end

@interface NSURL (GQSQLiteProtocol)

+ (instancetype)sqliteURLWithDatabaseName:(NSString *)databaseName sql:(NSString *)sql;

- (NSString *)gq_sql;

@end
