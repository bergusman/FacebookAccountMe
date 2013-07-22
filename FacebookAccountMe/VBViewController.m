//
//  VBViewController.m
//  FacebookAccountMe
//
//  Created by Vitaly Berg on 22.07.13.
//  Copyright (c) 2013 Vitaly Berg. All rights reserved.
//

#import "VBViewController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define APP_ID @"141594139372172"

@interface VBViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;

@property (strong, nonatomic) ACAccountStore *accountStore;

@end

@implementation VBViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItem];
    
    self.accountStore = [[ACAccountStore alloc] init];
    NSLog(@"%@", self.accountStore.accounts);
}

#pragma mark - Setups

- (void)setupNavigationItem {
    self.navigationItem.title = @"Facebook Me";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Get" style:UIBarButtonItemStyleBordered target:self action:@selector(getAction:)];
}

#pragma mark - Content

- (void)grabFacebookMe {
    ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *accessOptions = @{
        ACFacebookAppIdKey: APP_ID,
        ACFacebookPermissionsKey: @[@"email"],
        ACFacebookAudienceKey: ACFacebookAudienceOnlyMe
    };
    
    [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:accessOptions completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showGrantErrorWithError:error];
                return;
            }
            
            NSArray *facebookAccounts = [self.accountStore accountsWithAccountType:facebookAccountType];
            
            if ([facebookAccounts count] == 0) {
                [self showNoFacebookAccount];
                return;
            }
            
            ACAccount *facebookAccount = facebookAccounts[0];
            
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
            NSDictionary *params = @{
                @"fields": @"picture"
            };
            
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
            request.account = facebookAccount;
            
            [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [self showMeRequestErrorWithError:error];
                    } else {
                        id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        NSLog(@"%@", json);
                    }
                });
            }];
        });
    }];
}

- (void)showMeRequestErrorWithError:(NSError *)error {
    [self showAlertWithTitle:@"Request Error" message:error.localizedDescription];
}

- (void)showNoFacebookAccount {
    [self showAlertWithTitle:@"No Facebook" message:@"Setup facebook account in the system settins"];
}

- (void)showGrantErrorWithError:(NSError *)error {
    [self showAlertWithTitle:@"Access Error" message:error.localizedDescription];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

#pragma mark - Actions

- (void)getAction:(id)sender {
    [self grabFacebookMe];
}

@end
