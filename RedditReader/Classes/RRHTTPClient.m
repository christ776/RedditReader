//
//  RRHTTPClient.m
//  RedditReader
//
//  Created by Christian De Martino on 8/27/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//


// Taken from http://hesh.am/2013/04/afnetworking-nsurlcache-ios-6/

#import "RRHTTPClient.h"
#import "AFJSONRequestOperation.h"

@implementation RRHTTPClient


+ (RRHTTPClient *)sharedClient {
    static RRHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[RRHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:REDDIT_BASE_URL]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(self){
        
        // See http://stackoverflow.com/questions/15349123/afnetworking-client-subclass-not-parsing-responses
        //
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    
    return self;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.name.bgqueue", NULL);
    AFHTTPRequestOperation *operation = [super HTTPRequestOperationWithRequest:urlRequest success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:urlRequest];
            if (cachedResponse != nil && [[cachedResponse data] length] > 0) {
                id JSON = [NSJSONSerialization JSONObjectWithData:cachedResponse.data options:0 error:&error];
                success(operation, JSON);
            } else {
                failure(operation, error);
            }
        } else {
            failure(operation, error);
        }
    }];
    
    return operation;
}

@end
