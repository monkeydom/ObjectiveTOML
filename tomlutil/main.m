//  main.m
//  tomlutil
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.

@import Foundation;
#import "LMPTOMLSerialization.h"

typedef CF_ENUM(int, LMPFileFormat) {
    FileFormatUnknown = 0,
    FileFormatPlistBinary = kCFPropertyListBinaryFormat_v1_0,
    FileFormatPlistXML = kCFPropertyListXMLFormat_v1_0,
//    FileFormatPlistOpenStep = kCFPropertyListOpenStepFormat, cannot write anymore anyways
    FileFormatJSON = 801,
    FileFormatTOML = 901,
};

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

void showErrorAndHalt(NSError *error, NSData *inputData) {
    if (!error) {
        return;
    }
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
    
    exit(EXIT_FAILURE);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc <= 1) {
            puts("Usage: tomlutil [-f json|xml1|binary1|toml] file\n"
                 "Defaults: a [file] of '-' reads from stdin, outputs \"normalized\" toml again.\n");
            return EXIT_SUCCESS;
        }
        
        if (argc > 1) {
            __block LMPFileFormat inputFormat = FileFormatUnknown;
            __block LMPFileFormat outputFormat = FileFormatTOML; // default to toml
            __block NSString *filenameString;
            
            __block NSString *flag = nil;
            
            [[NSProcessInfo processInfo].arguments enumerateObjectsUsingBlock:^(NSString *argument, NSUInteger index, BOOL *stop) {
                if (index > 0) {
                    if (flag) {
                        if ([flag isEqualToString:@"-f"]) {
                            outputFormat = [@{
                                              @"toml" : @(FileFormatTOML),
                                              @"json" : @(FileFormatJSON),
                                              @"xml1" : @(FileFormatPlistXML),
                                              @"binary1" : @(FileFormatPlistBinary),
                                              }[argument] intValue] ?: outputFormat;
                        }
                        flag = nil;
                    } else {
                        if ([argument hasPrefix:@"-f"]) {
                            flag = argument;
                        } else {
                            filenameString = argument;
                        }
                    }
                }
            }];

            NSData *inputData = [filenameString isEqualToString:@"-"] ? ({
                [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
            }) : ({
                NSURL *fileURL =[NSURL fileURLWithPath:[filenameString stringByStandardizingPath]];
                [NSData dataWithContentsOfURL:fileURL];
            });

            
            // determine input format
            if (inputFormat == FileFormatUnknown) {
                // Extensions
                NSString *extension = [filenameString.pathExtension lowercaseString];
                inputFormat = [@{
                                 @".toml" : @(FileFormatTOML),
                                 @".json" : @(FileFormatJSON),
                                 @".js" : @(FileFormatJSON),
                                 @".plist" : @(FileFormatPlistXML),
                                 }[extension] intValue];
            }

            if (inputFormat == FileFormatUnknown) {
                // check first bytes
                char *bytes = (char *)inputData.bytes;
                if (bytes[0] == '<' &&
                    bytes[1] == '?') {
                    inputFormat = FileFormatPlistXML;
                } else if ([inputData length] > 6 && [[[NSString alloc] initWithBytes:bytes length:6 encoding:NSASCIIStringEncoding] isEqualToString:@"bplist"]) {
                    inputFormat = FileFormatPlistBinary;
                } else if (bytes[0] == '{') {
                    inputFormat = FileFormatJSON;
                }
            }
            
            if (inputFormat == FileFormatUnknown) {
                inputFormat = FileFormatTOML; // default to TOML if nothing else was found
            }
            
            NSError *error;
        
            NSDictionary<NSString *, id> *tomlObject;
            NSDictionary<NSString *, id> *dictionaryObject;
            if (inputFormat == FileFormatTOML) {
                tomlObject = [LMPTOMLSerialization TOMLObjectWithData:inputData error:&error];
                showErrorAndHalt(error, inputData);
                dictionaryObject = tomlObject;
            } else if (inputFormat == FileFormatJSON) {
                dictionaryObject = [NSJSONSerialization JSONObjectWithData:inputData options:0 error:&error];
                showErrorAndHalt(error, inputData);
            } else {
                dictionaryObject = [NSPropertyListSerialization propertyListWithData:inputData options:0 format:nil error:&error];
                showErrorAndHalt(error, inputData);
            }
            

            NSData *outputData;
            if (outputFormat == FileFormatTOML) {
                outputData = [LMPTOMLSerialization dataWithTOMLObject:tomlObject ?: dictionaryObject error:&error];
                showErrorAndHalt(error, inputData);
            } else if (outputFormat == FileFormatJSON) {
                outputData = [NSJSONSerialization dataWithJSONObject:dictionaryObject options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys error:&error];
                showErrorAndHalt(error, inputData);
            } else {
                outputData = [NSPropertyListSerialization dataWithPropertyList:dictionaryObject format:(NSPropertyListFormat)outputFormat options:0 error:&error];
                showErrorAndHalt(error, inputData);
            }
            // TODO: convert NSDateComponents back to strings again after handling dates special again
            
            [[NSFileHandle fileHandleWithStandardOutput] writeData:outputData];
        }
    }
    return EXIT_SUCCESS;
}
