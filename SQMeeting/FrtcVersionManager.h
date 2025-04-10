#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcVersionManager : NSObject

+ (instancetype)sharedManager;

// 检查版本更新
- (void)checkForUpdates;

// 设置版本检查的URL
- (void)setVersionCheckURL:(NSString *)url;

// 手动检查更新并在指定窗口显示结果
- (void)checkForUpdatesAndShowInWindow:(NSWindow *)window;

// 获取当前版本号
- (NSString *)currentVersion;

@end

NS_ASSUME_NONNULL_END 