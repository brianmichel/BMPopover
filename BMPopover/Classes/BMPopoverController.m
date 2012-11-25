//
//  BMPopoverController.m
//  BMPopover
//
//  Created by Brian Michel on 11/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import "BMPopoverController.h"

@interface BMPopoverWindow : UIWindow
@property (strong) NSArray *passthroughViews;
@property (weak) BMPopoverController *controller;
@property (assign) CGRect contentRect;
@end

@interface BMPopoverBackgroundView ()
@property (strong) UIView *contentView;
@end

@implementation BMPopoverBackgroundView

@synthesize contentView = _contentView;

+ (BOOL)wantsDefaultContentAppearance {
  return YES;
}

+ (CGFloat)arrowBase {
  return 0.0;
}

+ (CGFloat)arrowHeight {
  return 0.0;
}

+ (UIEdgeInsets)contentViewInsets {
  return UIEdgeInsetsZero;
}

- (void)commonInit {
  if ([[self class] wantsDefaultContentAppearance]) {
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 10.0;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
return self;
}

- (void)setContentView:(UIView *)contentView {
  if (_contentView) {
    [_contentView removeFromSuperview];
  }
  _contentView = contentView;
  
  if ([[self class] wantsDefaultContentAppearance]) {
    _contentView.layer.cornerRadius = 3.0;
    _contentView.layer.masksToBounds = YES;
  }
  
  [self addSubview:_contentView];
}

- (UIView *)contentView {
  return _contentView;
}

@end

@interface BMPopoverController ()

@property (strong) BMPopoverWindow *displayWindow;
@property (strong) UIViewController *containerViewController;
@property (strong) BMPopoverBackgroundView *backgroundView;
@end

@implementation BMPopoverController

@synthesize contentViewController = _contentViewController;
@synthesize visible = _visible;
@synthesize contentInsets = _contentInsets;
@synthesize popoverBackgroundViewClass = _popoverBackgroundViewClass;
@dynamic popoverContentSize;

- (id)initWithContentViewController:(UIViewController *)contentViewController {
  NSParameterAssert(contentViewController);
  self = [super init];
  if (self) {
    _contentViewController = contentViewController;
    
    self.containerViewController = [[UIViewController alloc] init];
    self.containerViewController.view.backgroundColor = [UIColor clearColor];
    self.containerViewController.view.alpha = 0.0;
    
    self.contentInsets = UIEdgeInsetsZero;
    
    self.displayWindow = [[BMPopoverWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.displayWindow.backgroundColor = [UIColor clearColor];
    self.displayWindow.transform = [UIApplication sharedApplication].keyWindow.transform;
    self.displayWindow.rootViewController = self.containerViewController;
    
    self.popoverBackgroundViewClass = [BMBasicPopoverBackgroundView class];
  }
  return self;
}
#pragma mark - API
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
  if (!self.visible) {
    _visible = YES;
  }
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
  if (!self.visible) {
    void (^animations)(void) = ^{
      self.containerViewController.view.alpha = 1.0;
    };
    
    [self setupContentViewControllerForRect:rect inView:view withPermittedArrowDirections:arrowDirections];
    [self.displayWindow makeKeyAndVisible];
    
    if (animated) {
      [UIView animateWithDuration:0.3 animations:animations completion:^(BOOL finished) {
        _visible = YES;
      }];
    } else {
      animations();
      _visible = YES;
    }
  }
}

- (void)dismissPopoverAnimated:(BOOL)animated {
  if (self.delegate && [self.delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)]) {
    BOOL dismiss = [self.delegate popoverControllerShouldDismissPopover:self];
    if (!dismiss) {
      return;
    }
  }
  if (self.visible) {
    void (^animations)(void) = ^{
      self.containerViewController.view.alpha = 0.0;
    };
    
    if (animated) {
      [UIView animateWithDuration:0.3 animations:animations completion:^(BOOL finished) {
        self.displayWindow.hidden = YES;
        _visible = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
          [self.delegate popoverControllerDidDismissPopover:self];
        }
      }];
    } else {
      animations();
      self.displayWindow.hidden = YES;
      _visible = NO;
      if (self.delegate && [self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
        [self.delegate popoverControllerDidDismissPopover:self];
      }
    }
  }
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated {
  if (self.visible) {
    void(^animations)(void) = ^{
      self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, self.contentViewController.view.frame.origin.y, size.width, size.height);
      self.displayWindow.contentRect = self.backgroundView.frame;
    };
    
    if (animated) {
      [UIView animateWithDuration:0.3 animations:animations completion:nil];
    } else {
      animations();
    }
  }
}

#pragma mark - Setters / Getters
- (CGSize)popoverContentSize {
  return self.contentViewController.view.frame.size;
}

- (void)setPopoverContentSize:(CGSize)popoverContentSize {
  [self setPopoverContentSize:popoverContentSize animated:YES];
}

- (void)setPopoverBackgroundViewClass:(Class)popoverBackgroundViewClass {
  _popoverBackgroundViewClass = popoverBackgroundViewClass;
  if (self.popoverBackgroundViewClass) {
    self.backgroundView = [[_popoverBackgroundViewClass alloc] init];
  } else {
    self.backgroundView = [[BMBasicPopoverBackgroundView alloc] init];
  }
}

- (Class)popoverBackgroundViewClass {
  return _popoverBackgroundViewClass;
}

#pragma mark - Helpers
- (void)setupContentViewControllerForRect:(CGRect)rect inView:(UIView *)view withPermittedArrowDirections:(UIPopoverArrowDirection)directions {
  self.contentViewController.view.frame = CGRectMake(0, 0, self.contentViewController.contentSizeForViewInPopover.width, self.contentViewController.contentSizeForViewInPopover.height);
  self.backgroundView.contentView = self.contentViewController.view;

  CGRect originatingRect = [self.containerViewController.view convertRect:rect toView:nil];
  
  //self.contentViewController.view.backgroundColor = [UIColor brownColor];
  //self.backgroundView.backgroundColor = [UIColor greenColor];
  
  UIPopoverArrowDirection bestDirection = [self bestArrowDirectionForRect:originatingRect];
  self.backgroundView.arrowDirection = bestDirection;
  
  CGRect layoutRect = [self layoutRectForArrowDirection:bestDirection withRect:originatingRect];
  CGRect contentRect = [self contentRectForArrowDirection:bestDirection withContainerRect:layoutRect];

  self.backgroundView.frame = layoutRect;
  self.backgroundView.contentView.frame = contentRect;
  
  CGFloat arrowOffset = [self arrowOffsetForOriginatingRect:originatingRect layoutRect:layoutRect andArrowDirection:bestDirection];
  self.backgroundView.arrowOffset = arrowOffset;
  
  
  [self.containerViewController.view addSubview:self.backgroundView];
  self.displayWindow.contentRect = self.backgroundView.frame;
  self.displayWindow.controller = self;
}

- (CGRect)layoutRectForArrowDirection:(UIPopoverArrowDirection)arrowDirection withRect:(CGRect)rect {
  CGRect boundingRect = CGRectMake(10, 10, self.containerViewController.view.frame.size.width - 20, self.containerViewController.view.frame.size.height - 20);
  CGFloat x, y, height, width;
  UIEdgeInsets insets = [[self.backgroundView class] contentViewInsets];
  CGFloat arrowHeight = [[self.backgroundView class] arrowHeight];
  width = self.contentViewController.view.frame.size.width + insets.left + insets.right;
  height = self.contentViewController.view.frame.size.height + insets.top + insets.bottom;
  
  switch (arrowDirection) {
    case UIPopoverArrowDirectionUp:
      x = (rect.origin.x + rect.size.width/2) - width/2;
      y = CGRectGetMaxY(rect);
      height += arrowHeight;
      break;
    case UIPopoverArrowDirectionRight:
      x = rect.origin.x - width;
      y = (rect.origin.y + (rect.size.height/2)) - height/2;
      width += arrowHeight;
      break;
    case UIPopoverArrowDirectionDown:
      x = (rect.origin.x + rect.size.width/2) - width/2;
      y = rect.origin.y - height;
      height += arrowHeight;
      break;
    case UIPopoverArrowDirectionLeft:
      x = CGRectGetMaxX(rect);
      y = (rect.origin.y + (rect.size.height/2)) - height/2;
      width += arrowHeight;
      break;
    default:
      x = round(self.containerViewController.view.frame.size.width/2 - width/2);
      y = round(self.containerViewController.view.frame.size.height/2 - height/2);
      break;
  }
  CGFloat correctedX = x < boundingRect.origin.x ? boundingRect.origin.x : x;
  correctedX = correctedX + width > CGRectGetMaxX(boundingRect) ? CGRectGetMaxX(boundingRect) - width : correctedX;
  return CGRectMake(correctedX, y < boundingRect.origin.y ? boundingRect.origin.y : y, width, height);
}

- (CGRect)contentRectForArrowDirection:(UIPopoverArrowDirection)arrowDirection withContainerRect:(CGRect)containerRect {
  CGFloat x, y, height, width;
  UIEdgeInsets insets = [[self.backgroundView class] contentViewInsets];
  CGFloat arrowHeight = [[self.backgroundView class] arrowHeight];
  
  switch (arrowDirection) {
    case UIPopoverArrowDirectionUp:
      x = insets.left;
      y = insets.top + arrowHeight;
      width = containerRect.size.width - insets.left - insets.right;
      height = containerRect.size.height - arrowHeight - insets.top - insets.bottom;
      break;
    case UIPopoverArrowDirectionRight:
      x = insets.left;
      y = insets.top;
      width = containerRect.size.width - insets.left - insets.right - arrowHeight;
      height = containerRect.size.height - insets.top - insets.bottom;
      break;
    case UIPopoverArrowDirectionDown:
      x = insets.left;
      y = insets.top;
      width = containerRect.size.width - insets.left - insets.right;
      height = containerRect.size.height - arrowHeight - insets.top - insets.bottom;
      break;
    case UIPopoverArrowDirectionLeft:
      x = arrowHeight + insets.left;
      y = insets.top;
      width = containerRect.size.width - insets.left - insets.right - arrowHeight;
      height = containerRect.size.height - insets.top - insets.bottom;
      break;
    default:
      x = insets.left;
      y = insets.top;
      width = containerRect.size.width;
      height = containerRect.size.height;
      break;
  }
  return CGRectMake(x, y, width, height);
}


- (UIPopoverArrowDirection)bestArrowDirectionForRect:(CGRect)rect {
  CGRect screenRect = self.containerViewController.view.frame;
  CGFloat leftSpace = rect.origin.x - screenRect.origin.x;
  CGFloat rightSpace = CGRectGetMaxX(screenRect) - CGRectGetMaxX(rect);
  CGFloat topSpace = rect.origin.y - screenRect.origin.y;
  CGFloat bottomSpace =  CGRectGetMaxY(screenRect) - CGRectGetMaxY(rect);
  NSArray *values = @[@(leftSpace), @(rightSpace), @(topSpace), @(bottomSpace)];
  NSArray *sortedValues = [values sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    NSNumber *number1 = (NSNumber *)obj1;
    NSNumber *number2 = (NSNumber *)obj2;
    return [number1 compare:number2];
  }];
  
  CGFloat largestValue = [((NSNumber *)[sortedValues lastObject]) floatValue];
  if (largestValue == leftSpace) {
    return UIPopoverArrowDirectionRight;
  } else if (largestValue == rightSpace) {
    return UIPopoverArrowDirectionLeft;
  } else if (largestValue == topSpace) {
    return UIPopoverArrowDirectionDown;
  } else if (largestValue == bottomSpace) {
    return UIPopoverArrowDirectionUp;
  } else {
    return UIPopoverArrowDirectionUnknown;
  }
}

