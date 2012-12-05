//
//  BMPopoverController.h
//  BMPopover
//
//  Created by Brian Michel on 11/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMPopoverController;
@protocol BMPopoverControllerDelegate <NSObject>

@optional
- (void)popoverControllerDidDismissPopover:(BMPopoverController *)popoverController;
- (BOOL)popoverControllerShouldDismissPopover:(BMPopoverController *)popoverController;
@end

@interface BMPopoverController : NSObject

@property (assign, readonly) BOOL visible;

#pragma mark - Appearance
@property (assign) UIEdgeInsets contentInsets;
@property (assign) CGSize popoverContentSize;
@property (strong) Class popoverBackgroundViewClass;

#pragma mark - Misc
@property (weak) id<BMPopoverControllerDelegate> delegate;
@property (strong, readonly) UIViewController *contentViewController;

#pragma mark - API
- (id)initWithContentViewController:(UIViewController *)contentViewController;

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

#pragma mark - Layout
- (void)setPopoverContentSize:(CGSize)popoverContentSize animated:(BOOL)animated;
@end

@interface BMPopoverController (Unimplemented)
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
@end

@interface UIViewController (BMPopoverExtensions)
@property (nonatomic, readonly, strong) BMPopoverController *popoverController;
@end

@interface UIBarButtonItem(BMPopoverExtensions)
- (CGRect)frameInView:(UIView *)v;
- (UIView *)superview;
@end

//Basically the same thing as a UIPopoverBackgroundView
@interface BMPopoverBackgroundView : UIView

@property (nonatomic, readwrite) UIPopoverArrowDirection arrowDirection;
@property (nonatomic, readwrite) CGFloat arrowOffset;

+ (UIEdgeInsets)contentViewInsets;
+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;

//Not fully implemented
+ (BOOL)wantsDefaultContentAppearance;

@end

//Default background view class if non is provided
//Basic subclass that places arrows with drawRect:
@interface BMBasicPopoverBackgroundView : BMPopoverBackgroundView
@property (strong) UIColor *fillColor;
@end
