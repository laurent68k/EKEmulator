@interface NSNotificationCenter (Utils)

-(void)postNotificationOnMainThread:(NSNotification *)notification;
-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject;
-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end