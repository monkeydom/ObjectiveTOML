//  LMPTOMLSerialization.m
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.

#import "LMPTOMLSerialization.h"
#include "cpptoml.h"
#include "LMP_cpptoml_visitors.h"

#include <iostream>
#include <istream>
#include <streambuf>
#include <string>

NSErrorDomain const LMPTOMLErrorDomain = @"productions.monkey.lone.TOML";
static NSInteger const LMPTOMLParseErrorCode = 7031;

struct membuf : std::streambuf {
    membuf(char* begin, char* end) {
        this->setg(begin, begin, end);
    }
};

@implementation LMPTOMLSerialization

+ (NSDictionary <NSString *, id>*)TOMLObjectWithData:(NSData *)data error:(NSError **)error {
    try {
        char *bytes = (char *)data.bytes;
        membuf sbuf(bytes, bytes + data.length);
        std::istream in(&sbuf);
        cpptoml::parser p{in};
        std::shared_ptr<cpptoml::table> g = p.parse();
//        std::cout << (*g) << std::endl;
        
        // convert table to standard Objective-C objects
        toml_nsdictionary_writer dw;
        g->accept(dw);
        NSDictionary *result = dw.dictionary();
        
        return result;
    } catch (const cpptoml::parse_exception& e) {
        if (error) {
            *error = [NSError errorWithDomain:LMPTOMLErrorDomain
                                         code:LMPTOMLParseErrorCode
                                     userInfo:@{
                                                NSLocalizedDescriptionKey : @"Input TOML could not be parsed",
                                                NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"%s", e.what()],
                                                                                      }];
        }
        return nil;
    }
}
@end
