/*
 *    Helpshift.h
 *    SDK version 2.5.0
 *
 *    Get the documentation at http://www.helpshift.com/docs
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
This document describes the API exposed by the Helpshift SDK (2.x) which the developers can use to integrate Helpshift support into their iOS applications. If you want documentation regarding how to use the various features provided by the Helpshift SDK, please visit [helpshift how-to page](http://www.helpshift.com/docs/howto/ios/v2.x/) 
*/

typedef NSDictionary* (^metadataBlock)(void);

@protocol HelpshiftDelegate;
@interface Helpshift : NSObject <UIAlertViewDelegate>
{
    id <HelpshiftDelegate> delegate;
}

@property (nonatomic,retain) id<HelpshiftDelegate> delegate;

/** Initialize helpshift support
    
When initializing Helpshift you must pass these three tokens. You initialize Helpshift by adding the following lines in the implementation file for your app delegate, ideally at the top of application:didFinishLaunchingWithOptions. If you use this api to initialize helpshift support, in-app notifications will be enabled by default.
In-app notifications are banner like notifications shown by the Helpshift SDK to alert the user of any updates to the reported issues. 
If you want to disable the in-app notifications please refer to the installForAppID:domainName:apiKey:withOptions: api
     
    @param appID This is the unique ID assigned to your app
    @param domainName This is your domain name without any http:// or forward slashes
    @param apiKey This is your developer API Key
 
    @available Available in SDK version 1.0.0 or later
*/
+ (void) installForAppID:(NSString *)appID domainName:(NSString *)domainName apiKey:(NSString *)apiKey;

/** Initialize helpshift support
 
 When initializing Helpshift you must pass these three tokens. You initialize Helpshift by adding the following lines in the implementation file for your app delegate, ideally at the top of application:didFinishLaunchingWithOptions
 
 @param appID This is the unique ID assigned to your app
 @param domainName This is your domain name without any http:// or forward slashes
 @param apiKey This is your developer API Key
 @param withOptions This is the dictionary which contains additional configuration options for the HelpshiftSDK. Currently we support the "disableInAppNotif" as the only available option. Possible values are <"YES"/"NO">. If you set the flag to "YES", the helpshift SDK will show notifications similar to the banner notifications supported by Apple Push notifications. These notifications will alert the user of any updates to reported issues. If you set the flag to "NO", the in-app notifications will be disabled.
 
 @available Available in SDK version 2.4.0-rc.1 or later
 */

+ (void) installForAppID:(NSString *)appID domainName:(NSString *)domainName apiKey:(NSString *)apiKey withOptions : (NSDictionary *) optionsDictionary;

/** Returns an instance of Helpshift
 
 When calling any Helpshift instance method you must use sharedInstance. For example to call showSupport: you must call it like [[Helpshift sharedInstance] showSupport:self];
 
 @available Available in SDK version 1.0.0 or later
 */
+ (Helpshift *) sharedInstance;

/** Show the helpshift support screen

To show the Helpshift support screen you need to pass the name of the viewcontroller on which the support screen will show up. For example from inside a viewcontroller you can call Helpshift support by passsing the argument “self”.

    @param viewController viewController on which the helpshift support screen will show up.

    @available Available in SDK version 1.0.0 or later
*/
- (void) showSupport:(UIViewController *)viewController;

/** Show the helpshift support screen (with Optional Arguments)

 To show the Helpshift support screen with optional arguments you will need to pass the name of the viewcontroller on which the support screen will show up and an options dictionary. If you do not want to pass any options then just call showSupport: instead of showSupport:withOptions:

 @param viewController viewController on which the helpshift support screen will show up.
 @param optionsDictionary the dictionary which will contain the arguments passed to the Helpshift support session (that will start with this method call).

 Please check the docs for available options.

 @available Available in SDK version 2.0.0 or later
 */
- (void) showSupport:(UIViewController *)viewController withOptions:(NSDictionary *)optionsDictionary;

/** Show the helpshift screen to report an issue

 To show the Helpshift screen for reporting an issue you need to pass the name of the viewcontroller on which the report issue screen will show up. For example from inside a viewcontroller you can call the Helpshift report issue screen by passing the argument “self”.

 @param viewController viewController on which the helpshift report issue screen will show up.

 @available Available in SDK version 1.4.2 or later
 */
- (void) reportIssue:(UIViewController *)viewController;

