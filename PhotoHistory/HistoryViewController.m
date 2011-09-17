#import "HistoryViewController.h"

@interface HistoryViewController ()

@property (nonatomic, retain) UIScrollView *scrollView;

@end

@implementation HistoryViewController

@synthesize scrollView=_scrollView;

- (void)dealloc
{
    self.scrollView = nil;
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
    // scroll view
    UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    CGSize contentSize = scrollView.frame.size;
    contentSize.height *= 2;
    scrollView.contentSize = contentSize;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollView flashScrollIndicators];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
