//
//  AppDelegate.m
//  HelpViewerApp
//
//  Created by Jim Derry on 5/13/16.
//  Copyright © 2016 Jim Derry. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

/* Provide a label title for the nice, little Window. This little application
   uses DEFs (in the Build Settings), but you could gleen this information
   from the Info.plist just as well.
 */
- (NSString*) labelTitle
{
    NSString *result;
    
#if defined(TARGET_FREE)
    result = @"target free";
#elif defined(TARGET_PRO)
    result = @"target pro";
#else
    result = @"undefined!";
#endif
    
    return result;
}

@end
