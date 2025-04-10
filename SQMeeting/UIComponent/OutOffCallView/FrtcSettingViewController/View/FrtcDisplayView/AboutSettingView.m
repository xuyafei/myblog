#pragma mark -- Button Sender --
- (void)onUpateBtnPressed {
    // 获取当前窗口
    NSWindow *currentWindow = [self window];
    [[FrtcVersionManager sharedManager] checkForUpdatesAndShowInWindow:currentWindow];
} 