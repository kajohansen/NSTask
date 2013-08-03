//
//  AppDelegate.m
//  TasksProject
//
//  Created by Andy on 3/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}

- (IBAction)speak:(id)sender
{
    NSTask *task = [[NSTask alloc] init]; //1
    
    task.launchPath = @"/usr/bin/say";    //2
    
    NSString* speakingPhrase = self.phraseField.stringValue;    //3
//    task.arguments  = @[speakingPhrase];
    task.arguments  = @[@"-v", @"vicki", speakingPhrase];
    
    [task launch];    //4
    [task waitUntilExit];    //5
}

- (IBAction)startTask:(id)sender
{
    self.outputText.string = @"";   //1
    
    // get project location vars
    NSString *projectLocation  = [self.projectPath.URL path];
    NSString *finalLocation    = [self.repoPath.URL path];
    
    // get project name vars
    NSString *projectName      = [self.projectPath.URL lastPathComponent];
    NSString *xcodeProjectFile = [projectLocation stringByAppendingString:[NSString stringWithFormat:@"/%@.xcodeproj", projectName]];
    
    // set directory for build
    NSString *buildLocation    = [projectLocation stringByAppendingString:@"/build/Release-iphoneos"];
    
    // setup the arguments for the task
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:xcodeProjectFile];
    [arguments addObject:self.targetName.stringValue];
    [arguments addObject:buildLocation];
    [arguments addObject:projectName];
    [arguments addObject:finalLocation];
    
    // change UI and run task
    [self.buildButton setEnabled:NO];
    [self.stopButton setEnabled:YES];
    [self.spinner startAnimation:self];
    [self runScript:arguments];
}

- (IBAction)stopTask:(id)sender
{
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
    }
    [self.stopButton setEnabled:NO];
}

- (void)runScript:(NSArray*)arguments
{
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
//        _isRunning = YES;
        
        @try {
            NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"BuildScript" ofType:@"command"]];
            NSLog(@"Main bundle path : %@", path);
            
            self.buildTask            = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments  = arguments;
            
            // Output Handling
            self.outputPipe = [[NSPipe alloc] init]; // allocate output pipe
            self.buildTask.standardOutput = self.outputPipe; // associate pipe with task
            
            [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify]; // wait for output from the command
            
            // add observer for the output of the command
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
                                                              object:[self.outputPipe fileHandleForReading]
                                                               queue:nil usingBlock:^(NSNotification *notification)
            {
                NSData *output = [[self.outputPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                //5
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.outputText.string = [self.outputText.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", outStr]];
                    // Scroll to end of outputText field
                    NSRange range;
                    range = NSMakeRange([self.outputText.string length], 0);
                    [self.outputText scrollRangeToVisible:range];
                });
                //6
                [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            // launch and wait until done
            [self.buildTask launch];
            [self.buildTask waitUntilExit];
        }
        @catch (NSException *exception) {
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        @finally {
            [self.buildButton setEnabled:YES];
            [self.spinner stopAnimation:self];
            _isRunning = NO;
//            NSLog(@"is running : %c", _isRunning);
        }
    });
}

@end
