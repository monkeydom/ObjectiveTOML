//  main.m
//  tomlutil
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.

@import Foundation;
#import "LMPTOMLSerialization.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc <= 1) {
            puts("Usage: tomlutil [-f json|xml1|binary1|toml] file\n"
                 "Defaults: a [file] of '-' reads from stdin, outputs \"normalized\" toml again.\n");
            return EXIT_SUCCESS;
        }
        
#if DEBUG
        for (int i=0; i<argc; i++) {
            puts(argv[i]);
        }
#endif
        if (argc > 1) {
            const char *filename = argv[argc-1];
            NSString *filenameString = [NSString stringWithUTF8String:filename];

            NSData *inputData = [filenameString isEqualToString:@"-"] ? ({
                [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
            }) : ({
                NSURL *fileURL =[NSURL fileURLWithPath:[filenameString stringByStandardizingPath]];
#if DEBUG
                puts(fileURL.description.UTF8String);
                puts("\n");
#endif
                [NSData dataWithContentsOfURL:fileURL];
            });
            
            NSError *error;
            __auto_type tomlObject = [LMPTOMLSerialization TOMLObjectWithData:inputData error:&error];
            if (error) {
                NSLog(@"%s error: %@",__FUNCTION__, error.debugDescription);
            }
            NSLog(@"%s %@",__FUNCTION__, tomlObject);
            
        }
    }
    return EXIT_SUCCESS;
}