- (CGFloat)arrowOffsetForOriginatingRect:(CGRect)originatingRect layoutRect:(CGRect)layoutRect andArrowDirection:(UIPopoverArrowDirection)direction {
  CGPoint originatingRectCenter = CGPointMake(originatingRect.origin.x + (originatingRect.size.width/2), originatingRect.origin.y + (originatingRect.size.height/2));
  CGPoint layoutRectCenter = CGPointMake(layoutRect.origin.x + (layoutRect.size.width/2), layoutRect.origin.y + (layoutRect.size.height/2));
  switch (direction) {
    case UIPopoverArrowDirectionDown:
    case UIPopoverArrowDirectionUp:
      return originatingRectCenter.x - layoutRectCenter.x;
      break;
    case UIPopoverArrowDirectionLeft:
    case UIPopoverArrowDirectionRight:
      return originatingRectCenter.y - layoutRectCenter.y;
      break;
    default:
      break;
  }
  return 0.0;
}

- (void)dealloc {
  if (self.visible) {
    [NSException raise:NSInternalInconsistencyException format:@"<%@> An instance of BMPopoverController was deallocated while still visible. This usually means the object was not propertly retained.", self];
  }
}

#pragma mark - Window Callbacks

@end

@implementation BMPopoverWindow
/*
 1.) if a given touch is within a passthroughview, pass it on.
 */

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *anyTouch = [touches anyObject];
  if (!CGRectContainsPoint(self.contentRect, [anyTouch locationInView:self])) {
    [self.controller dismissPopoverAnimated:YES];
    return;
  }
  
  [super touchesEnded:touches withEvent:event];
}
@end

