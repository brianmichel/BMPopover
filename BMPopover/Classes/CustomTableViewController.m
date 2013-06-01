//
//  CustomTableViewController.m
//  BMPopover
//
//  Created by Brian Michel on 11/25/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import "CustomTableViewController.h"
#import "BMPopoverController.h"

@interface CustomTableViewController () <BMPopoverControllerDelegate>
@property (strong) BMPopoverController *controller;
@end

@implementation CustomTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
      [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
  cell.textLabel.text = [indexPath description];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
  vc.view.backgroundColor = [UIColor blueColor];
  vc.view.autoresizingMask = UIViewAutoresizingNone;
  vc.contentSizeForViewInPopover = CGSizeMake(200, 110);
  self.controller = [[BMPopoverController alloc] initWithContentViewController:vc];
  CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
  [self.controller presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  self.controller.delegate = self;
}

- (void)popoverControllerDidDismissPopover:(BMPopoverController *)popoverController {
  self.controller = nil;
}

@end
