//
//  TCSBleuContentViewController.m
//  BleuUser
//
//  Created by Steve Brokaw on 10/18/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TCSBleuContentViewController.h"
#import "TCSBleuBeaconManager.h"

@interface TCSBleuContentViewController ()
@property (strong, nonatomic) NSOperationQueue *opQueue;
@property (weak, nonatomic) UILabel *accuracyLabel;
- (void)loadURLs:(NSArray *)URLs;

@end

@implementation TCSBleuContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.opQueue = [[NSOperationQueue alloc] init];
	self.opQueue.name = @"com.twocanoes.bleu.contentviewcontroller";


    
    TCSBleuBeaconManager *manager = [TCSBleuBeaconManager sharedManager];
    [manager beginRegionMonitoring];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"TCSBeaconFound" object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        NSLog(@"not info is %@",note.userInfo[@"identifier"]);
        NSString *identifier=note.userInfo[@"identifier"];
        
        if ([identifier isEqualToString:@"com.twocanoes.one"]) {
            self.selectedIndex = 1;
        }
        else if ([identifier isEqualToString:@"com.twocanoes.two"]) {
            self.selectedIndex = 2;
        }
        else if ([identifier isEqualToString:@"com.twocanoes.three"]) {
            self.selectedIndex = 3;
        }
        
    }];
}

- (void)loadURLs:(NSArray *)URLs
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		
		NSURL *defaultURL = [NSURL URLWithString:[[TCSBleuBeaconManager sharedManager] defaultURL]];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:defaultURL];
		UIWebView *webView = (UIWebView *)((UIViewController *)self.viewControllers[0]).view;
		[webView loadRequest:request];
		
		for (int i = 0; i < 3; i++) {
			NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URLs[i]]];
			UIWebView *webView = (UIWebView *)((UIViewController *)self.viewControllers[i + 1]).view;
			[webView loadRequest:request];
		}
	}];
}

- (void)registerNotifications
{
	[[NSNotificationCenter defaultCenter] addObserverForName:TCSDidEnterBleuRegionNotification object:nil queue:self.opQueue usingBlock:^(NSNotification *note) {
		NSDictionary *info = [note userInfo];
		CLBeaconRegion *beaconRegion = info[@"region"];
		DLog(@"Received Enter Notification for beacon %@", beaconRegion.identifier);
		TCSBleuBeaconManager *manager = [TCSBleuBeaconManager sharedManager];
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered Region" message:manager.entryText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}];
	}];
	[[NSNotificationCenter defaultCenter] addObserverForName:TCSDidExitBleuRegionNotification object:nil queue:self.opQueue usingBlock:^(NSNotification *note) {
		NSDictionary *info = [note userInfo];
		CLBeaconRegion *beaconRegion = info[@"region"];
		DLog(@"Received Exit Notificationf for beacon %@", beaconRegion.identifier);
		TCSBleuBeaconManager *manager = [TCSBleuBeaconManager sharedManager];
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exited Region" message:manager.exitText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			self.selectedIndex = 0;
		}];
	}];
	[[NSNotificationCenter defaultCenter] addObserverForName:TCSBleuRangingNotification object:nil queue:self.opQueue usingBlock:^(NSNotification *note) {
		CLBeacon *beacon = note.userInfo[@"beacon"];
		DLog(@"%f", beacon.accuracy);
		NSUInteger index = [note.userInfo[@"index"] unsignedIntegerValue] + 1;
		if (index == 4) return; //ignore "unknown" proximity
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			self.selectedIndex = index;
			//self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
			CGFloat progress = pow(10.0, beacon.accuracy);
			DLog(@"Accuracy progress: %f", progress);
			if (progress > 1.0) progress = 1.0;
			//[self.progressView setProgress:(1.0 - progress) animated:YES];
		}];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