/** Show the helpshift screen to report an issue (with Optional Arguments)

 To show the Helpshift screen for reporting an issue with optional arguments you will need to pass the name of the viewcontroller on which the report issue screen will show up and an options dictionary. If you do not want to pass any options then just call reportIssue: instead of reportIssue:withOptions:

 @param viewController viewController on which the helpshift report issue screen will show up.
 @param optionsDictionary the dictionary which will contain the arguments passed to the Helpshift report issue session (that will start with this method call).

 Please check the docs for available options.

 @available Available in SDK version 2.0.0 or later
 */
- (void) reportIssue:(UIViewController *)viewController withOptions:(NSDictionary *)optionsDictionary;

/** Show the helpshift issues inbox screen

 To show the Helpshift screen that contains the list of issues posted by an user you need to pass the name of the viewcontroller on which the screen will show up. For example from inside a viewcontroller you can call the Helpshift issues inbox screen by passsing the argument “self”.

 @param viewController viewController on which the helpshift issues inbox screen will show up.

 @available Available in SDK version 2.0.0 or later
 */
- (void) showInbox:(UIViewController *)viewController;

/** Show the helpshift screen with faqs from a particular section

 To show the Helpshift screen for showing a particular faq section you need to pass the publish-id of the faq section and the name of the viewcontroller on which the faq section screen will show up. For example from inside a viewcontroller you can call the Helpshift faq section screen by passing the argument “self” for the viewController parameter.

 @param faqSectionPublishID the publish id associated with the faq section which is shown in the FAQ page on the admin side (__yourcompanyname__.helpshift.com/admin/faq/).
 @param viewController viewController on which the helpshift faq section screen will show up.

 @available Available in SDK version 2.0.0 or later
*/

- (void) showFAQSection : (NSString *) faqSectionPublishID withController : (UIViewController *)viewController;

/** Show the helpshift screen with a particular faq

 To show the Helpshift screen for showing a particular faq you need to pass the publish-id of the faq and the name of the viewcontroller on which the faq screen will show up. For example from inside a viewcontroller you can call the Helpshift faq section screen by passing the argument “self” for the viewController parameter.

 @param faqPublishID the publish id associated with the faq which is shown when you expand a single FAQ (__yourcompanyname__.helpshift.com/admin/faq/)
 @param viewController viewController on which the helpshift faq section screen will show up.

 @available Available in SDK version 2.0.0 or later
*/

- (void) showFAQ : (NSString *) faqPublishID withController : (UIViewController *)viewController;

/** Show the support screen with only the faqs

 To show the Helpshift screen with only the faq sections with search, you can use this api. This screen will not show the issues reported by the user. The search results screen will not have a way to report an issue.

 @param viewController viewController on which the helpshift faqs screen will show up.

*/
- (void) showFAQs : (UIViewController *)viewController;

/** Show the support screen with only the faqs (with Optional Arguments)

 To show the Helpshift screen with only the faq sections with search with optional arguments, you can use this api. This screen will not show the issues reported by the user.

 @param viewController viewController on which the helpshift faqs screen will show up.
 @param optionsDictionary the dictionary which will contain the arguments passed to the Helpshift faqs screen session (that will start with this method call).

 Please check the docs for available options.

 @available Available in SDK version 2.0.0 or later
 */

- (void) showFAQs:(UIViewController *)viewController withOptions:(NSDictionary *)optionsDictionary;

/** Set the unique identifier for your users.

This is part of additional user configuration. You can setup the unique identifier that this user will have with this api.
    @param userIdentifier A unique string to identify your users. For example "user-id-100"

    @available Available in SDK version 1.0.0 or later
*/

+ (void) setUserIdentifier:(NSString *)userIdentifier;

/** Set the name of the application user.

This is part of additional user configuration. If this is provided through the api, user will not be prompted to re-enter this information again.

     @param username The name of the user.

     @available Available in SDK version 1.0.0 or later
*/

+ (void) setUsername:(NSString *)username;

/** Set the email-id of the application user.

This is part of additional user configuration. If this is provided through the api, user will not be prompted to re-enter this information again.

    @param email The email address of the user.

    @available Available in SDK version 1.0.0 or later
*/

+ (void) setUseremail:(NSString *)email;

/** Add extra debug information regarding user-actions.

You can add additional debugging statements to your code, and see exactly what the user was doing right before they reported the issue.

    @param breadCrumbString The string containing any relevant debugging information.

    @available Available in SDK version 1.0.0 or later
*/

+ (void) leaveBreadCrumb:(NSString *)breadCrumbString;

