#import "HistoryTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define THUMB_SIZE (90.0)
#define THUMB_COLS (3)

@interface HistoryTableViewController ()

@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, retain) NSArray *photoSections;
@property (nonatomic, retain) NSArray *sectionIndexTitles;

@end


@implementation HistoryTableViewController

@synthesize assetsLibrary=_assetsLibrary;
@synthesize photoSections=_photoSections;
@synthesize sectionIndexTitles=_sectionIndexTitles;

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)dealloc
{
    self.assetsLibrary = nil;
    self.photoSections = nil;
    self.sectionIndexTitles = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = THUMB_SIZE;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Private methods

- (NSArray *)photoSections
{
    if (!_photoSections) {
        NSMutableArray *sections = [NSMutableArray array];
        NSMutableArray *assets = [NSMutableArray array];
        NSMutableArray *sectionIndexTitles = [NSMutableArray array];
        self.assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos|ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            NSLog(@"  group: %@", group);
            if (group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if (index != NSNotFound) {
                        //NSLog(@"  asset %4d: %@", index, asset);
                        [assets addObject:asset];
                    }
                }];
            } else {
                [assets sortUsingComparator:^(ALAsset *a, ALAsset *b) {
                    return [[a valueForProperty:ALAssetPropertyDate] compare:[b valueForProperty:ALAssetPropertyDate]];
                }];
                //NSMutableArray *sections = [NSMutableArray array];
                NSCalendar *cal = [NSCalendar currentCalendar];
                for (ALAsset *asset in assets) {
                    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
                    NSDictionary *section = [sections lastObject];
                    if (!section) {
                        NSDateComponents *monthComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:date];
                        NSDate *month = [cal dateFromComponents:monthComponents];
                        section = [NSDictionary dictionaryWithObjectsAndKeys:month, @"month", [NSMutableArray array], @"assets", nil];
                        [sections addObject:section];
                    }
                    NSDateComponents *nextMonthComponents = [[NSDateComponents new] autorelease];
                    [nextMonthComponents setMonth:1];
                    NSDate *nextMonth = [cal dateByAddingComponents:nextMonthComponents toDate:[section objectForKey:@"month"] options:0];
                    if ([date compare:nextMonth] != NSOrderedAscending) {
                        section = [NSDictionary dictionaryWithObjectsAndKeys:nextMonth, @"month", [NSMutableArray array], @"assets", nil];
                        [sections addObject:section];
                    }
                    [[section objectForKey:@"assets"] addObject:asset];
                }
                NSDateFormatter *yearFormatter = [[NSDateFormatter new] autorelease];
                yearFormatter.dateFormat = @"y";
                NSDateFormatter *monthFormatter = [[NSDateFormatter new] autorelease];
                monthFormatter.dateFormat = @"M月";
                NSString *lastYear = nil;
                for (NSDictionary *section in sections) {
                    NSString *title = [yearFormatter stringFromDate:[section objectForKey:@"month"]];
                    if ([lastYear isEqual:title]) {
                        title = [monthFormatter stringFromDate:[section objectForKey:@"month"]];
                    } else {
                        lastYear = title;
                    }
                    [sectionIndexTitles addObject:title];
            }
                [self.tableView reloadData];
            }
        } failureBlock: ^(NSError *error) {
            NSLog(@"ERROR: enumerateGroupsWithTypes -> %@", error);
            // TODO: ALAssetsLibraryAccessGloballyDeniedError 
        }];
        _photoSections = [sections retain];
        self.sectionIndexTitles = [sectionIndexTitles retain];
    }
    return _photoSections;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.photoSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"%s -> %d", __PRETTY_FUNCTION__, self.photoSections.count);
    int count = [[[self.photoSections objectAtIndex:section] objectForKey:@"assets"] count];
    return count / THUMB_COLS + ((count % THUMB_COLS) ? 1 : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
    dateFormatter.dateFormat = @"y年M月";
    return [dateFormatter stringFromDate:[[self.photoSections objectAtIndex:section] objectForKey:@"month"]];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitles;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        for (int i = 0; i < THUMB_COLS; i++) {
            UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(1 + (THUMB_SIZE + 1) * i, 0, THUMB_SIZE, THUMB_SIZE)] autorelease];
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, THUMB_SIZE - 10, THUMB_SIZE, 10)] autorelease];
            label.textAlignment = UITextAlignmentRight;
            label.font = [UIFont systemFontOfSize:9];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [[[UIColor alloc] initWithWhite:0 alpha:0.2] autorelease];
            [imageView addSubview:label];
            [cell.contentView addSubview:imageView];
        }
    }
    NSArray *assets = [[self.photoSections objectAtIndex:indexPath.section] objectForKey:@"assets"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
    dateFormatter.dateFormat = @"M/d HH:mm";
    for (int i = 0; i < THUMB_COLS; i++) {
        UIImageView *imageView = [cell.contentView.subviews objectAtIndex:i];
        UILabel *label = imageView.subviews.lastObject;
        int index = indexPath.row * THUMB_COLS + i;
        if (index < assets.count) {
            ALAsset *asset = [assets objectAtIndex:index];
            imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            label.text = [dateFormatter stringFromDate:date];
        } else {
            imageView.image = nil;
            label.text = nil;
        }
    }
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
