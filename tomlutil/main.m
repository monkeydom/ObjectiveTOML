//  main.m
//  tomlutil
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.

@import Foundation;
#import "LMPTOMLSerialization.h"

static void showLineWithContext(FILE *file, NSString *fullSourceString, NSInteger lineNumber, int context) {
    NSInteger lineNumberStart = MAX(1, lineNumber - context);
    NSInteger lineNumberStop = lineNumber + context;
    
    NSMutableArray <NSString *>*lineArray = [NSMutableArray new];
    __block NSInteger currentLineNumber = 1;
    [fullSourceString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (currentLineNumber >= lineNumberStart) {
            [lineArray addObject:line];
        }
        if (currentLineNumber >= lineNumberStop) { *stop = YES; }
        currentLineNumber += 1;
    }];
    currentLineNumber = lineNumberStart;
    int lineMaxWidth = (int)ceil(log10(lineNumberStop)) + 1;
    [lineArray enumerateObjectsUsingBlock:^(NSString *line, NSUInteger index, BOOL *_stop) {
        NSInteger number = index + lineNumberStart;
        fprintf(file, "%s%*ld: %s\n", number == lineNumber ? "➤" : " ", lineMaxWidth, (long)number, [[line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] UTF8String]);
    }];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc <= 1) {
            puts("Usage: tomlutil [-f json|xml1|binary1|toml] file\n"
                 "Defaults: a [file] of '-' reads from stdin, outputs \"normalized\" toml again.\n");
            return EXIT_SUCCESS;
        }
        
        if (argc > 1) {
            const char *filename = argv[argc-1];
            NSString *filenameString = [NSString stringWithUTF8String:filename];

            NSData *inputData = [filenameString isEqualToString:@"-"] ? ({
                [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
            }) : ({
                NSURL *fileURL =[NSURL fileURLWithPath:[filenameString stringByStandardizingPath]];
                [NSData dataWithContentsOfURL:fileURL];
            });
            
            NSError *error;
            __auto_type tomlObject = [LMPTOMLSerialization TOMLObjectWithData:inputData error:&error];
            if (error) {
                char *bold="";
                char *stopBold="";
                if (isatty([[NSFileHandle fileHandleWithStandardError] fileDescriptor])) {
                    bold="\033[1m";
                    stopBold="\033[0m";
                }
                fputs(bold, stderr);
                fputs("🚫 ",stderr);
                fputs(error.localizedDescription.UTF8String, stderr);
                fputs(stopBold, stderr);
                fputs("\n", stderr);
                fputs(error.localizedFailureReason.UTF8String, stderr);
                fputs("\n", stderr);
                
                if ([error.domain isEqualToString:LMPTOMLErrorDomain]) {
                    NSString *errorString = error.localizedFailureReason;
                    NSRange atLineRange = [errorString rangeOfString:@"at line "];
                    if (atLineRange.location != NSNotFound) {
                        int context = 1;
                        NSInteger lineNumber = [[errorString substringFromIndex:NSMaxRange(atLineRange)] integerValue];
                        showLineWithContext(stderr, [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding], lineNumber, context);
                    }
                }
                
            } else {
                NSLog(@"%s %@",__FUNCTION__, tomlObject);
            }
        }
    }
    return EXIT_SUCCESS;
}