@implementation BMBasicPopoverBackgroundView

@synthesize fillColor = _fillColor;

- (id)init {
  self = [super init];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 10.0;
    self.fillColor = [UIColor darkGrayColor];
  }
  return self;
}

+ (UIEdgeInsets)contentViewInsets {
  return UIEdgeInsetsMake(8, 8, 8, 8);
}

+ (CGFloat)arrowBase {
  return 35.0;
}

+ (CGFloat)arrowHeight {
  return 20.0;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {
  [super setArrowDirection:arrowDirection];
  [self setNeedsDisplay];
}

- (void)setArrowOffset:(CGFloat)arrowOffset {
  [super setArrowOffset:arrowOffset];
  [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
  _fillColor = fillColor;
  [self setNeedsDisplay];
}

- (UIColor *)fillColor {
  return _fillColor;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGFloat arrowHeight = [BMBasicPopoverBackgroundView arrowHeight];
  
  CGFloat arrowBase = [BMBasicPopoverBackgroundView arrowBase];
  CGFloat arrowOffset = self.arrowOffset;
  CGMutablePathRef arrowPath = CGPathCreateMutable();
  
  CGFloat outlineOriginX = 0;
  CGFloat outlineOriginY = 0;
  CGFloat outlineHeight = self.bounds.size.height;
  CGFloat outlineWidth = self.bounds.size.width;
  switch (self.arrowDirection) {
    case UIPopoverArrowDirectionDown:
      outlineHeight -= arrowHeight;
      CGPathMoveToPoint(arrowPath, NULL, round(self.bounds.size.width/2) + (arrowOffset - (arrowBase/2)), outlineHeight);
      CGPathAddLineToPoint(arrowPath, NULL, round(self.bounds.size.width/2) + arrowOffset, self.bounds.size.height);
      CGPathAddLineToPoint(arrowPath, NULL, round(self.bounds.size.width/2) + arrowOffset + (arrowBase/2), outlineHeight);
      break;
    case UIPopoverArrowDirectionUp:
      outlineOriginY = arrowHeight;
      outlineHeight -= arrowHeight;
      CGPathMoveToPoint(arrowPath, NULL, round(self.bounds.size.width/2) + (arrowOffset - (arrowBase/2)), outlineOriginY);
      CGPathAddLineToPoint(arrowPath, NULL, round(self.bounds.size.width/2) + arrowOffset, 0);
      CGPathAddLineToPoint(arrowPath, NULL, round(self.bounds.size.width/2) + arrowOffset + (arrowBase/2), outlineOriginY);
      break;
    case UIPopoverArrowDirectionLeft:
      outlineOriginX = arrowHeight;
      outlineWidth -= arrowHeight;
      CGPathMoveToPoint(arrowPath, NULL, outlineOriginX, round(self.bounds.size.height/2) + (arrowOffset - (arrowBase/2)));
      CGPathAddLineToPoint(arrowPath, NULL, 0, round(self.bounds.size.height/2) + arrowOffset);
      CGPathAddLineToPoint(arrowPath, NULL, outlineOriginX, round(self.bounds.size.height/2) + arrowOffset + (arrowBase/2));
      break;
    case UIPopoverArrowDirectionRight:
      outlineWidth -= arrowHeight;
      CGPathMoveToPoint(arrowPath, NULL, self.bounds.size.width - arrowHeight, round(self.bounds.size.height/2) + (arrowOffset - (arrowBase/2)));
      CGPathAddLineToPoint(arrowPath, NULL, self.bounds.size.width, round(self.bounds.size.height/2) + arrowOffset);
      CGPathAddLineToPoint(arrowPath, NULL, self.bounds.size.width - arrowHeight, round(self.bounds.size.height/2) + (arrowOffset + (arrowBase/2)));
      break;
    default:
      break;
  }
  CGRect outlineRect = CGRectMake(outlineOriginX, outlineOriginY, outlineWidth, outlineHeight);
  UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:outlineRect cornerRadius:5.0];
  CGColorRef fillColor = self.fillColor.CGColor;
  
  CGContextSaveGState(ctx);
  CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
  CGContextSetFillColorWithColor(ctx, fillColor);
  CGContextAddPath(ctx, outerPath.CGPath);
  CGContextFillPath(ctx);
  CGContextStrokePath(ctx);
  
  CGContextRestoreGState(ctx);
  
  CGContextSaveGState(ctx);
  CGContextSetFillColorWithColor(ctx, fillColor);
  
  CGContextAddPath(ctx, arrowPath);
  CGContextFillPath(ctx);
  CFRelease(arrowPath);
  CGContextRestoreGState(ctx);
}

@end
