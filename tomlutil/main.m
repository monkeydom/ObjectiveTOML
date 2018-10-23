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
    FileFormatNone = 99991,
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

static LMPFileFormat formatFromFilename(NSString *filename) {
    // Extensions
    NSString *extension = [filename.pathExtension lowercaseString];
    LMPFileFormat result = [@{
                     @".toml" : @(FileFormatTOML),
                     @".json" : @(FileFormatJSON),
                     @".js" : @(FileFormatJSON),
                     @".plist" : @(FileFormatPlistXML),
                     }[extension] intValue];
    return result;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc <= 1) {
            NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//            NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
            NSString *cpptomlVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LPMCpptomlVersion"];

            NSString *versionLineString = [NSString stringWithFormat:@"tomlutil v%@ (cpptoml v%@)", shortVersion, cpptomlVersion];
            
            puts(versionLineString.UTF8String);
            puts("");
            puts("Usage: tomlutil [-f json|xml1|binary1|toml] file [outputfile]\n\n"
                 "A file of '-' reads from stdin. Can read json, plists and toml. Output defaults to stdout.\n"
                 "-f format   Output format. One of json, xml, binary1, toml. Defaults to toml.\n"
                 "-lint       Just lint with cpptoml, no output.");
            return EXIT_SUCCESS;
        }
        
        if (argc > 1) {
            __block LMPFileFormat inputFormat = FileFormatUnknown;
            __block LMPFileFormat outputFormat = FileFormatUnknown; // default to toml
            __block NSString *filenameString;
            __block NSString *outputFilenameString;
            
            __block NSString *flag = nil;
            
            NSMutableArray *argumentsArray = [[NSProcessInfo processInfo].arguments mutableCopy];
            argumentsArray[0] = @"tomlutil";
            
            [[NSProcessInfo processInfo].arguments enumerateObjectsUsingBlock:^(NSString *argument, NSUInteger index, BOOL *stop) {
                if (index > 0) {
                    if (flag) {
                        if ([flag isEqualToString:@"-f"]) {
                            if (outputFormat != FileFormatNone) {
                                outputFormat = [@{
                                                  @"toml" : @(FileFormatTOML),
                                                  @"json" : @(FileFormatJSON),
                                                  @"xml1" : @(FileFormatPlistXML),
                                                  @"binary1" : @(FileFormatPlistBinary),
                                                  }[argument] intValue] ?: outputFormat;
                            }
                        }
                        flag = nil;
                    } else {
                        if ([argument hasPrefix:@"-f"]) {
                            flag = argument;
                        } else if ([argument isEqualToString:@"-lint"]) {
                            outputFormat = FileFormatNone;
                            inputFormat = FileFormatTOML;
                        } else {
                            if (!filenameString) {
                                filenameString = argument;
                            } else if (!outputFilenameString) {
                                outputFilenameString = argument;
                            } else {
                                showErrorAndHalt([NSError errorWithDomain:NSPOSIXErrorDomain code:999 userInfo:@{
                                                                                                                 NSLocalizedDescriptionKey : @"Too many file arguments.",
                                                                                                                 NSLocalizedFailureReasonErrorKey : [argumentsArray componentsJoinedByString:@" "],
                                                                                                                 }], nil);
                            }
                        }
                    }
                }
            }];

            NSData *inputData = (!filenameString || [filenameString isEqualToString:@"-"]) ? ({
                [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
            }) : ({
                NSURL *fileURL =[NSURL fileURLWithPath:[filenameString stringByStandardizingPath]];
                [NSData dataWithContentsOfURL:fileURL];
            });

            
            NSError *error;
            NSDictionary<NSString *, id> *tomlObject;
            NSDictionary<NSString *, id> *dictionaryObject;

            if (inputData.length > 0) {
                
                // determine input format
                if (inputFormat == FileFormatUnknown) {
                    inputFormat = formatFromFilename(filenameString);
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
                
                if (inputFormat == FileFormatTOML) {
                    tomlObject = [LMPTOMLSerialization TOMLObjectWithData:inputData error:&error];
                    showErrorAndHalt(error, inputData);
                } else if (inputFormat == FileFormatJSON) {
                    dictionaryObject = [NSJSONSerialization JSONObjectWithData:inputData options:0 error:&error];
                    showErrorAndHalt(error, inputData);
                } else {
                    dictionaryObject = [NSPropertyListSerialization propertyListWithData:inputData options:0 format:nil error:&error];
                    showErrorAndHalt(error, inputData);
                }
            } else if (inputData) { // empty input produces empty output
                dictionaryObject = @{};
            } else {
                showErrorAndHalt([NSError errorWithDomain:NSPOSIXErrorDomain code:999 userInfo:@{
                                                                                                 NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failure to read input (%@)", filenameString ?: @"stdin"],
                                                                                                 NSLocalizedFailureReasonErrorKey : [argumentsArray componentsJoinedByString:@" "],
                                                                                                 }], nil);
            }

            if (outputFormat == FileFormatNone) {
                exit(EXIT_SUCCESS);
            } else if (outputFormat == FileFormatUnknown) {
                if (outputFilenameString) {
                    outputFormat = formatFromFilename(outputFilenameString);
                }
                if (outputFormat == FileFormatUnknown) {
                    outputFormat = FileFormatTOML;
                }
            }
            
            NSData *outputData;
            if (outputFormat == FileFormatTOML) {
                outputData = [LMPTOMLSerialization dataWithTOMLObject:tomlObject ?: dictionaryObject error:&error];
                showErrorAndHalt(error, inputData);
            } else {
                if (!dictionaryObject) {
                    dictionaryObject = [LMPTOMLSerialization serializableObjectWithTOMLObject:tomlObject];
                }
                @try {
                    if (outputFormat == FileFormatJSON) {
                        NSJSONWritingOptions options = NSJSONWritingPrettyPrinted;
                        if (@available(macOS 10.13, *)) {
                            options |= NSJSONWritingSortedKeys;
                        }
                        outputData = [NSJSONSerialization dataWithJSONObject:dictionaryObject options:options error:&error];
                        showErrorAndHalt(error, inputData);
                    } else {
                        outputData = [NSPropertyListSerialization dataWithPropertyList:dictionaryObject format:(NSPropertyListFormat)outputFormat options:0 error:&error];
                        showErrorAndHalt(error, inputData);
                    }
                }
                @catch (NSException *exception) {
                    error = [NSError errorWithDomain:NSCocoaErrorDomain code:1234 userInfo:@{
                                                                                             NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Exception in Foundation while serializing: %@", exception.name],
                                                                                             NSLocalizedFailureReasonErrorKey : exception.reason,
                                                                                             }
                             ];
                    showErrorAndHalt(error, nil);
                }
            }
            
            if (outputFilenameString) {
                NSError *error;
                [outputData writeToURL:[NSURL fileURLWithPath:[outputFilenameString stringByStandardizingPath]] options:NSDataWritingAtomic error:&error];
                showErrorAndHalt(error, nil);
            } else {
                [[NSFileHandle fileHandleWithStandardOutput] writeData:outputData];
            }
        }
    }
    return EXIT_SUCCESS;
}
