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

- (IBAction)doList:(id)sender {
    [self startTask:self];
}

- (IBAction)startTask:(id)sender
{
    self.outputText.string = @"";   //1
    
    // get project location vars
    NSString *directory  = [self.fsPath.URL path];
            
    // setup the arguments for the task
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:@"-h"];
    [arguments addObject:directory];
    
    // change UI and run task
    [self.spinner startAnimation:self];
    [self runScript:arguments];
}

- (IBAction)stopTask:(id)sender
{
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
    }
//    [self.stopButton setEnabled:NO];
}

- (void)runScript:(NSArray*)arguments
{
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        self.isRunning = YES;
        
        @try {
            NSString *path  = [NSString stringWithFormat:@"/bin/ls"];
            
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
            [self.spinner stopAnimation:self];
            self.isRunning = NO;
        }
    });
}

#pragma mark - NSPathcontrol delegate methods

- (void)pathControl:(NSPathControl *)pathControl willPopUpMenu:(NSMenu *)menu
{
    
    _menuItems = [NSMutableArray arrayWithArray:[menu itemArray]];
    NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSetWithIndex:0];
    [indexesToRemove addIndex:1];
    [indexesToRemove addIndex:2];
    [indexesToRemove addIndex:_menuItems.count -1];
    [_menuItems removeObjectsAtIndexes:indexesToRemove];
    
    self.urlComponents = [NSMutableArray arrayWithArray:[[self.fsPath.URL path] componentsSeparatedByString:@"/"]];
    [self.urlComponents removeObjectAtIndex:0];
    self.initialPathComponents = self.urlComponents.count;
//    NSLog(@"Initial Path %@ componens: %lu", [self.fsPath.URL path], (unsigned long)self.urlComponents.count);
    
    for (int i = 0; i < _menuItems.count; i++) {
        [[_menuItems objectAtIndex:i] setTag:i];
        [[_menuItems objectAtIndex:i] setTarget:self];
        [[_menuItems objectAtIndex:i] setAction:@selector(setPath:)];
    }
}

- (void)setPath:(NSMenuItem *)item
{
    NSURL *newPath = [NSURL URLWithString:@"file://localhost"];
    
    for (int i = 0; i < _menuItems.count; i++) {
        if ([[[_menuItems objectAtIndex:i] title] isEqualToString:item.title]) {
            NSUInteger pathComponentSteps = 1 + [[_menuItems objectAtIndex:i] tag];
            for (int k = 0; k < pathComponentSteps; k++) {
                [self.urlComponents removeObjectAtIndex:self.urlComponents.count -1];
            }
            for (int j = 0; j < self.urlComponents.count; j++) {
                newPath = [newPath URLByAppendingPathComponent:[self.urlComponents objectAtIndex:j]];
            }
            if ([[newPath absoluteString] isEqualToString:@"file://localhost"]) {
                newPath = [newPath URLByAppendingPathComponent:@"Volumes"];
                newPath = [newPath URLByAppendingPathComponent:item.title];
            }
            NSLog(@"%@", [newPath absoluteString]);
        }
    }
    
    self.fsPath.URL = newPath;
    [self startTask:self];
}

@end