/** Provide a block which returns a dictionary for custom meta data to be attached along with reported issues

If you want to attach custom data along with any reported issues, use this api to provide a block which accepts zero arguments and returns an NSDictionary containing the meta data key-value pairs. Everytime an issue is reported, the SDK will call this block and attach the returned meta data dictionary along with the reported issue. Ideally this metaDataBlock should be provided before the user can file an issue.

    @param metadataBlock a block variable which accepts zero arguments and returns an NSDictionary.

    @available Available in SDK version 2.0.0-beta.3 or later
*/

+ (void) metadataWithBlock : (metadataBlock) metadataBlock;

/** Get the notification count for replies to reported issues.
 
 
 If you want to show your user notifications for replies on the issues posted, you can get the notification count asynchronously by implementing the HelpshiftDelegate in your respective .h and .m files.
 Use the following method to set the delegate, where self is the object implementing the delegate.
 [[Helpshift sharedInstance] setDelegate:self];
 Now you can call the method
 [[Helpshift sharedInstance] notificationCountAsync:true];
 This will return a notification count in the
 - (void) notificationCountAsyncReceived:(NSInteger) count
 count delegate method.
 If you want to retrieve the current notification count synchronously, you can call the same method with the parameter set to false, i.e
 NSInteger count = [[Helpshift sharedInstance] notificationCountAsync:false]
 
 @param isAsync Whether the notification count is to be returned asynchronously via delegate mechanism or synchronously as a return val for this api
 
 @available Available in SDK version 1.4.4 or later
 */

- (NSInteger) notificationCountAsync : (BOOL) isAsync;

/** Register the deviceToken to enable push notifications


To enable push notifications in the Helpshift iOS SDK, set the Push Notifications’ deviceToken using this method inside your application:didRegisterForRemoteNotificationsWithDeviceToken application delegate.
    
    @param deviceToken The deviceToken received from the push notification servers.

Example usage
    - (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:
                (NSData *)deviceToken
    {
        [[Helpshift sharedInstance] registerDeviceToken:deviceToken];
    }
 
    @available Available in SDK version 1.4.0 or later
 
*/
- (void) registerDeviceToken:(NSData *) deviceToken;

/** Forward the push notification for the Helpshift lib to handle


To show support on Notification opened, call handleNotification in your application:didReceiveRemoteNotification application delegate. 
If the value of the “origin” field is “helpshift” call the handleNotification api

    @param notification The dictionary containing the notification information
    @param viewController ViewController on which the helpshift support screen will show up.
    
Example usage
    - (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    {
        if ([[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
            [[Helpshift sharedInstance] handleNotification:userInfo withController:self.viewController];
        }
    }

    @available Available in SDK version 1.4.0 or later
 
*/
- (void) handleNotification: (NSDictionary *)notification withController : (UIViewController *) viewController;

/** Clears all local Helpshift user data
 
 Clears all local data which is user related (includes issues, user info, faq likes, etc).
 
 @available Available in SDK version 2.3.0-rc.1 or later
 
 */
- (void) clearUserData;

/** Clears Breadcrumbs list.
 
 Breadcrumbs list stores upto 100 latest actions. You'll receive those in every Issue. 
 If for some reason you want to clear previous messages, you can use this method.
 
 @available Available in SDK version 2.3.0-rc.1 or later
 
 */
- (void) clearBreadCrumbs;

/** Forward the local notification for the Helpshift lib to handle
 
 
 To show support on Notification opened, call handleLocalNotification in your application:didReceiveLocalNotification application delegate.
 If the value of the “origin” field is “helpshift” call the handleLocalNotification api
 
 @param notification The UILocalNotification object containing the notification information
 @param viewController ViewController on which the helpshift support screen will show up.
 
 Example usage
    - (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
    {
        if ([[notification.userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"])
        [[Helpshift sharedInstance] handleLocalNotification:notification withController:self.viewController];
    }

 @available Available in SDK version 2.4.0-rc.1 or later
 
 */

- (void) handleLocalNotification: (UILocalNotification *)notification withController : (UIViewController *) viewController;

@end

@protocol HelpshiftDelegate <NSObject>

/** Delegate method call that should be implemented if you are calling notificationCountAsync.
 @param count Returns the number of issues with unread messages.
 
 @available Available in SDK version 1.4.4 or later
 */

- (void) notificationCountAsyncReceived:(NSInteger)count;

/** Optional delegate method that is called when the Helpshift session ends.
 
    @available Available in SDK version 1.4.3 or later
*/
@optional
- (void) helpshiftSessionHasEnded;

@end
