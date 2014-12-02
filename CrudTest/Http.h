//
//  Http.h
//  CrudTest
//
//  Created by devdutt on 12/1/14.
//  Copyright (c) 2014 Devjangir. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(id response,NSError *error);

@interface Http : NSObject

@property (nonatomic,copy) CompletionBlock completeBlock;

+(instancetype) sharedInstance;

/*
 Register User Request
 @param
 Parameters : dictionary of request value
 ws_type : create, update, delete, list
 Completion Block : complete block of result or error
 */
-(void) crudAPI : (NSDictionary *) parameters completionBlock : (CompletionBlock) completionBlock;

@end
