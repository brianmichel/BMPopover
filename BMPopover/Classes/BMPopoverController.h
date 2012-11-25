//
//  BMPopoverController.h
//  BMPopover
//
//  Created by Brian Michel on 11/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMPopoverController : NSObject

@property (assign, readonly) BOOL visible;

#pragma mark - Appearance
@property (assign) UIEdgeInsets contentInsets;
@property (assign) CGSize popoverContentSize;
@property (strong) Class popoverBackgroundViewClass;

#pragma mark - Misc
@property (weak) id<UIPopoverControllerDelegate> delegate;
@property (strong, readonly) UIViewController *contentViewController;

#pragma mark - API
- (id)initWithContentViewController:(UIViewController *)contentViewController;

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

#pragma mark - Layout
- (void)setPopoverContentSize:(CGSize)popoverContentSize animated:(BOOL)animated;
@end

//Better make a version of this jawn too
@interface BMPopoverBackgroundView : UIView

@property (assign) UIPopoverArrowDirection arrowDirection;
@property (assign) CGFloat arrowOffset;

+ (BOOL)wantsDefaultContentAppearance;
+ (UIEdgeInsets)contentViewInsets;
+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;

@end

//Basic subclass that places arrows with drawRect:
@interface BMBasicPopoverBackgroundView : BMPopoverBackgroundView

@end
