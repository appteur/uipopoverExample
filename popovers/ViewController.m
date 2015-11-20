//
//  ViewController.m
//  popovers
//
//  Created by Seth on 11/18/15.
//  Copyright © 2015 Seth Arnott. All rights reserved.
//

#import "ViewController.h"
#import "PopoverViewController.h"

@interface ViewController ()<UIPopoverPresentationControllerDelegate>

// the editing suite toolbar (lower)
@property (weak, nonatomic) IBOutlet UIToolbar *lowerToolbar;

@property (nonatomic, weak) UIView *activePopoverBtn;
@property (nonatomic, strong) PopoverViewController *popoverVC;
@property (nonatomic, assign) CGRect sourceRect;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup our view
    [self setupToolbar];
}

// called when rotating a device
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"viewWillTransitionToSize [%@]", NSStringFromCGSize(size));

    // resizes popover to new size and arrow location on orientation change
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context)
    {
        if (self.popoverVC)
        {
            // get the new frame of our button (this is our new source rect)
            CGRect viewframe = self.activePopoverBtn ? self.activePopoverBtn.frame : CGRectZero;
            
            // update our popover view controller's sourceRect so the arrow will be pointed in the right place
            self.popoverVC.popoverPresentationController.sourceRect = viewframe;
            
            // update the preferred content size if we want to adapt the size of the popover to fit the new bounds
            self.popoverVC.preferredContentSize = CGSizeMake(self.view.bounds.size.width -20, self.view.bounds.size.height - 100);
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // anything you want to do when the transition completes
    }];
}


-(void) setupToolbar
{
    UIBarButtonItem *flex       = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    // setup button for toolbar
    UIButton *toolbarBtn        = [self buttonWithSelector:@selector(buttonAction:event:) title:@"1" color:[UIColor redColor]];
    [toolbarBtn setBackgroundColor:[UIColor greenColor]];
    
    // create our bar button item using our button
    UIBarButtonItem *btnItem    = [[UIBarButtonItem alloc] initWithCustomView:toolbarBtn];
    
    // set our items to put into the toolbar
    NSArray *items = @[flex, btnItem, flex];
    
    // put our items into the toolbar
    [self.lowerToolbar setItems:items animated:YES];
}

-(UIButton*) buttonWithSelector:(SEL)selector title:(NSString*)title color:(UIColor*)color
{
    // convenience button creation method that configures all the buttons the same
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [editBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTitle:title forState:UIControlStateNormal];
    [editBtn setTintColor:color];
    [editBtn setTitleColor:color forState:UIControlStateNormal];
    [editBtn.titleLabel setFont:[UIFont fontWithName:@"Arial" size:17.0]];
    
    return editBtn;
}


-(void) buttonAction:(id)sender event:(UIEvent*)event
{
    NSLog(@"ButtonAction");
    
    // when the button is tapped we want to display a popover, so setup all the variables needed and present it here
    
    // get a reference to which button's view was tapped (this is to get the frame to update the arrow to later)
    UIView *buttonView          = [[event.allTouches anyObject] view];
    
    // set our tracker properties for when the orientation changes (handled in the viewWillTransitionToSize method above)
    self.activePopoverBtn       = buttonView;
    self.sourceRect             = buttonView.frame;
    
    // get our size, make it adapt based on our view bounds
    CGSize viewSize             = self.view.bounds.size;
    CGSize contentSize          = CGSizeMake(viewSize.width, viewSize.height - 100.0);
    
    // set our popover view controller property
    self.popoverVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PopoverVC"];
    
    // configure using a convenience method (if you have multiple popovers this makes it faster with less code)
    [self setupPopover:self.popoverVC
        withSourceView:buttonView.superview // this will be the toolbar
            sourceRect:self.sourceRect
           contentSize:contentSize];
    
    [self presentViewController:self.popoverVC animated:YES completion:nil];
    
}


// convenience method in case you want to display multiple popovers
-(void) setupPopover:(UIViewController*)popover withSourceView:(UIView*)sourceView sourceRect:(CGRect)sourceRect contentSize:(CGSize)contentSize
{
    NSLog(@"\npopoverPresentationController: %@\n", popover.popoverPresentationController);
    
    popover.modalPresentationStyle = UIModalPresentationPopover;
    popover.popoverPresentationController.delegate = self;
    popover.popoverPresentationController.sourceView                = sourceView;
    popover.popoverPresentationController.sourceRect                = sourceRect;
    popover.preferredContentSize                                    = contentSize;
    popover.popoverPresentationController.permittedArrowDirections  = UIPopoverArrowDirectionDown;
    popover.popoverPresentationController.backgroundColor           = [UIColor whiteColor];
}










#pragma mark - Popover Presentation Controller Delegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    NSLog(@"prepareForPopoverPresentation");
    // do any setup you want to do here before the popover is presented
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view
{
    NSLog(@"willRepositionPopoverToRect - controller: %@  rect: [%@] inView: %@", popoverPresentationController, NSStringFromCGRect(*rect), *view);
    // deal with repositioning
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    NSLog(@"popoverPresentationControllerShouldDismissPopover");
    return YES;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    NSLog(@"popoverPresentationControllerDidDismissPopover");
    
    // we dismissed the popover so set it to nil here
    self.popoverVC = nil;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    NSLog(@"adaptivePresentationStyleForPresentationController: %@", controller);
    
    // This makes it an actual popover on an iphone
    return UIModalPresentationNone;
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
