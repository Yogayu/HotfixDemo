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

## 安全

1. 问题：

	- 网络传输过程中被中间人篡改 
	- 本地脚本文件被解包获取

2. [部署安全策略](http://blog.cnbang.net/tech/2879/) 

	- 传输安全： 对称加密、HTTPS、RSA 校验 
	- 执行安全：灰度、监控、回退


JSPatch可以通过写JS脚本文件，新增修改OC中的属性，方法，类等。JSPatch，是基于Runtime的特性，通过写JS去动态的修改代码。也就是说，JS能做到的事情，直接写OC都能做到。这样的话，怎么存在着只有JSPatch能做而OC不能做的恶意攻击呢？或者说需是思考JS脚本独有的攻击方式吗？

其实，如果反编译之后，只能知道部分的代码内容，部分类的名称，无法知道详细。而能看见所有的JS文件代码，那么就会存在风险。也就是说，JS文件提供了一个暴露的可以修改类的入口。

<!--如果能在JS文件方法的过程中截获并修改，那么将有很大的危险。但是，这总情况是很容易预防的。一种方式是加密，一种方式是校验。使用对称加密容易被破解，使用非对称加密进行校验是一种较好的方式。-->

## 部署以及使用

1. 添加依赖
	
		platform :ios, '7.0'
		pod 'JSPatch'
2. 添加JavaScriptCore.framework
3. 编写JS代码，在AppDelegate中下载执行。

4. 使用JPLoader
	
	在didFinishLaunchingWithOptions中：
	
	运行：
	
		[JPLoader runPatch];
			
	本地调试运行（默认文件名为main.js）：
		
		// Local test
		[JPLoader runTestScriptInBundle];
		
		
	
具体JS编写方式见[JSPatch文档](https://github.com/bang590/JSPatch/wiki/JSPatch-%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95)。

---

> **问题：**

- 如何确定在didFinishLaunchingWithOptions、applicationDidBecomeActive中调用的顺序？即何时下载、何时更新更合适？更新的频率设为多少最合适？
	在didFinishLaunchingWithOptions中下载执行。
- 是否封装为一个Manager更好？如何封装？是。
- 目前有实现奔溃监控吗？灰度机制如何实现？服务端实现。
- 是否需要及时撤回脚本？不需要。
- Pod中无法修改？思考中。

## 辅助工具

- [自动补全插件](https://github.com/bang590/JSPatchX)
- [OC自动转JS](https://github.com/bang590/JSPatchConvertor)
- [JPLoader](https://github.com/bang590/JSPatch/wiki/JSPatch-Loader-%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3)


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


Thanks for reading.

---

