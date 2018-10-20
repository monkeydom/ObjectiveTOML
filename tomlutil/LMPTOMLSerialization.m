//  LMPTOMLSerialization.m
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.

#import "LMPTOMLSerialization.h"

@implementation LMPTOMLSerialization

+ (NSDictionary <NSString *, id>*)TOMLObjectWithData:(NSData *)data error:(NSError **)error {
    return @{@"TOML" : [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]};
}
@end
