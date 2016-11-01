@interface NSNotificationCenter (Utils_Impl) {
}

-(void)postNotificationOnMainThreadImpl:(NSNotification*)notification;
-(void)postNotificationNameOnMainThreadImpl:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end

@implementation NSNotificationCenter (Utils)

-(void)postNotificationOnMainThread:(NSNotification *)notification {
    [notification retain];
    [notification.object retain];
    [self performSelectorOnMainThread:@selector(postNotificationOnMainThreadImpl:) 
                           withObject:notification
                        waitUntilDone:NO];
}

-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject {
    [self postNotificationNameOnMainThread:aName object:anObject userInfo:nil];
}

-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    [aName retain];
    [anObject retain];
    [aUserInfo retain];

    SEL sel = @selector(postNotificationNameOnMainThreadImpl:object:userInfo:);
    NSMethodSignature* sig = [self methodSignatureForSelector:sel];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:sel];
    [invocation setArgument:&aName atIndex:2];
    [invocation setArgument:&anObject atIndex:3];
    [invocation setArgument:&aUserInfo atIndex:4];
    [invocation invokeOnMainThreadWaitUntilDone:NO];
}

@end

@implementation NSNotificationCenter (Utils_Impl)

-(void)postNotificationOnMainThreadImpl:(NSNotification*)notification {
    [self postNotification:notification];
    [notification.object release];
    [notification release];
}

-(void)postNotificationNameOnMainThreadImpl:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    [self postNotificationName:aName object:anObject userInfo:aUserInfo];
    [aName release];
    [anObject release];
    [aUserInfo release];
}

@end
