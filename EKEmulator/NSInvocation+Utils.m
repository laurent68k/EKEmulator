@implementation NSInvocation (Utils)

-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait
{
    [self performSelectorOnMainThread:@selector(invoke)
                           withObject:nil
                        waitUntilDone:wait];
}

@end
