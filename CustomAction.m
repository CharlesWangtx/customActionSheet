//
//  CustomAction.m
//  ChmtechIOS
//
//  Created by taixiangwang on 15/9/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//
#define cellHeight              50
#define cancelToTabView         10
#define toView                  10
#define selfWidth               SCREENWIDTH-2*toView


#import "CustomAction.h"
#import "ActionCollectionViewCell.h"

@interface CustomAction ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) UITableView *otherTabView;
@property (nonatomic,strong) NSArray *otherButtonArr;

@property (nonatomic,strong) UICollectionView *otherCollectView;
@property (nonatomic,strong) NSArray *otherTitleCollectArr;
@property (nonatomic,strong) NSArray *otherImgsCollectArr;

@property (nonatomic,strong) UIView *backimageView;

@property (nonatomic,assign) CGFloat customHeight;
@property (nonatomic,assign) CGFloat titleHeight;

//是tableview 还是collectView
@property (nonatomic,assign) BOOL isTableView;

@end

@implementation CustomAction

//tableview
-(instancetype)initCustomWithTitle:(NSString *)title delegate:(id<CustomActionDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles{
    
    if (self = [super init]) {

        self.backgroundColor = [UIColor clearColor];
        self.otherButtonArr = [NSArray arrayWithArray:otherButtonTitles];
        self.delegate = delegate;
        self.isTableView = YES;
        
        if (title&&![title isEqualToString:@""]) {
            //动态计算title高度
            self.titleHeight = [NSString getTextHeightWithText:title andFont:[UIFont systemFontOfSize:15] andWidth:selfWidth]+30;
            
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, selfWidth-40, self.titleHeight-20)];
            self.titleLabel.font = [UIFont systemFontOfSize:15];
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.text = title;
            self.titleLabel.textColor = [UIColor getColorWithHex:CELLDETAILCOLOR];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.numberOfLines = 0;
            
            //创建中间的tableview
            CGFloat tabViewHeight = self.otherButtonArr.count*cellHeight+self.titleHeight;
            if (tabViewHeight>=SCREENHEIGHT*2./3) {
                tabViewHeight = SCREENHEIGHT*2./3;
            }
            self.otherTabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, selfWidth, tabViewHeight) style:UITableViewStylePlain];
            
        }
        else{
            self.titleHeight = 0;
            //创建中间的tableview
            CGFloat tabViewHeight = self.otherButtonArr.count*cellHeight+self.titleHeight;
            if (tabViewHeight>=SCREENHEIGHT*2./3) {
                tabViewHeight = SCREENHEIGHT*2./3;
            }
            self.otherTabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, selfWidth, tabViewHeight) style:UITableViewStylePlain];
            
        }
        
        self.otherTabView.alwaysBounceVertical = NO;
        self.otherTabView.backgroundColor = [UIColor whiteColor];
        self.otherTabView.layer.cornerRadius = 8.0;
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
            self.cancelBtn.layer.cornerRadius = 8.0;
            [self.cancelBtn setTitleColor:[UIColor getColorWithHex:YellowTextColor] forState:UIControlStateNormal];
            self.cancelBtn.backgroundColor = [UIColor whiteColor];
            [self.cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal
             ];
            self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [self.cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.cancelBtn];
        }
        
    }
    
    return self;
}

