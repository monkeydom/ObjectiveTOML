//  LMPTOMLSerialization.h
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMPTOMLSerialization : NSObject

+ (NSDictionary <NSString *, id>*)TOMLObjectWithData:(NSData *)data error:(NSError **)error;

@end
