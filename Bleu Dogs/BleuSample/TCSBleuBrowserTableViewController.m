//
//  TCSBleuBrowserTableViewController.m
//  Bleu Dogs
//
//  Created by Tim Perfitt on 2/7/14.
//  Copyright (c) 2014 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSBleuBrowserTableViewController.h"
@interface TCSBleuBrowserTableViewController ()
- (IBAction)cancelSelectBleuStation:(id)sender;

@property (strong,nonatomic) TCSBleuStationManager *bsManager;
@property (strong,nonatomic) NSMutableArray *beaconArray;
@property (strong,nonatomic) NSMutableDictionary *beaconDetails;

@end

@implementation TCSBleuBrowserTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    _beaconArray=[NSMutableArray array];
    _bsManager=[[TCSBleuStationManager alloc] initWithDelegate:self queue:nil];
    [_bsManager scanForStations];
    _beaconDetails=[NSMutableDictionary dictionary];


}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [_bsManager stopScan];
    self.bsManager=nil;
}
- (void)stationManager:(TCSBleuStationManager *)manager didDiscoverStation:(TCSBleuStation *)station{
    [_beaconArray addObject:station];
    [self.tableView reloadData];
    
}
- (void)station:(TCSBleuStation *)station didReadProperty:(NSString *)attribute value:(id)value error:(NSError *)error{
    
    [_beaconDetails setObject:value forKey:attribute];
    
    if ([_beaconDetails count]==3) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TCSBeaconInfoFound" object:self userInfo:self.beaconDetails];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}
- (void)stationManager:(TCSBleuStationManager *)manager didDisconnectStationWithIdentifier:(NSString *)hardwareName{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)stationManager:(TCSBleuStationManager *)manager didFailWithError:(NSError *)error{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_beaconArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"com.bleu.station.id";
    


        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        
    }
    cell.textLabel.text=[[_beaconArray objectAtIndex:indexPath.row] hardwareName];
    
    cell.backgroundColor=[UIColor blueColor];
    // Configure the cell...
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[_beaconArray objectAtIndex:indexPath.row] setDelegate:self];
    [[_beaconArray objectAtIndex:indexPath.row] readValues:@[TCSBleuStationProximityUUID,TCSBleuStationMajor,TCSBleuStationMinor]];

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation
 
 */
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)cancelSelectBleuStation:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