//collectview
- (instancetype)initCustomBottomWithTitle:(NSString *)title delegate:(id<CustomActionDelegate>)delegate otherButtonTitles:(NSArray *)otherButtonTitles otherBtnImgs:(NSArray *)otherBtnImgs{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.otherTitleCollectArr = [NSArray arrayWithArray:otherButtonTitles];
        self.otherImgsCollectArr = [NSArray arrayWithArray:otherBtnImgs];
        self.delegate = delegate;
        self.isTableView = NO;
        
        CGFloat itemWidth = SCREENWIDTH*(1.0/3)-5;
        CGFloat drawHeight = 0.0;
        if (otherButtonTitles.count%3!=0) {
            drawHeight  = otherButtonTitles.count/3+1;
        }
        else if(otherButtonTitles.count%3==0){
            drawHeight = otherButtonTitles.count/3;
        }
        
        if (title) {
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, SCREENWIDTH, 25)];
            self.titleLabel.font = [UIFont systemFontOfSize:13];
            self.titleLabel.text = title;
            self.titleLabel.textColor = [UIColor darkGrayColor];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            
            //创建中间的collectview
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.itemSize = CGSizeMake(itemWidth, itemWidth);
            layout.minimumInteritemSpacing = 1;
            layout.minimumLineSpacing = 1;
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.otherCollectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 10, SCREENWIDTH, (self.otherTitleCollectArr.count<3?1:self.otherTitleCollectArr.count/3)*drawHeight+30) collectionViewLayout:layout];
            
            self.titleHeight = 30;
        }
        else{
            //创建中间的collectview
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.itemSize = CGSizeMake(itemWidth, itemWidth);
            layout.minimumInteritemSpacing = 1;
            layout.minimumLineSpacing = 1;
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.otherCollectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 10, SCREENWIDTH, drawHeight*itemWidth) collectionViewLayout:layout];
            
            self.titleHeight = 0;
        }
        
        self.otherCollectView.alwaysBounceVertical = NO;
        self.otherCollectView.backgroundColor = [UIColor whiteColor];
        self.otherCollectView.delegate = self;
        self.otherCollectView.dataSource = self;
        [self addSubview:self.otherCollectView];
        
        [self.otherCollectView registerNib:[UINib nibWithNibName:@"ActionCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
        
        //计算自身view的高度
        self.customHeight = self.otherCollectView.height+20;
        
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
        }
        
        if (self.tabViewDidSelectBlock) {
            self.tabViewDidSelectBlock(indexPath.row);
        }
        
        [self dismissActionSheet];
    }
    
}

#pragma mark - UITableViewDatasource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]init];
    [headView addSubview:self.titleLabel];
    
    //横线
    UIImageView *lineImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.titleLabel.bottom+8, selfWidth, 1)];
    lineImgV.alpha = .3;
    lineImgV.backgroundColor = [UIColor getColorWithHex:CELLDETAILCOLOR];
    [headView addSubview:lineImgV];
    
    return headView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.otherButtonArr.count>0) {
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.text = self.otherButtonArr[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor getColorWithHex:YellowTextColor];
    }
    
    return cell;
    
}

#pragma mark - UICollectViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.tag==self.tag) {
        if ([self.delegate respondsToSelector:@selector(customActionSheet:clickedButtonAtIndex:)])
        {
            [self.delegate customActionSheet:self clickedButtonAtIndex:indexPath.row];
            [self dismissActionSheet];
        }
    }
    
}


#pragma mark - UICollectViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.otherTitleCollectArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ActionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imgV.image = [UIImage imageNamed:self.otherImgsCollectArr[indexPath.row]];
    cell.label.text = self.otherTitleCollectArr[indexPath.row];
    cell.label.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark - actionsheetShow
- (void)show
{
    //获取第一响应视图视图
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (self.isTableView) {
        self.frame = CGRectMake(toView, SCREENHEIGHT+self.customHeight, selfWidth, self.customHeight);
    }
    else{
        self.frame = CGRectMake(0, SCREENHEIGHT+self.customHeight, SCREENWIDTH, self.customHeight);
    }
    
    
    self.alpha=0;
    self.otherTabView.tag = self.tag;
    self.otherCollectView.tag = self.tag;
    
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
    CGRect afterFrame;
    if (self.isTableView) {
        afterFrame = CGRectMake(toView, topVC.view.height, selfWidth , self.customHeight);
    }
    else{
        afterFrame = CGRectMake(0, topVC.view.height, SCREENWIDTH , self.customHeight);
    }

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
    
    if (self.isTableView) {
        self.frame = CGRectMake(toView, SCREENHEIGHT+self.customHeight, selfWidth, self.customHeight);
    }
    else{
        self.frame = CGRectMake(0, SCREENHEIGHT+self.customHeight, SCREENWIDTH, self.customHeight);
    }
    
    //视图显示
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if (self.isTableView) {
           self.frame = CGRectMake(toView, window.height - self.customHeight-10, selfWidth, self.customHeight);
        }
        else{
            self.frame = CGRectMake(0, window.height - self.customHeight, SCREENWIDTH, self.customHeight);
        }
        
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
