//
//  CustomAction.m
//  ChmtechIOS
//
//  Created by taixiangwang on 15/9/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//
#define cellHeight              44
#define cancelToTabView         20
#define toView                  10
#define selfWidth               SCREENWIDTH-2*toView


#import "CustomAction.h"

@interface CustomAction ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *otherTabView;
@property (nonatomic,strong) NSArray *otherButtonArr;
@property (nonatomic,strong) UIView *backimageView;

@property (nonatomic,assign) CGFloat customHeight;
@property (nonatomic,assign) CGFloat titleHeight;

@end

@implementation CustomAction

-(instancetype)initCustomWithTitle:(NSString *)title delegate:(id<CustomActionDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles{
    
    if (self = [super init]) {

        self.backgroundColor = [UIColor clearColor];
        self.otherButtonArr = [NSArray arrayWithArray:otherButtonTitles];
        self.delegate = delegate;
        
        if (title) {
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, SCREENWIDTH, 25)];
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.titleLabel.text = title;
            self.titleLabel.textColor = [UIColor darkGrayColor];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            
            //创建中间的tableview
            self.otherTabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, selfWidth, self.otherButtonArr.count*cellHeight+30) style:UITableViewStylePlain];
            self.titleHeight = 30;
        }
        else{
            //创建中间的tableview
            self.otherTabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, selfWidth, self.otherButtonArr.count*cellHeight) style:UITableViewStylePlain];
            self.titleHeight = 0;
        }
        
        self.otherTabView.backgroundColor = [UIColor whiteColor];
        self.otherTabView.layer.cornerRadius = 5.0;
        self.otherTabView.delegate = self;
        self.otherTabView.dataSource = self;
        self.otherTabView.rowHeight = cellHeight;
        [self addSubview:self.otherTabView];
        
        //解决tableView分割线左边不到边的情况 在初始化tableview写
        if ([self.otherTabView respondsToSelector:@selector(setSeparatorInset:)])
        {
            [self.otherTabView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self.otherTabView respondsToSelector:@selector(setLayoutMargins:)])
        {
            [self.otherTabView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        //计算自身view的高度
        self.customHeight = cellHeight+cancelToTabView+self.otherTabView.height;
        
        if (cancelButtonTitle) {
            //cancel
            self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.cancelBtn.frame = CGRectMake(0, self.customHeight-cellHeight, selfWidth, cellHeight);
            self.cancelBtn.layer.cornerRadius = 5.0;
            [self.cancelBtn setTitleColor:[UIColor getColorWithHex:YellowText] forState:UIControlStateNormal];
            self.cancelBtn.backgroundColor = [UIColor whiteColor];
            [self.cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal
             ];
            [self.cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.cancelBtn];
        }
        
    }
    
    return self;
}

-(void)cancelBtnClick{
    [self dismissActionSheet];
}

//解决tableView分割线左边不到边的情况
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.otherButtonArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.titleHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag==self.tag) {
        if ([self.delegate respondsToSelector:@selector(customActionSheet:clickedButtonAtIndex:)])
        {
            [self.delegate customActionSheet:self clickedButtonAtIndex:indexPath.row];
            [self dismissActionSheet];
        }
    }
    
}

#pragma mark - UITableViewDatasource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return self.titleLabel;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.otherButtonArr.count>0) {
        cell.textLabel.text = self.otherButtonArr[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor getColorWithHex:YellowText];
    }
    
    return cell;
    
}

- (void)show
{   //获取第一响应视图视图
    //UIViewController *topVC = [self appRootViewController];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self.frame = CGRectMake(toView, SCREENHEIGHT+self.customHeight, selfWidth, self.customHeight);
    self.alpha=0;
    self.otherTabView.tag = self.tag;
    [window addSubview:self];
    
}

- (void)dismissActionSheet
{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    [self removeFromSuperview];
}

- (UIViewController *)appRootViewController
{
    
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


- (void)removeFromSuperview
{
    [self.backimageView removeFromSuperview];
    self.backimageView = nil;
    UIViewController *topVC = [self appRootViewController];
    CGRect afterFrame = CGRectMake(toView, topVC.view.height, selfWidth , self.customHeight);
    
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = afterFrame;
        self.alpha=0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}
//添加新视图时调用（在一个子视图将要被添加到另一个视图的时候发送此消息）
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    //     获取根控制器
    UIViewController *topVC = [self appRootViewController];
    
    if (!self.backimageView) {
        self.backimageView = [[UIView alloc] initWithFrame:topVC.view.bounds];
        self.backimageView.backgroundColor = [UIColor blackColor];
        self.backimageView.alpha = 0.4f;
        self.backimageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.backimageView addGestureRecognizer:tap];
    
    //    加载背景背景图,防止重复点击
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.backimageView];
    
    self.frame = CGRectMake(toView, SCREENHEIGHT+self.customHeight, selfWidth, self.customHeight);
    
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(toView, window.height - self.customHeight-10, selfWidth, self.customHeight);
        self.alpha=1;
    } completion:^(BOOL finished) {
    }];
    [super willMoveToSuperview:newSuperview];
}

-(void)tapClick{
    [self dismissActionSheet];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
