//
//  MMImageDetailsViewController.m
//  MMGalery
//
//  Created by Petar Petrov on 09/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMImageDetailsViewController.h"
#import "Tweet.h"
#import "UIImageView+Networking.h"

@interface MMImageDetailsViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;

@property (assign, nonatomic, getter=isZoomedIn) BOOL zoomedIn;

@property (assign, nonatomic) CGFloat zoomingScale;
@property (assign, nonatomic) CGFloat storedScale;

@property (strong, nonatomic) UIImage *image;

@property (nonatomic) CGRect imageZoomRect;

@end

@implementation MMImageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    
    [self.scrollView addGestureRecognizer:tapGesture];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      self.scrollView.contentSize = self.image.size;
                                                      
                                                      self.scrollView.frame = self.view.frame;
                                              
                                                      CGFloat minScale = [self calculateMinScale];
                                                      self.scrollView.minimumZoomScale = minScale;
                                                      self.scrollView.zoomScale = minScale;
                                                      
                                                      if (self.storedScale != 0) {
                                                          self.scrollView.zoomScale = self.storedScale;
                                                      }
                                                      
                                                    
                                                      [self centerScrollViewContent];
                                                }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.imageView psetImageWithURLString:self.tweetInfo.mediaURL placeholder:nil compeletionHandler:^ (UIImage *image){
        self.image = image;
        
        
        
        self.scrollView.contentSize = image.size;
        
        self.imageView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        
        CGFloat minScale = [self calculateMinScale];
        self.scrollView.minimumZoomScale = minScale;
        
        self.scrollView.maximumZoomScale = 1.5f;
        self.scrollView.zoomScale = minScale;

        [self centerScrollViewContent];

        self.zoomedIn = YES;
        
        [self.scrollView addSubview:self.imageView];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (IBAction)close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    
    CGPoint pointInView = [gesture locationInView:self.imageView];
    
    self.imageZoomRect = [self zoomRectForPoint:pointInView];
    
    [self.scrollView zoomToRect:self.imageZoomRect animated:YES];
}

- (CGRect)zoomRectForPoint:(CGPoint)point {
    CGFloat newZoomScale;
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    if (self.isZoomedIn) {
        newZoomScale = self.scrollView.zoomScale * 1.5f;
        newZoomScale = 2.5f;
        
        self.zoomedIn = NO;
    } else {
        newZoomScale = [self calculateMinScale];
        
        self.zoomedIn = YES;
    }
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    
    return CGRectMake(x, y, w, h);
}

- (CGFloat)calculateMinScale {
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    
    return MIN(scaleWidth, scaleHeight);
}

- (void)centerScrollViewContent {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - UIScrollViewDelegate 

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContent];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.zoomingScale = self.scrollView.zoomScale;
    self.storedScale = 0;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.zoomingScale < scale) {
        self.zoomedIn = NO;
    } else {
        self.zoomedIn = YES;
    }
    
    self.storedScale = scale;
}

@end
