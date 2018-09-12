//
//  CALayer+LayerPause.m
//  ConmonUse
//
//  Created by jorgon on 27/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//
/*
 二.CALayer及时间模型
 我们都知道UIView是MVC中的View.UIView的职责在于界面的显示和界面事件的处理.每一个View的背后都有一个layer(可以通过view.layer进行访问),layer是用于界面显示的.CALayer属于QuartzCore框架,非常重要,但并没有想象中的那么好理解.我们通常操作的用于显示的Layer在Core Animation这层的概念中其实担当的是数据模型Model的角色,它并不直接做渲染的工作.关于Layer,之前从座标系的角度分析过,这次则侧重于它的时间系统.
 1.Layer的渲染架构
 Layer也和View一样存在着一个层级树状结构,称之为图层树(Layer Tree),直接创建的或者通过UIView获得的(view.layer)用于显示的图层树,称之为模型树(Model Tree),模型树的背后还存在两份图层树的拷贝,一个是呈现树(Presentation Tree),一个是渲染树(Render Tree). 呈现树可以通过普通layer(其实就是模型树)的layer.presentationLayer获得,而模型树则可以通过modelLayer属性获得(详情文档).模型树的属性在其被修改的时候就变成了新的值,这个是可以用代码直接操控的部分;呈现树的属性值和动画运行过程中界面上看到的是一致的.而渲染树是私有的,你无法访问到,渲染树是对呈现树的数据进行渲染,为了不阻塞主线程,渲染的过程是在单独的进程或线程中进行的,所以你会发现Animation的动画并不会阻塞主线程.
 
 2.事务管理
 CALayer的那些可用于动画的(Animatable)属性,称之为Animatable Properties,这里有一份详情的列表,罗列了所有的CALayer Animatable Properties. 如果一个Layer对象存在对应着的View,则称这个Layer是一个Root Layer,非Root Layer一般都是通过CALayer或其子类直接创建的.下面的subLayer就是一个典型的非Root Layer,它没有对应的View对象关联着.
 subLayer = [[CALayeralloc]init];
 subLayer.fra me=CGRectMake(0,0,300,300);
 subLayer.backgroundColor=[[UIColorredColor]CGColor];
 [self.view.layeraddSublayer:subLayer];
 所有的非Root Layer在设置Animatable Properties的时候都存在着隐式动画,默认的duration是0.25秒.
 subLayer.position=CGPointMake(300,400);
 像上面这段代码当下一个RunLoop开始的时候并不是直接将subLayer的position变成(300,400)的,而是有个移动的动画进行过渡完成的.
 任何Layer的animatable属性的设置都应该属于某个CA事务(CATransaction),事务的作用是为了保证多个animatable属性的变化同时进行,不管是同一个layer还是不同的layer之间的.CATransaction也分两类,显式的和隐式的,当在某次RunLoop中设置一个animatable属性的时候,如果发现当前没有事务,则会自动创建一个CA事务,在线程的下个RunLoop开始时自动commit这个事务,如果在没有RunLoop的地方设置layer的animatable属性,则必须使用显式的事务.
 显式事务的使用如下：
 [CATransactionbegin];...[CATransactioncommit];
 事务可以嵌套.当事务嵌套时候,只有当最外层的事务commit了之后,整个动画才开始.
 可以通过CATransaction来设置一个事务级别的动画属性,覆盖隐式动画的相关属性,比如覆盖隐式动画的duration,timingFunction.如果是显式动画没有设置duration或者timingFunction,那么CA事务设置的这些参数也会对这个显式动画起作用.
 还可以设置completionBlock,当当前CATransaction的所有动画执行结束后, completionBlock会被调用.
 3.时间系统
 ******* CALayer实现了CAMediaTiming协议. CALayer通过CAMediaTiming协议实现了一个有层级关系的时间系统.除了CALayer,CAAnimation也采纳了此协议,用来实现动画的时间系统.
 在CA中,有一个Absolute Time(绝对时间)的概念,可以通过CACurrentMediaTime()获得,其实这个绝对时间就是将mach_absolute_time()转换成秒后的值.这个时间和系统的uptime有关,系统重启后CACurrentMediaTime()会被重置.
 就和座标存在相对座标一样,不同的实现了CAMediaTiming协议的存在层级关系的对象也存在相对时间,经常需要进行时间的转换,CALayer提供了两个时间转换的方法:
 -(CFTimeInterval)convertTime:(CFTimeInterval)tfromLayer:(CALayer)l;
 -(CFTimeInterval)convertTime:(CFTimeInterval)ttoLayer:(CALayer)l;
 现在来重点研究CAMediaTiming协议中几个重要的属性.
 beginTime
 无论是图层还是动画,都有一个时间线Timeline的概念,他们的beginTime是相对于父级对象的开始时间. 虽然苹果的文档中没有指明,但是通过代码测试可以发现,默认情况下所有的CALayer图层的时间线都是一致的,他们的beginTime都是0,绝对时间转换到当前Layer中的时间大小就是绝对时间的大小.所以对于图层而言,虽然创建有先后,但是他们的时间线都是一致的(只要不主动去修改某个图层的beginTime),所以我们可以想象成所有的图层默认都是从系统重启后开始了他们的时间线的计时.
 但是动画的时间线的情况就不同了,当一个动画创建好,被加入到某个Layer的时候,会先被拷贝一份出来用于加入当前的图层,在CA事务被提交的时候,如果图层中的动画的beginTime为0,则beginTime会被设定为当前图层的当前时间,使得动画立即开始.如果你想某个直接加入图层的动画稍后执行,可以通过手动设置这个动画的beginTime,但需要注意的是这个beginTime需要为 CACurrentMediaTime()+延迟的秒数,因为beginTime是指其父级对象的时间线上的某个时间,这个时候动画的父级对象为加入的这个图层,图层当前的时间其实为[layer convertTime:CACurrentMediaTime() fromLayer:nil],其实就等于CACurrentMediaTime(),那么再在这个layer的时间线上往后延迟一定的秒数便得到上面的那个结果.
 timeOffset
 这个timeOffset可能是这几个属性中比较难理解的一个,官方的文档也没有讲的很清楚. local time也分成两种一种是active local time 一种是basic local time.
 timeOffset则是active local time的偏移量.
 你将一个动画看作一个环,timeOffset改变的其实是动画在环内的起点,比如一个duration为5秒的动画,将timeOffset设置为2(或者7,模5为2),那么动画的运行则是从原来的2秒开始到5秒,接着再0秒到2秒,完成一次动画.
 speed
 speed属性用于设置当前对象的时间流相对于父级对象时间流的流逝速度,比如一个动画beginTime是0,但是speed是2,那么这个动画的1秒处相当于父级对象时间流中的2秒处. speed越大则说明时间流逝速度越快,那动画也就越快.比如一个speed为2的layer其所有的父辈的speed都是1,它有一个subLayer,speed也为2,那么一个8秒的动画在这个运行于这个subLayer只需2秒(8 / (2 * 2)).所以speed有叠加的效果.
 fillMode
 fillMode的作用就是决定当前对象过了非active时间段的行为. 比如动画开始之前,动画结束之后。如果是一个动画CAAnimation,则需要将其removedOnCompletion设置为NO,要不然fillMode不起作用. 下面来讲各个fillMode的意义
 kCAFillModeRemoved这个是默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
 kCAFillModeForwards当动画结束后,layer会一直保持着动画最后的状态
 kCAFillModeBackwards这个和kCAFillModeForwards是相对的,就是在动画开始前,你只要将动画加入了一个layer,layer便立即进入动画的初始状态并等待动画开始.你可以这样设定测试代码,将一个动画加入一个layer的时候延迟5秒执行.然后就会发现在动画没有开始的时候,只要动画被加入了layer,layer便处于动画初始状态
 kCAFillModeBoth理解了上面两个,这个就很好理解了,这个其实就是上面两个的合成.动画加入后开始之前,layer便处于动画初始状态,动画结束后layer保持动画最后的状态.
 其他的一些参数都是比较容易理解的.
 
 作者：wzf_taker
 链接：https://www.jianshu.com/p/d79b71f5bddd
 來源：简书
 简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
 */
#import "CALayer+LayerPause.h"

@implementation CALayer (LayerPause)
- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval curTime =CACurrentMediaTime();
    CFTimeInterval pauseTime = [layer convertTime:curTime fromLayer:nil];
    layer.timeOffset= pauseTime;
    layer.speed=0;
}
- (void)resumeLayer:(CALayer*) layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed=1.0;
    layer.timeOffset=0.0;
    layer.beginTime=0.0;
    CFTimeInterval timeSincePause =
    [layer convertTime:CACurrentMediaTime()fromLayer:nil] - pausedTime;
    layer.beginTime= timeSincePause;
}
@end
