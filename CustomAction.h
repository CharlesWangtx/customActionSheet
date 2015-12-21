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

//tableview布局的
- (instancetype)initCustomWithTitle:(NSString *)title delegate:(id<CustomActionDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;

//collectView布局的
- (instancetype)initCustomBottomWithTitle:(NSString *)title delegate:(id<CustomActionDelegate>)delegate otherButtonTitles:(NSArray *)otherButtonTitles otherBtnImgs:(NSArray *)otherBtnImgs;


@property (nonatomic,assign) id<CustomActionDelegate>delegate;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *cancelBtn;

//传给当前停车界面的btn
@property (nonatomic,strong) UIButton *senderBtn;

//触发消失的block
@property (nonatomic, copy) dispatch_block_t dismissBlock;
//tableview didselect block 用这个block在初始化时将代理置为nil
@property (nonatomic, copy) void (^tabViewDidSelectBlock)(NSInteger buttonIndex);

- (void)show;
@end
