# Hot Fix

> Hot fix Demo for iOS.

[TOC]


## 需求

- 有哪一些热修复方案？各自的优缺点是什么
- 选择哪一种热修复方案？为什么？
- 是否可保障安全性？
- 如何部署和使用？

## 方案

国内流行的有JSPatch和WaxPatch，国外相应的服务有Rollout和Apptimize，一共四种。

1. [JSPatch](https://github.com/bang590/JSPatch/wiki/JSPatch-%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95)
	
	JSPatch bridge Objective-C and Javascript using the Objective-C runtime. You can call any Objective-C class and method in JavaScript by just including a small engine. JSPatch is generally use for hotfix iOS App. 
- [WaxPatch](https://github.com/alibaba/wax) 
	
	Wax is a framework that lets you write native iPhone apps in Lua. It bridges Objective-C and Lua using the Objective-C runtime.  
- [Rollout](https://rollout.io/) 
	Rollout’s revolutionary SDK lets you react to production issues or modify your app in real time. 
- [Apptimize](http://apptimize.com/blog/2014/04/hide-bugs-without-app-store/) 

四种方案中，Rollout和Apptimize都是国外闭源的服务，因为我们的需求是采用其核心技术，使用自己的后端，不适合，所以对比JSPatch和WaxPatch进行选择。

### JSPatch与WaxParchWax对比
**基本：**

| 名称 | 语言 | 大小 | 使用率 | 活跃度 | 文档 | 工具 | Swift | 支持版本 |
| --- | --- | --- | --- |  --- | --- | --- | --- | --- |
| JSPatch | JavaScript 使用广泛 | 小巧 <br> 使用内置库 | [高](http://using.jspatch.org/) | 高<br> 8天前更新 | 中英文 | 1.自动补全插件<br>2.OC->JS工具 | 有条件使用 继承NSObject<br>dynamic修饰 | iOS 7+ |
| WaxPatch | Lua 简洁快速 | 较大 引入库WAX.Framwork | 中 | 中 五个月前更新 | 英文 | 无 | 同上 | iOS 6+ |

**优缺点：**

| 名称 | 优点 | 缺点 | 
| --- | --- | --- | 
| [JSPatch](https://github.com/bang590/JSPatch/wiki/JSPatch-%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95) | <br>1. 更小巧 <br>3\. 更符合Apple规范 <br>5\. [使用广泛](http://using.jspatch.org/)<br>6\. 工具便捷 | 1.不支持iOS 6 | 
| [WaxPatch](https://github.com/alibaba/Wax) | 1\. 支持iOS 6 <br> 2\. Lua脚本简单快速 | 1\. 相对较大 <br> |  

综合来看，选择JSPatch最好。

相对WaxPatch，JSPatch采用的是JS语言比Lua使用更为广泛，提高的工具可以提高效率；更符合Apple的规则；因为使用系统内置JavaScriptCore.framework不用另外引入脚本引擎，所以小巧；缺点是不支持iOS 6，但豆瓣FM iOS客户端最低支持iOS 7，所以没有影响；另外JSPatch比WaxPatch的使用更广泛，维护更活跃。

## 安全性

1. 问题：

	- 网络传输过程中被中间人篡改 
	- 本地脚本文件被解包获取

2. [部署安全策略](http://blog.cnbang.net/tech/2879/) 

	- 传输安全： 对称加密、HTTPS、RSA 校验 
	- 执行安全：灰度、监控、回退

## 如何使用？

1. 添加依赖

		pod init
	
		platform :ios, '7.0'
		pod 'JSPatch'
		
		pod install

2. 添加JavaScriptCore.framework

### Simple Demo

didFinishLaunchingWithOptions启用脚本：

	[JPEngine startEngine];
    
    // exec js file from local
     NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
     NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    
     [JPEngine evaluateScript:script];
     
    // exec js file from network
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://7xle3b.com1.z0.glb.clouddn.com/YXYDemo.js"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *script_online = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [JPEngine evaluateScript:script_online];
        NSLog(@"Run the script from internet.");
    }];

编写JS文件，导入所需头文件：

	require('YXYViewController,UIColor');
ViewController源代码：
	
	#import "ViewController.h"
	#import "YXYViewController.h"
	#import "JPEngine.h"
	
	@interface ViewController ()
	
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    [self chooseTheColor];
	}
	
	- (IBAction)pushJPTableViewVC:(id)sender {
	}
	
	- (void)chooseTheColor {
	}
	
	@end

通过JS写方法：

	defineClass('ViewController', {

    pushJPTableViewVC: function(sender) {
        var tableViewCtrl = JPTableViewController.alloc().init()
        self.navigationController().pushViewController_animated(tableViewCtrl, YES)
        console.log("did touch hanleBtn");
    },
            
    chooseTheColor: function() {
        var isNight = false;
            
        if (isNight == false) {
            self.view().setBackgroundColor(UIColor.grayColor());
        } else {
            self.view().setBackgroundColor(UIColor.whiteColor());
        }
    },
	});

通过JS写一个新的TableViewController：
	
	defineClass('JPTableViewController : UITableViewController <UIAlertViewDelegate>', ['data'], {
	  dataSource: function() {
	    var data = self.data();
	    if (data) return data;
	    var data = [];
	    for (var i = 0; i < 20; i ++) {
	      data.push("cell No." + i + " test form local.");
	    }
	    self.setData(data)
	    return data;
	  },
	  numberOfSectionsInTableView: function(tableView) {
	    return 1;
	  },
	  tableView_numberOfRowsInSection: function(tableView, section) {
	    return self.dataSource().length;
	  },
	  tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
	    var cell = tableView.dequeueReusableCellWithIdentifier("cell") 
	    if (!cell) {
	      cell = require('UITableViewCell').alloc().initWithStyle_reuseIdentifier(0, "cell")
	    }
	    cell.textLabel().setText(self.dataSource()[indexPath.row()])
	    return cell
	  },
	  tableView_heightForRowAtIndexPath: function(tableView, indexPath) {
	    return 60
	  },
	  tableView_didSelectRowAtIndexPath: function(tableView, indexPath) {
	     var alertView = require('UIAlertView').alloc().initWithTitle_message_delegate_cancelButtonTitle_otherButtonTitles("Alert",self.dataSource()[indexPath.row()], self, "OK",  null);
	     alertView.show()
	  },
	  alertView_willDismissWithButtonIndex: function(alertView, idx) {
	    console.log('click btn ' + alertView.buttonTitleAtIndex(idx).toJS())
	  }
	})


## 辅助工具

- [自动补全插件](https://github.com/bang590/JSPatchX)
- [OC自动转JS](https://github.com/bang590/JSPatchConvertor)
- [JPLoader](https://github.com/bang590/JSPatch/tree/master/Loader)



# 安全需求

JSPatch可以通过写JS脚本文件，新增修改OC中的属性，方法，类等。
热修复时，JS能做到的事情，OC都能做到。

JSPatch，是基于Runtime的特性，通过写JS去动态的修改代码。也就是说，JS能做到的事情，直接写OC都能做到。这样的话，怎么存在着只有JSPatch能做而OC不能做的恶意攻击呢？或者说需是思考JS脚本独有的攻击方式吗？

如果反编译之后，只能知道部分的代码内容，部分类的名称，无法知道详细。而能看见所有的JS文件，那么就会存在风险。也就是说，JS文件提供了一个暴露的可以修改类的入口。

如果能在JS文件方法的过程中截获并修改，那么将有很大的危险。但是，这总情况是很容易预防的。一种方式是加密，一种方式是校验。使用非对称加密容易被破解，使用对称加密进行校验是一种较好的方式。

## [JSPatch文档概要](https://github.com/bang590/JSPatch/wiki/JSPatch-%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95)

1. require
	引用所需类
		
		require('className','className2')
		require('UIView').alloc().init()
		
2. 调用OC方法
	
   > A class method is a method that operates on class objects rather than instances of the class.
 
	Swift: Type methods are similar to class methods in Objective-C.
   			
		class SomeClass {
		    class func someTypeMethod() {
		        // type method implementation goes here
		    }
		}
		SomeClass.someTypeMethod()
	
	区别：Swift中可以对class、structures和enumerations定义类型方法，但OC中只能对类定义类方法。
 
   调用类方法
  
   		var redColor = UIColor.redColor();
   		
   调用实例方法
   	
   		var view = UIView.alloc().init();
		view.setNeedsLayout();
	
  参数传递
   Property
   方法名转换
   
3. defineClass
      API
   
   	defineClass(classDeclaration, [properties,] instanceMethods, classMethods)
	
		@param classDeclaration: 字符串，类名/父类名和Protocol
		@param properties: 新增property，字符串数组，可省略
		@param instanceMethods: 要添加或覆盖的实例方法
		@param classMethods: 要添加或覆盖的类方法
   
   覆盖方法
   覆盖类方法
   覆盖 Category 方法
   Super
   	
   		self.super() 
   	
   Property
     	 获取/修改 OC 定义的 Property
     	 动态新增 Property
   私有成员变量
   添加新方法
   Protocol
   
4. 特殊类型
   Struct
   Selector
   nil
5. NSArray / NSString / NSDictionary
6. Block
   block传递
   block 里使用 self 变量
   限制
7. __weak / __strong
8. GCD
9. 传递 id* 参数
10. 常量、枚举、宏、全局变量
   常量/枚举
   宏
   全局变量
11. Swift
12. 加载动态库
13. 调试




## Reference

1. 调研对比

	-  [JSPatch解决方案，会出现的安全问题 ](http://www.securityweek.com/ios-app-patching-solutions-introduce-security-risks-fireeye)
	- [HOT OR NOT? THE BENEFITS AND RISKS OF IOS REMOTE HOT PATCHING](https://www.fireeye.com/blog/threat-research/2016/01/hot_or_not_the_bene.html)
	- [ROLLOUT OR NOT: THE BENEFITS AND RISKS OF IOS REMOTE HOT PATCHING](https://www.fireeye.com/blog/threat-research/2016/04/rollout_or_not_the.html)
	- [对于上诉文章中安全问题作者的回应](http://blog.cnbang.net/internet/2990/)
	- [iOS Apps JSPatch Hack](http://thehackernews.com/2016/01/ios-apps-jspatch-hack.html)
	- [热修复讨论](http://blog.oneapm.com/apm-tech/591.html)
	- [Weex & ReactNative & JSPatch](http://awhisper.github.io/2016/07/22/Weex-ReactNative-JSPatch/)
	- [iOS平台Hotfix框架](http://philonpang.github.io/blog/2015/06/26/jspatchxue-xi-yi-ji-iosping-tai-hotfixzai-xian-bu-ding-guan-li-fang-an-shi-xian/)
	- [weex&ReactNative对比](https://zhuanlan.zhihu.com/p/21677103)
	- [Weex & ReactNative & JSPatch](http://awhisper.github.io/2016/07/22/Weex-ReactNative-JSPatch/)
	- [与其他产品相比，JSPatch 的最大优势是什么？]( http://www.wmyouxi.com/a/57298.html#ixzz4G2nZYpzb)
	- [滴滴iOS客户端的架构演变之路](http://www.infoq.com/cn/news/2016/03/lixianhui-interview)

2. 使用

	- [JSPacth Wiki](https://github.com/bang590/JSPatch/wiki)
	- [iOS解决方案JSPatch](http://blog.methodname.com/jspatchde-shi-yong-xue-xi-guo-cheng/)
	- [JSPatch使用小记](http://www.cnblogs.com/dsxniubility/p/5080875.html)
	- [JSPatch总结](http://albert43.net/2015/07/12/JSPatch%E6%80%BB%E7%BB%93/)


