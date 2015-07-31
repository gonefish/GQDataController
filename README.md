GQDataController
=================

GQDataController是一个抽象类，一个子类对应一个具体接口。

### 使用

不带参数的接口请求。

```objc
- (void)request;
```

带参数的接口请求

```objc
- (void)requestWithParams:(NSDictionary *)params;
```

### 配置

接口的HTTP Method

```objc
- (NSString *)requestMethod;
```

接口的地址

```objc
- (NSArray *)requestURLStrings;
```

### 集成Mantle

这个方法返回用于序列化的Mantle类

```objc
- (Class)mantleModelClass;
```

在默认的转换过程中，如果返回的是Dictionary，会将整个Dictionary与Mantle进行转换。

通过实现mantleObjectKeyPath方法，用于指定该Dictionary中的某一个键值与Mantle进行转换，基于KVC的valueForKeyPath:方法。

```objc
- (NSString *)mantleObjectKeyPath;
```

### 请求重试

可以设置多个请求地址，方便在接口请求失败时，使用另外的地址继续请求。

```objc
- (NSArray *)requestURLStrings;
```

### 单例

```objc
+ (instancetype)sharedDataController;
```

这个子类都可以类方法来获取自己的单例。

### 绑定

### 委托方法

