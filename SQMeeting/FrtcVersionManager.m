#import "FrtcVersionManager.h"

@interface FrtcVersionManager ()

@property (nonatomic, copy) NSString *versionCheckURL;
@property (nonatomic, weak) NSWindow *targetWindow;

@end

@implementation FrtcVersionManager

+ (instancetype)sharedManager {
    static FrtcVersionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FrtcVersionManager alloc] init];
    });
    return instance;
}

- (void)setVersionCheckURL:(NSString *)url {
    _versionCheckURL = [url copy];
}

- (NSString *)currentVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (void)checkForUpdatesAndShowInWindow:(NSWindow *)window {
    self.targetWindow = window;
    [self checkForUpdates];
}

- (void)checkForUpdates {
    if (!self.versionCheckURL) {
        NSLog(@"Version check URL not set");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:self.versionCheckURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Version check failed: %@", error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON parsing failed: %@", jsonError);
            return;
        }
        
        // 获取 macOS 版本信息
        NSDictionary *macInfo = json[@"sdk_mac"];
        if (!macInfo) {
            NSLog(@"No Mac version info in response");
            return;
        }
        
        // 获取服务器版本号
        NSString *serverVersion = macInfo[@"latest_version"];
        if (!serverVersion) {
            NSLog(@"No version info in response");
            return;
        }
        
        // 获取当前应用版本号
        NSString *currentVersion = [self currentVersion];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self isVersion:serverVersion greaterThan:currentVersion]) {
                [self showUpdateAlert:macInfo];
            } else if (self.targetWindow) {
                // 如果是手动检查且没有更新，显示提示
                [self showNoUpdateAlert];
            }
        });
    }] resume];
}

- (BOOL)isVersion:(NSString *)version1 greaterThan:(NSString *)version2 {
    NSArray *v1Components = [version1 componentsSeparatedByString:@"."];
    NSArray *v2Components = [version2 componentsSeparatedByString:@"."];
    
    NSInteger length = MIN(v1Components.count, v2Components.count);
    
    for (int i = 0; i < length; i++) {
        NSInteger v1 = [v1Components[i] integerValue];
        NSInteger v2 = [v2Components[i] integerValue];
        
        if (v1 > v2) {
            return YES;
        } else if (v1 < v2) {
            return NO;
        }
    }
    
    return v1Components.count > v2Components.count;
}

- (void)showUpdateAlert:(NSDictionary *)versionInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"发现新版本";
        alert.informativeText = [NSString stringWithFormat:@"有新版本 %@ 可用\n\n%@",
                                   versionInfo[@"latest_version"],
                                   versionInfo[@"description"]];
        [alert addButtonWithTitle:@"更新"];
        [alert addButtonWithTitle:@"稍后"];
        
        // 获取正确的窗口
        NSWindow *window = self.targetWindow;
        if (!window) {
            // 获取当前激活的窗口
            window = [NSApp keyWindow];
            if (!window) {
                // 如果没有激活的窗口，获取主窗口
                window = [NSApp mainWindow];
                if (!window) {
                    // 如果还是没有，获取第一个窗口
                    window = [NSApp windows].firstObject;
                }
            }
        }
        
        if (window) {
            // 确保窗口是可见的并且在前面
            [window makeKeyAndOrderFront:nil];
            [NSApp activateIgnoringOtherApps:YES];
            
            // 在窗口上显示模态对话框
            [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertFirstButtonReturn) {
                    // 打开更新链接
                    NSString *downloadURL = versionInfo[@"latest_update_url"];
                    if (downloadURL) {
                        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadURL]];
                    }
                }
                self.targetWindow = nil;
            }];
        } else {
            // 如果没有找到合适的窗口，使用普通的模态对话框
            NSModalResponse response = [alert runModal];
            if (response == NSAlertFirstButtonReturn) {
                NSString *downloadURL = versionInfo[@"latest_update_url"];
                if (downloadURL) {
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadURL]];
                }
            }
            self.targetWindow = nil;
        }
    });
}

- (void)showNoUpdateAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleInformational;
        alert.messageText = @"已是最新版本";
        alert.informativeText = [NSString stringWithFormat:@"当前版本 %@ 已是最新版本", [self currentVersion]];
        
        [alert addButtonWithTitle:@"确定"];
        
        // 获取正确的窗口
        NSWindow *window = self.targetWindow;
        if (!window) {
            // 获取当前激活的窗口
            window = [NSApp keyWindow];
            if (!window) {
                // 如果没有激活的窗口，获取主窗口
                window = [NSApp mainWindow];
                if (!window) {
                    // 如果还是没有，获取第一个窗口
                    window = [NSApp windows].firstObject;
                }
            }
        }
        
        if (window) {
            // 确保窗口是可见的并且在前面
            [window makeKeyAndOrderFront:nil];
            [NSApp activateIgnoringOtherApps:YES];
            
            // 在窗口上显示模态对话框
            [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
                self.targetWindow = nil;
            }];
        } else {
            // 如果没有找到合适的窗口，使用普通的模态对话框
            [alert runModal];
            self.targetWindow = nil;
        }
    });
}

@end 