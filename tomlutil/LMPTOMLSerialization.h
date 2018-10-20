//  LMPTOMLSerialization.h
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const LMPTOMLErrorDomain;


@interface LMPTOMLSerialization : NSObject

+ (NSDictionary <NSString *, id>*)TOMLObjectWithData:(NSData *)data error:(NSError **)error;
+ (NSData *)dataWithTOMLObject:(NSDictionary<NSString *, id> *)tomlObject error:(NSError **)error;

@end
