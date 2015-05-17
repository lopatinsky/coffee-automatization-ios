//
//  DBCommentViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBCommentViewController.h"

@interface DBCommentViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation DBCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Комментарий", nil);
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 10)];
    self.textView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.textView.backgroundColor = [UIColor db_backgroundColor];
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textView.text = self.comment;
    [self.textView becomeFirstResponder];

    [GANHelper analyzeScreen:@"Comments_screen"];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
}

- (void)clickSave:(UIBarButtonItem *)sender {
    [self.delegate commentViewController:self didFinishWithText:self.textView.text];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if([newString length] > 200){
        return NO;
    }
    
    if (!self.navigationItem.rightBarButtonItem) {
        NSString *saveString =  NSLocalizedString(@"Сохранить", nil);
        CGSize size = [saveString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]}];
        UIButton *button = [UIButton new];
        button.frame = CGRectMake(0, 0, size.width, size.height + 10);
        button.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
        [button setTitle:saveString forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
        [button addTarget:self action:@selector(clickSave:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

        if ([text isEqualToString:@"\n"]) {
        }
    }
    return YES;
}


#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect textViewRect = self.textView.frame;
    textViewRect.size.height = self.view.frame.size.height - 10 - keyboardRect.size.height;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.textView.frame = textViewRect;
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    CGRect textViewRect = self.textView.frame;
    textViewRect.size.height = self.view.frame.size.height - 10;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.textView.frame = textViewRect;
                     }
                     completion:nil];
}

@end
