#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "Masonry.h"
#import "FrtcCall.h"
#import "FrtcMeetingManagement.h"
#import "FrtcUserDefault.h"
#import "FrtcCallInterface.h"
#import "FrtcMainViewController.h"
#import "FrtcAccountViewController.h"
#import "CommonNotification.h"
#import "FrtcUpdateMediaDevice.h"
#import "FrtcVersionManager.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CGDisplayRegisterReconfigurationCallback(displayReconfigurationCallBack, NULL);
    
    [FrtcCallInterface singletonFrtcCall];
    self.window.delegate = self;
    NSApp.appearance = [NSAppearance appearanceNamed:@"NSAppearanceNameAqua"];
    
    // 检查版本更新
    [[FrtcVersionManager sharedManager] setVersionCheckURL:@"https://shenqi-dl.internetware.cn/client/update.json"];
    [[FrtcVersionManager sharedManager] checkForUpdates];
    
    NSString *server = [[FrtcUserDefault defaultSingleton] objectForKey:STORAGE_SERVER_ADDRESS];
    server = [server isEqualToString:@""] ? @"" :server;
}

@end 