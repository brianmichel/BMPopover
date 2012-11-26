//
//  ViewController.m
//  BMPopover
//
//  Created by Brian Michel on 11/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import "ViewController.h"
#import "BMPopoverController.h"
#import "KSCustomPopoverBackgroundView.h"
#import "CustomTableViewController.h"

@interface ViewController () <BMPopoverControllerDelegate>
@property (strong) BMPopoverController *popover;
@property (strong) UIPopoverController *controller;
@property (strong) UIButton *lastButton;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showPopover:(UIButton *)sender {
  self.lastButton = sender;
  CustomTableViewController *vc = [[CustomTableViewController alloc] initWithStyle:UITableViewStylePlain];
  vc.view.autoresizingMask = UIViewAutoresizingNone;
  vc.contentSizeForViewInPopover = CGSizeMake(200, 150);
  self.popover = [[BMPopoverController alloc] initWithContentViewController:vc];
  if (self.segmentedControl.selectedSegmentIndex == 0) {
    self.popover.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
  }
  self.popover.popoverBackgroundViewClass = self.segmentedControl.selectedSegmentIndex == 0 ?[KSCustomPopoverBackgroundView class] : nil;
  [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  self.popover.delegate = self;
}

#pragma mark - Popover Delegate
- (BOOL)popoverControllerShouldDismissPopover:(BMPopoverController *)popoverController {
  return YES;
}

- (void)popoverControllerDidDismissPopover:(BMPopoverController *)popoverController {
  self.popover = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
