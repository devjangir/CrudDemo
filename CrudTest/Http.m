//
//  Http.m
//  CrudTest
//
//  Created by devdutt on 12/1/14.
//  Copyright (c) 2014 Devjangir. All rights reserved.
//

#import "Http.h"

#define WEB @"http://localhost/crud/api.php"

@implementation Http


+(instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//crudAPI
-(void) crudAPI : (NSDictionary *) parameters completionBlock : (CompletionBlock) completionBlock {
    if(completionBlock) self.completeBlock = [completionBlock copy];
    [self sendRequest:[self getParamString:parameters]];
}

-(void) sendRequest : (NSString *) parameters {
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:WEB]];
    
    //set http method
    [request setHTTPMethod:@"POST"];

    //set request content type we MUST set this value.
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSError *_errorJson = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&_errorJson];
        //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.completeBlock(json,connectionError);
    }];
}

-(NSString *) getParamString : (NSDictionary *) parameters {
    NSMutableString *request = [[NSMutableString alloc] init];
    for (NSString *key in [parameters allKeys]) {
        [request appendString:[NSString stringWithFormat:@"%@=%@&",key,[parameters objectForKey:key]]];
    }
    return request;
}
@end
