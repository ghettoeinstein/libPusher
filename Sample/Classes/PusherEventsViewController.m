//
//  PusherEventsViewController.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherClient.h"
#import "NewEventViewController.h"

@implementation PusherEventsViewController

@synthesize eventsPusher;
@synthesize eventsReceived;
@synthesize pusherClient;

- (void)viewDidLoad 
{
  self.tableView.rowHeight = 55;
  
  if (eventsReceived == nil) {
    eventsReceived = [[NSMutableArray alloc] init];
  }
  if (eventsPusher == nil) {
    eventsPusher = [[PTPusher alloc] initWithKey:PUSHER_API_KEY channel:@"events"];
    [eventsPusher addEventListener:@"new-event" target:self selector:@selector(handleNewEvent:)];
  }
  if (pusherClient == nil) {
    pusherClient = [[PTPusherClient alloc] initWithAppID:@"40" key:PUSHER_API_KEY secret:PUSHER_API_SECRET];
  }
  
  UIBarButtonItem *newEventButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentNewEventScreen)];
  self.toolbarItems = [NSArray arrayWithObject:newEventButtonItem];
  
  [super viewDidLoad];
}

- (void)dealloc {
  [pusherClient release];
  [eventsReceived release];
  [eventsPusher release];
  [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)presentNewEventScreen;
{
  NewEventViewController *newEventController = [[NewEventViewController alloc] init];
  newEventController.delegate = self;
  [self presentModalViewController:newEventController animated:YES];
  [newEventController release];
}

- (void)sendEventWithMessage:(NSString *)message;
{
  NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:message, @"title", @"Sent from libPusher", @"description", nil];

  [self performSelector:@selector(sendEvent:) withObject:payload afterDelay:0.3];
  [self dismissModalViewControllerAnimated:YES];
}

- (void)sendEvent:(id)payload;
{
  [self.pusherClient triggerEvent:@"new-event" channel:@"events" data:payload];
}

#pragma mark -
#pragma mark PTPusherEvent handling

- (void)handleNewEvent:(PTPusherEvent *)event;
{
  [self.tableView beginUpdates];
  [eventsReceived insertObject:event atIndex:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
  return eventsReceived.count;
}

static NSString *EventCellIdentifier = @"EventCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EventCellIdentifier] autorelease];
  }
  PTPusherEvent *event = [eventsReceived objectAtIndex:indexPath.row];
  cell.textLabel.text = [event.data valueForKey:@"title"];
  cell.detailTextLabel.text = [event.data valueForKey:@"description"];
  
  return cell;
}

@end