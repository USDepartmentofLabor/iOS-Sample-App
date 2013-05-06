//
//  MasterViewController.m
//  SDKSample2
//
//  Created by the U.S. Deparment of Labor
//  Code available in the public domain
//

#import "MasterViewController.h"

#import "DetailViewController.h"

//Set API key information
#define API_KEY @""
#define API_SECRET @""
#define API_HOST @"http://api.dol.gov"
#define API_URL @"/V1"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize dataRequest, arrayOfResults, dictionaryOfResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}
							
- (void)dealloc
{
    [arrayOfResults release];
    [dictionaryOfResults release];
    [dataRequest release];
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.title = @"SDK Sample";
    //Create Context Object
    //This object will store the URL and authorization information
    GOVDataContext *context = [[GOVDataContext alloc] initWithAPIKey:API_KEY Host:API_HOST SharedSecret:API_SECRET APIURL:API_URL];
    
	//Instantiate a new request
	dataRequest = [[GOVDataRequest alloc] initWithContext:context];
	//Set self as a delegate
	dataRequest.delegate = self;
	
	//Define the method that will be called
	NSString *method = @"Compliance/WHD/full";
    
	//Create a dictionary of arguments
	//Top 20 records; Selected 3 columns.
	NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:@"20", @"top", @"trade_nm,city_nm,st_cd", @"select", nil];
    
	//Set the timeout.  Set this higher for long-loading APIs
	int timeOut = 20;
    
	//Call API method with the arguments
	//didCompleteWithResults or didCompleteWithError delegate method will be called
	//when results or errors are returned
	[dataRequest callAPIMethod:method withArguments:arguments andTimeOut:timeOut];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // return _objects.count;
    return [self.arrayOfResults count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    //Get the record
    NSDictionary *result = (NSDictionary *)[arrayOfResults objectAtIndex:indexPath.row];
    
    //Configure the cell
    
    //Set the cell text to trade_nm
    cell.textLabel.text = (NSString *)[result objectForKey:@"trade_nm"];
    
    //Set the cell small text to "city, state"
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", (NSString *)[result objectForKey:@"city_nm"], (NSString *)[result objectForKey:@"st_cd"]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    }
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

#pragma mark GOVDataRequest delegate methods
-(void)govDataRequest:(GOVDataRequest *)request didCompleteWithResults:(NSArray *)resultsArray {
	NSLog(@"Got results");
    
	//Save results in our local array instance
	self.arrayOfResults = [resultsArray retain];
    
	//Refresh the tableView
	[self.tableView reloadData];
}

-(void)govDataRequest:(GOVDataRequest *)request didCompleteWithError:(NSString *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
	[alert show];
	[alert release];
}

-(void)govDataRequest:(GOVDataRequest *)request didCompleteWithDictionaryResults:(NSDictionary *)resultsDictionary {
    
    
    NSLog(@"Got a Dictionary");
	//Save results in our local dictionary instance
	self.dictionaryOfResults = [resultsDictionary retain];
    //    NSLog(@"%@", self.dictionaryOfResults);
	//Refresh the tableView
	//[self.tableView reloadData];
}


@end
