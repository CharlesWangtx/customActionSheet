//
//  CustomAction.h
//  ChmtechIOS
//
//  Created by taixiangwang on 15/9/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomAction;
@protocol CustomActionDelegate <NSObject>

- (void)customActionSheet:(CustomAction *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface CustomAction : UIView

- (instancetype)initCustomWithTitle:(NSString *)title delegate:(id<CustomActionDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;

@property (nonatomic,assign) id<CustomActionDelegate>delegate;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *cancelBtn;

//触发消失的block
@property (nonatomic, copy) dispatch_block_t dismissBlock;

- (void)show;
@end
