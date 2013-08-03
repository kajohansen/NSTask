//
//  AppDelegate.h
//  TasksProject
//
//  Created by Andy on 3/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

/** 
 * Speaking
 */
@property (weak) IBOutlet NSTextField *phraseField;

- (IBAction)speak:(id)sender;

/** 
 * Project Package
 */
@property (unsafe_unretained) IBOutlet NSTextView *outputText;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSPathControl *projectPath;
@property (weak) IBOutlet NSPathControl *repoPath;
@property (weak) IBOutlet NSButton *buildButton;
@property (weak) IBOutlet NSButton *stopButton;
@property (weak) IBOutlet NSTextField *targetName;

- (IBAction)startTask:(id)sender;
- (IBAction)stopTask:(id)sender;

/**
 * NSTask 
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;


@end
