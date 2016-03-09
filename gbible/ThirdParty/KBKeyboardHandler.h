//http://stackoverflow.com/a/12402817

@protocol KBKeyboardHandlerDelegate;

@interface KBKeyboardHandler : NSObject

- (id)init;

@property(nonatomic, weak) id<KBKeyboardHandlerDelegate> delegate;
@property(nonatomic) CGRect frame;

@end