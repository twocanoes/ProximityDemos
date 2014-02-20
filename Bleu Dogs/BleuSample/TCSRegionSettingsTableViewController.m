//
//  TCSRegionSettingsTableViewController.m
//  Bleu Dogs
//
//  Created by Tim Perfitt on 2/7/14.
//  Copyright (c) 2014 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSRegionSettingsTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TCSBleuBeaconManager.h"
NSString * const TCSBleuStationProximityUUID;
NSString * const TCSBleuStationMajor;
NSString * const TCSBleuStationMinor;

@interface TCSRegionSettingsTableViewController ()
- (IBAction)doneButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *region1UUID;
@property (weak, nonatomic) IBOutlet UITextField *region1Major;
@property (weak, nonatomic) IBOutlet UITextField *region1Minor;
@property (weak, nonatomic) IBOutlet UITextField *region2UUID;
@property (weak, nonatomic) IBOutlet UITextField *region2Major;
@property (weak, nonatomic) IBOutlet UITextField *region2Minor;
@property (weak, nonatomic) IBOutlet UITextField *region3UUID;
@property (weak, nonatomic) IBOutlet UITextField *region3Major;
@property (weak, nonatomic) IBOutlet UITextField *region3Minor;
@property (strong, nonatomic) id myNot;

@end

@implementation TCSRegionSettingsTableViewController


-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.region1UUID.text=[ud objectForKey:@"region1uuid"];
    self.region1Major.text=[[ud objectForKey:@"region1major"] stringValue];
    self.region1Minor.text=[[ud objectForKey:@"region1minor"] stringValue];
    
    self.region2UUID.text=[ud objectForKey:@"region2uuid"];
    self.region2Major.text=[[ud objectForKey:@"region2major"] stringValue];
    self.region2Minor.text=[[ud objectForKey:@"region2minor"] stringValue];
    
    self.region3UUID.text=[ud objectForKey:@"region3uuid"];
    self.region3Major.text=[[ud objectForKey:@"region3major"] stringValue];
    self.region3Minor.text=[[ud objectForKey:@"region3minor"] stringValue];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}




- (IBAction)changeRegion:(id)sender {
    
    if (_myNot) [[NSNotificationCenter defaultCenter] removeObserver:_myNot];
    
    switch ([sender tag]) {
        case 0:{
            NSLog(@"Registering 0");
            
            _myNot=[[NSNotificationCenter defaultCenter] addObserverForName:@"TCSBeaconInfoFound" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                
                [[NSUserDefaults standardUserDefaults] setObject:[[note userInfo] objectForKey:TCSBleuStationProximityUUID]  forKey:@"region1uuid"];
                [[NSUserDefaults standardUserDefaults] setObject:@([[[note userInfo] objectForKey:TCSBleuStationMajor] intValue])  forKey:@"region1major"];
                [[NSUserDefaults standardUserDefaults] setObject:@([[[note userInfo] objectForKey:TCSBleuStationMinor] intValue])  forKey:@"region1minor"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] removeObserver:_myNot];
                NSLog(@"remove 0");
                
                
            }];
            
            
        }
            break;
            
        case 1:{
            NSLog(@"Registering 1");
            _myNot=[[NSNotificationCenter defaultCenter] addObserverForName:@"TCSBeaconInfoFound" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [[NSUserDefaults standardUserDefaults] setObject:[[note userInfo] objectForKey:TCSBleuStationProximityUUID]  forKey:@"region2uuid"];
                [[NSUserDefaults standardUserDefaults] setObject:@([[[note userInfo] objectForKey:TCSBleuStationMajor]  intValue]) forKey:@"region2major"];
                [[NSUserDefaults standardUserDefaults] setObject:@([[[note userInfo] objectForKey:TCSBleuStationMinor] intValue]) forKey:@"region2minor"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] removeObserver:_myNot];
                NSLog(@"remove 1");
            }];
            
            
        }
            break;
            
        case 2:{
            NSLog(@"Registering 2");
            _myNot=[[NSNotificationCenter defaultCenter] addObserverForName:@"TCSBeaconInfoFound" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [[NSUserDefaults standardUserDefaults] setObject:[[note userInfo] objectForKey:TCSBleuStationProximityUUID]  forKey:@"region3uuid"];
                [[NSUserDefaults standardUserDefaults] setObject:@([[[note userInfo] objectForKey:TCSBleuStationMajor] intValue])  forKey:@"region3major"];
                [[NSUserDefaults standardUserDefaults] setObject:@([[[note userInfo] objectForKey:TCSBleuStationMinor] intValue]) forKey:@"region3minor"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] removeObserver:_myNot];
                NSLog(@"remove 2");
            }];
            
            
        }
            break;
        default:
            break;
    }
    
}
- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
        
        [[NSUserDefaults standardUserDefaults] setObject:self.region1UUID.text  forKey:@"region1uuid"];
        [[NSUserDefaults standardUserDefaults] setObject:@([self.region1Major.text intValue])  forKey:@"region1major"];
        [[NSUserDefaults standardUserDefaults] setObject:@([self.region1Minor.text intValue])  forKey:@"region1minor"];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.region2UUID.text  forKey:@"region2uuid"];
        [[NSUserDefaults standardUserDefaults] setObject:@([self.region2Major.text  intValue]) forKey:@"region2major"];
        [[NSUserDefaults standardUserDefaults] setObject:@([self.region2Minor.text intValue]) forKey:@"region2minor"];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.region3UUID.text  forKey:@"region3uuid"];
        [[NSUserDefaults standardUserDefaults] setObject:@([self.region3Major.text intValue])  forKey:@"region3major"];
        [[NSUserDefaults standardUserDefaults] setObject:@([self.region3Minor.text intValue]) forKey:@"region3minor"];
        [[NSUserDefaults standardUserDefaults]  synchronize];
        
        
        [[TCSBleuBeaconManager sharedManager] beginRegionMonitoring];
    }];
    
}

@end
