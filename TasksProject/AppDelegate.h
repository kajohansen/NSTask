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
 * Project Package
 */
@property (unsafe_unretained) IBOutlet NSTextView *outputText;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSPathControl *fsPath;
@property (weak) IBOutlet NSButton *buildButton;
@property (weak) IBOutlet NSButton *stopButton;

- (IBAction)startTask:(id)sender;
- (IBAction)stopTask:(id)sender;

/**
 * NSTask 
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;


@end
