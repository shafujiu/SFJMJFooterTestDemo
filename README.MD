我们在使用 UITableView的时候，很多时候会用到MJRefresh 的下拉刷新，以及上拉加载。大概是在iOS 10之后，我们发现MJFooter配合 我们的tableView的 estimatedRowHeight的时候 并且通过insertRowsAtIndexPaths的方式去插入数据。很容易出现，看到footer 出现在一个位置，突然又滚动到底部。
iOS 11 之后，tableView的contentSize 计算猜测采用了新的方式。
```
// 第一步 如果设置了 预估高度的计算 跟实际通过cell 计算出来差很多。
self.tableView.estimatedRowHeight = 10;

// 第二步 如果在添加更多的时候采用
[tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];

```
出现这种情况 我们需要去探究一下MJRefresh的源码

解答思路： 

1. 首先我们找到 MJRefreshAutoFooter.m -> scrollViewContentSizeDidChange

MJ监控了 scrollView的ContentSize的变化 

2. 不难发现MJFooter 是通过scrollView的contentSize去改变footer的y值

```
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
    // 设置位置
    self.mj_y = self.scrollView.mj_contentH + self.ignoredScrollViewContentInsetBottom;
}
```

3. 猜测我们的tableView的contentSize 可能多次变化，第一次算出来正好是真正高度的上方（小于真实高度）


验证 

为我们上拉加载更多的tableView 添加相同的contentSize改变的通知，然后再作如上的设置后，开始滚动测试。

```
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    MJPerformSelectorLeakWarning(
        [self performSelector:NSSelectorFromString(self.method) withObject:nil];
                                 );
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@", change[@"new"]);
}
```

打印出来的结果没有让我们失望

```
2020-05-18 15:39:04.898112+0800 MJRefreshExample[22720:5813669] NSSize: {414, 1450}
2020-05-18 15:39:04.920224+0800 MJRefreshExample[22720:5813669] NSSize: {414, 4075}
2020-05-18 15:39:05.238028+0800 MJRefreshExample[22720:5813669] NSSize: {414, 4075}
```

出现上述描述的情况的时候 通常 会是因为有一次contentSize 完全是通过预估高度计算出来的 **1450**， 与最终的**4075** 差很多 出现1450 的时候设置一次footer 的y 正好看到屏幕中间的一个位置，然后在出现4075 的时候 就正好是我们需要的一个正确高度。

解决方案

```
self.tableView.estimatedRowHeight = 0;
// 经验证 预估高度为0的时候 似乎系统并不会用到该属性去计算scrollView的contentSize
```

或者 不对此属性作设置
