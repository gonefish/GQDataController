GQDataController
=================

GQDataController是一款符合MVVM模式的网络框架，通过混合AFNetworking和Mantle让你更方便的处理网络交互。

## 基本使用

GQDataController是一个抽象类，使用前需要先创建新的子类。每个子类表示一种接口交互。

首先，子类必须实现这个接口，并返回请求的接口字符串。

```objc
- (NSArray *)requestURLStrings;
```

通过初始化方法创建实例。

```objc
- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate;
```

### GQDataControllerDelegate委托方法

GQDataControllerDelegate定义了3个方法用于回调，当然你也可以选择Block风格的回调。

```objc
- (void)dataControllerWillStartLoading:(GQDataController *)controller;

- (void)dataControllerDidFinishLoading:(GQDataController *)controller;

- (void)dataController:(GQDataController *)controller didFailWithError:(NSError *)error;
```

### 接口请求

创建完实例后，你可以发起请求接口

不带参数的接口请求。

```objc
- (void)request;
```

带参数的接口请求

```objc
- (void)requestWithParams:(NSDictionary *)params;
```

Block风格

```objc
- (void)requestWithParams:(nullable NSDictionary *)params
                  success:(nullable GQRequestSuccessBlock)success
                  failure:(nullable GQRequestFailureBlock)failure;
```

### 其它配置

```objc
- (NSString *)requestMethod;
```

### 结果处理

检测返回的结果是否有效

```objc
- (BOOL)isValidWithObject:(id)object;
```

手动处理返回结果，object是由AFNetworking返回的JSON对象。

```objc
- (void)handleWithObject:(id)object;
```

## Mantle

GQDataController可以自动的将AFNetworking返回的结果转换成Mantle对象。在GQDataController中定义了mantleObject和mantleObjectList 2个实例属性。如果转换的JSON是字典，会将结果赋值到mantleObject；如果转换的JSON是数组，则会将结果赋值到mantleObjectList。

### 启用Mantle转换

mantleObject和mantleObjectList都有相对应的配置方法，你需要手动指定转换用的Class和JSON路径(可选)。

默认实现中mantleObjectListKeyPath和mantleListModelClass会返回mantleObjectKeyPath和mantleModelClass的值。

```objc
- (Class)mantleModelClass;

- (NSString *)mantleObjectKeyPath;

- (Class)mantleListModelClass;

- (NSString *)mantleObjectListKeyPath;
```

### 内置DataSource

GQDataController声现UITableViewDataSource和UICollectionViewDataSource，你可以快速的创建DataSource。

```objc
@property (nonatomic, copy) NSString *cellIdentifier;

@property (nonatomic, copy) GQTableViewCellConfigureBlock tableViewCellConfigureBlock;

@property (nonatomic, copy) GQCollectionViewCellConfigureBlock collectionViewCellConfigureBlock;
```

### 分页

GQPagination对象描述分页时的常用信息。

```objc
@property (nonatomic, strong, nullable) GQPagination *pagination;
```

以分页的方式请求

```objc
- (void)requestMore;
```

## 其它

### 接口重试

可以设置多个请求地址，方便在接口请求失败时，使用另外的地址继续请求。

```objc
- (NSArray *)requestURLStrings;
```

### 接口Stub

GQDataController也集成了OHHTTPStubs，允许你使用本地JSON文件来做为接口返回，该功能只在定义过DEBUG宏的条件下开启。

### 复制

GQDataController也实现NSCopying协议，你可以快速的复制当前的实例。

### 单例

```objc
+ (instancetype)sharedDataController;
```

这个子类都可以类方法来获取自己的单例。

## 例子

请参考Demo工程中的例子：

1. 基本使用
2. 使用Block风格的回调
3. 使用Mantle处理返回结果
4. DataSource
5. 分页
6. 接口的Stub


## 系统要求

支持iOS 7以上

第三库依赖：

* AFNetworking 2.6.3
* Mantle 1.5.6
* OHHTTPStubs 4.6.0

## 安装

### CocoaPods

```
pod 'GQDataController', '~> 0.2'
```


## FAQ

**是否支持XML的返回格式？**

当前只支持JSON格式。

**如何为接口添加公共参数？**

自定义AFHTTPRequestSerializer，然后在初始化方法中设置

```objc
self.requestOperationManager.requestSerializer
```

**如何自定义接口响应**

自定义AFJSONResponseSerializer，然后在初始化方法中设置

```objc
self.requestOperationManager.responseSerializer
```

你甚至可以自定义子类，用于将任意格式转换成JSON的适配器。

**是否需要创建自己的基类？**

总是继承自己的基类是最好的实践。你可以在基类里配置AFNetworking及其它自定义属性。

## LICENSE

See LICENSE
