# UIImageView-ZJRadius
全局高性能设置圆角图片分类, runtime, 异步剪裁


# 针对UIImageView圆角设置性能优化分类


```
原理: 
利用Runtime的Method Swizzle交换系统的setClipsToBounds与setImage方法 
若设置了layer.cornerRadius 且 clipsToBounds = YES, 则clipsToBounds不会设置为YES, 在设置image时会生成一个圆角的layer并遮盖UIImageView
```
 
 
 
```
使用方法:
1.导入工程.
2.需要用到本分类的UIImageView设置layer.cornerRadius属性(必须先设置!!)
3.设置clipsToBounds = YES.(layer.maskToBounds不需设置)
```

 
 
```
须知:
1.使用本分类须设置clipsToBounds 而不是layer.maskToBounds,
  所以若不想使用本分类的UIImageView设置layer.maskToBounds则不会有任何影响.
2.本分类兼容SDWebImage.
3.iOS9之后, png图片在UIImageView中设置圆角不会触发离屏渲染, 此分类可以解决其他情况
```

~~在UITableView、UICollectionView滑动中, 不断调用SDWebImage设置图片会导致图片闪烁(重复调用setter方法, 反复剪裁), 若频繁滑动的控件建议在设置图片时手动判断url有没有改变, 没有改变则不重复调用SDWebImage设置图片方法~~

#### 已解决!
