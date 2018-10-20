//  LMPTOMLSerialization.m
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.

#import "LMPTOMLSerialization.h"
#include "cpptoml.h"

#include <iostream>
#include <istream>
#include <streambuf>
#include <string>

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
        std::cout << (*g) << std::endl;
    } catch (const cpptoml::parse_exception& e) {
        std::cerr << "Failed to parse toml data of length " << data.length << ": " << e.what() << std::endl;
        // TODO: properly parse exception into NSError
        if (error) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:7031 userInfo:@{
                                                                                      NSDebugDescriptionErrorKey : [NSString stringWithFormat:@"%s", e.what()]
                                                                                      }];
        }
        return nil;
    }

    
    
    return @{@"TOML" : [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]};
}
@end
