//
//  ViewController.m
//  GDataWithGTMOauth2Example
//
//  Created by Kobe Dai on 11/6/12.
//  Copyright (c) 2012 Kobe Dai. All rights reserved.
//

#import "ViewController.h"
#import "GData.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <Security/Security.h>

@interface ViewController ()
{
    GTMOAuth2ViewControllerTouch *touchViewController;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    static NSString *const kKeychainItemName = @"Oauth2 Sample: Calendar";
    
    NSString *kMyClientId = @"YOUR_CLIENT_ID";
    NSString *kMyClientSecret = @"YOUR_CLIENT_SECRET";
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName: kKeychainItemName clientID: kMyClientId clientSecret: kMyClientSecret];
    
    [[self calendarService] setAuthorizer: auth];
}

- (NSString *)signedInUserName
{
    // Get the email address of the signed-in user
    GTMOAuth2Authentication *auth = [[self calendarService] authorizer];
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn)
    {
        return auth.userEmail;
    }
    else
    {
        return nil;
    }
}

- (BOOL)isSignIn
{
    NSString *name = [self signedInUserName];
    return (name != nil);
}

- (void)runSignInThenInvokeSelector: (SEL)signInDoneSel
{
    static NSString *const kKeychainItemName = @"Oauth2 Sample: Calendar";
    
    NSString *kMyClientId = @"YOUR_CLIENT_ID";
    NSString *kMyClientSecret = @"YOUR_CLIENT_SECRET";
    
    NSString *scope = [GDataServiceGoogleCalendar authorizationScope];
    
    // Login viewController with a UIWebView.
    touchViewController = [[GTMOAuth2ViewControllerTouch alloc]
                           initWithScope: scope
                           clientID: kMyClientId
                           clientSecret: kMyClientSecret
                           keychainItemName: kKeychainItemName
                           delegate: self finishedSelector: @selector(viewController:finishedWithAuth:error:)];
    [self.navigationController pushViewController: touchViewController animated: YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        NSLog(@"uthentication failed");
    } else {
        // Authentication succeeded
        NSLog(@"Authentication succeeded");
        [[self calendarService] setAuthorizer: auth];
    }
    
    NSURL *feedURL = [GDataServiceGoogleCalendar calendarFeedURLForUsername: [auth userEmail]];
    NSLog(@"%@", feedURL);
    GDataServiceTicket *ticket;
    ticket = [[self calendarService] fetchFeedWithURL: feedURL delegate: self didFinishSelector: @selector(ticket:finishedWithFeed:error:)];
    
}

- (GDataServiceGoogleCalendar *)calendarService
{
    static GDataServiceGoogleCalendar *service = nil;
    
    if (!service)
    {
        service = [[GDataServiceGoogleCalendar alloc] init];
        [service setServiceShouldFollowNextLinks: YES];
        [service setIsServiceRetryEnabled: YES];
    }
    
    return service;
}

- (IBAction)login:(id)sender
{
    [self runSignInThenInvokeSelector: nil];
}

- (void)ticket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendar *)feed error:(NSError *)error {
    
    if (error == nil) {
        NSArray *entries = [feed entries];
        if ([entries count] > 0) {
            
            GDataEntryCalendar *firstCalendar = [entries objectAtIndex: 0];
            GDataTextConstruct *titleTextConstruct = [firstCalendar title];
            NSString *title = [titleTextConstruct stringValue];
            
            NSLog(@"first calendar's title: %@", title);
        } else {
            NSLog(@"the user has no calendars");
        }
    } else {
        NSLog(@"fetch error: %@", error);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
