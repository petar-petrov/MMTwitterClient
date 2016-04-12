//
//  MMComposerViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 07/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMComposerViewController.h"

#import "MMTwitterManager.h"

@interface MMComposerViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *charactersLeftLabel;

@property (strong, nonatomic) NSMutableDictionary *parameters;

@property (strong, nonatomic) NSString *inReplyToStatusID;
@property (strong, nonatomic) NSString *username;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint_View;

@property (strong, nonatomic) NSMutableArray <UIImage *> *images;
@property (strong, nonatomic) NSMutableArray *mediaIDs;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation MMComposerViewController

static NSInteger kMaxNumberOfCharactersAllowedInTweet = 140;

#pragma mark - Custom Accessors

- (NSMutableDictionary *)parameters {
    if (!_parameters) {
        _parameters = [NSMutableDictionary new];
    }
    
    return _parameters;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.inReplyToStatusID) {
        self.tweetTextView.text = [[@"@" stringByAppendingString:self.username] stringByAppendingString:@" "];
        [self.parameters setObject:self.inReplyToStatusID forKey:@"in_reply_to_status_id"];
    }
    
    self.tweetTextView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.images = [NSMutableArray new];
    self.mediaIDs = [NSMutableArray new];
    
    self.statusLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tweetTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)postTweet:(id)sender {
    NSString *status = self.tweetTextView.text;
    
    if (self.tweetTextView.text.length > kMaxNumberOfCharactersAllowedInTweet) {
        status = [self.tweetTextView.text substringToIndex:kMaxNumberOfCharactersAllowedInTweet];
    }
    
    [self.parameters setObject:status forKey:@"status"];
    
    if (self.mediaIDs.count > 0) {
        [self.parameters setObject:[self.mediaIDs lastObject] forKey:@"media_ids"];
    }
    
    [[MMTwitterManager sharedManager] postTweetWithText:self.parameters image:nil url:nil complete:^(NSError *error){
        [self.tweetTextView resignFirstResponder];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancel:(id)sender {
    [self.tweetTextView resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showImagePicker:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take a Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self showImagePickerControllerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    
    [alertController addAction:takePhotoAction];
    
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self showImagePickerControllerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    [alertController addAction:photoLibraryAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark - Public Methods

- (void)setInReplyToStatusID:(NSString *)statusID username:(NSString *)username {
    self.inReplyToStatusID = statusID;
    self.username = username;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"%ld characters left", (kMaxNumberOfCharactersAllowedInTweet - textView.text.length));
    
    self.charactersLeftLabel.text = [NSString stringWithFormat:@"%ld", (kMaxNumberOfCharactersAllowedInTweet - textView.text.length)];
}

#pragma mark - Private

- (void)showImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    if ([UIImagePickerController availableMediaTypesForSourceType:sourceType]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = sourceType;
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [((NSValue *)(notification.userInfo[UIKeyboardFrameEndUserInfoKey])) CGRectValue];
    NSTimeInterval duration = [((NSNumber *)(notification.userInfo[UIKeyboardAnimationDurationUserInfoKey])) doubleValue];
    UIViewAnimationCurve curve = [((NSNumber *)(notification.userInfo[UIKeyboardAnimationCurveUserInfoKey])) integerValue];
    UIViewAnimationOptions options = curve << 16;
    
    [self animateBottomConstraintConstantToValue:keyboardFrame.size.height duration:duration animationOptions:options];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval duration = [((NSNumber *)(notification.userInfo[UIKeyboardAnimationDurationUserInfoKey])) doubleValue];
    UIViewAnimationCurve curve = [((NSNumber *)(notification.userInfo[UIKeyboardAnimationCurveUserInfoKey])) integerValue];
    UIViewAnimationOptions options = curve << 16;

    [self animateBottomConstraintConstantToValue:0.0f duration:duration animationOptions:options];
}

- (void)animateBottomConstraintConstantToValue:(CGFloat)constant duration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)options{
    
    [self.view layoutIfNeeded];
    
    self.bottomConstraint_View.constant = constant;
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.statusLabel.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    [self.images addObject:info[UIImagePickerControllerOriginalImage]];
    
    [[MMTwitterManager sharedManager] uploadMedia:info[UIImagePickerControllerOriginalImage] completed:^(NSString *mediaID, NSError *error) {
        if (error == nil) {
            [self.mediaIDs addObject:mediaID];
            NSLog(@"image uploaded");
        } else {
            NSLog(@"image not uploaded");
        }
        
        self.statusLabel.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

@end
