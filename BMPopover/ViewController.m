//
//  ViewController.m
//  BMPopover
//
//  Created by Brian Michel on 11/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import "ViewController.h"
#import "BMPopoverController.h"

@interface ViewController ()
@property (strong) BMPopoverController *popover;
@property (strong) UIPopoverController *controller;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showPopover:(UIButton *)sender {
  UITableViewController *vc = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
  vc.view.autoresizingMask = UIViewAutoresizingNone;
  vc.contentSizeForViewInPopover = CGSizeMake(200, 150);
  self.popover = [[BMPopoverController alloc] initWithContentViewController:vc];
  [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  
//  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//    self.controller = [[UIPopoverController alloc] initWithContentViewController:vc];
//    [self.controller presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    //[self logSuperViews:self.controller.contentViewController.view];
//  } else {
//    self.popover = [[BMPopoverController alloc] initWithContentViewController:vc];
//    [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//  }
}

- (void)logSuperViews:(UIView *)view {
  if (view.superview) {
    NSLog(@"SuperView: %@", view.superview);
    [self logSuperViews:view.superview];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
