# UIImageView UIView圆角与性能之间的研究与优化针对UIImageView圆角设置性能优化分类


### 设想:
```
找出直接设置圆角(maskToBounds/clipsToBounds)帧数下降的例子, 
然后利用Runtime的Method Swizzle交换系统的setClipsToBounds方法 
若设置了layer.cornerRadius 且 clipsToBounds = YES, 则clipsToBounds不会设置为YES, 
而是通过各种其他方法设置圆角, 例如:
1.生成一个圆形的CALayer作为UIImageView.layer.mask.
2.异步剪裁图片.
(以上方法均为网络上流传性能优化方法)

3.生成一个UIImageView, 把原来的图像画在上面.
4.生成一个CALayer, 把原来的图像画在上面.
(自己)
```
 
 
### 场景: 
 ```
在日历中每一个UICollectionCell增加一个UIImageView并设置圆角
 ```
 
![](http://osnabh9h1.bkt.clouddn.com/17-7-28/5433917.jpg)

### 实际:
```
图为直接设置cornerRadius和maskToBounds属性, 在如此多的圆角图片下,依然是60帧.
手机iPhone6, 系统为iOS10, 网上传的比较多的是iOS9以上png图片不会触发离屏渲染,
所以不会怎么影响性能, 但我换成jpg图片 依然是60帧.
但我还是尝试了一下上面的两种方法, 看是什么作用:
1.生成一个圆形的CALayer作为UIImageView.layer.mask:
帧数明显降低.

2.异步剪裁图片.
正常操作帧数没有异常, 快速滑动, 会在cell的重用上出问题, 帧数明显下降.

以上肉眼观察明显, 并不需要instrument监控.

```

### UIImageView 结论
```
在百分之九十九的情况下,
放心使用系统自己的maskToBounds/clipsToBounds与cornerRadius吧,
不会有任何性能问题, 
实际上圆角对于安卓都不是事,
iOS缺老生常谈,确实不应该啊.(基于项目不兼容iOS8了)

UIImageView确定了结果, 
但实际上圆角的设置远不是UIImageView,
怎么对UIView设置圆角并且保持较好的性能,
网上爬文也难有一个比较结论性的回答.
再测试一下直接对UIView直接设置圆角.
```

### 场景:
```
依然是日历, 每一个cell中有2个UILabel.
```
![](http://osnabh9h1.bkt.clouddn.com/17-7-28/437301.jpg)

### 实际:
```
这次就出问题了, 滑动帧数直接降到15左右

```
![](http://osnabh9h1.bkt.clouddn.com/17-7-28/98216107.jpg)

```
依然按照上面的思路进行优化, 交换方法为setClipsToBounds与layoutSubViews, 
在设置clipsToBounds = YES且layer.cornerRaius > 0的情况下,
layoutSubViews中进行优化:

1.生成一个圆形的CALayer作为UIImageView.layer.mask:
帧数明显更低了, 所以这种方法在网上流传简直是害人...平均帧数不及10
```
![](http://osnabh9h1.bkt.clouddn.com/17-7-28/10653283.jpg)


```
2.异步剪裁图片.
因为UIView本身并不是UIImage的容器, 所以不太容易直接放, 
新增一个UIImageView盖在上面, 在异步绘制出当前cell, 并放入.
结果喜人, 帧数提高到了60帧附近了.
```
![](http://osnabh9h1.bkt.clouddn.com/17-7-28/35305251.jpg)

```
这里又有之前的前辈教导的常识:CALayer比UIView更轻量, 
所以不需要响应交互的地方用CALayer可以大幅提高性能.
将UIImageView换为CALayer, 并将图片放入contents.
结果实际上并没有更好, 也许是帧数已经快到极限了.
```
![](http://osnabh9h1.bkt.clouddn.com/17-7-28/90589527.jpg)


### UIView 结论
```
依然是, 屏幕里圆角数量不多的情况下(15-), 不太需要想办法, 大胆用吧.
屏幕圆角非常多, 可以使用我写的这种方法, 但限制其实也挺多的,
背景色必须是纯色.
当然最好的方法肯定是UI直接把阴影与圆角剪裁给你, 直接用,
虽然会有图层混合运算, 但是其实对性能影响很微妙.

```

### https://github.com/syik/UIImageView-ZJRadius
