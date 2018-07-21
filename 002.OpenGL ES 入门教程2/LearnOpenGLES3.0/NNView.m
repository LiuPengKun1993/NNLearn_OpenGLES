//
//  NNView.m
//  LearnOpenGLES3.0
//
//  Created by liupengkun on 2018/7/20.
//  Copyright © 2018年 以梦为马. All rights reserved.
//

#import "NNView.h"
#import <OpenGLES/ES3/gl.h>

@interface NNView () {
    EAGLContext *context;
}

@end

@implementation NNView

/** 每一个 UIView 都是寄宿在一个 CALayer 的示例上。这个图层是由视图自动创建和管理的，那我们可以用别的图层类型替代它么？一旦被创建，我们就无法代替这个图层了。但是如果我们继承了 UIView，那我们就可以重写 +layerClass 方法使得在创建的时候能返回一个不同的图层子类。UIView 会在初始化的时候调用 +layerClass 方法，然后用它的返回类型来创建宿主图层 */
/** 官方解释: default is [CALayer class]. Used when creating the underlying layer for the view. */
+ (Class)layerClass {
    // CAEAGLLayer 是苹果专门为 OpenGL ES 准备的一个图层类，它用于分配渲染缓冲区的存储空间
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self helloOpenGLES];
    }
    return self;
}

- (void)helloOpenGLES {
    
    // 配置OpenGL ES上下文
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!context) {
        NSLog(@"创建 context 失败");
        return;
    }
    
    // 设置当前上下文环境并告知 EAGLContext，即该线程中的后续 OpenGL ES 调用将与该上下文环境绑定。若不绑定，则下面的 GL 调用都返回无效值。
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"setCurrentContext 失败");
        return;
    }
    
    // 打印厂商信息
    NSLog(@"厂家 = %s\n", glGetString(GL_VENDOR));
    NSLog(@"渲染器 = %s\n", glGetString(GL_RENDERER));
    NSLog(@"ES版本 = %s\n", glGetString(GL_VERSION));
    NSLog(@"拓展功能 =>\n%s\n", glGetString(GL_EXTENSIONS));
    
    // CAEAGLLayer 是苹果专门为 OpenGL ES 准备的一个图层类，它用于分配渲染缓冲区的存储空间
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.contentsScale = [UIScreen mainScreen].scale;
    
    // 配置渲染缓冲区Render Buffer
    // 渲染缓冲区类似一个平面，用于保存绘制内容，并使用某种数据类型加以填充，比如颜色值。我们在此创建的是颜色缓冲区，用以保存所绘制的颜色信息，缓冲区大小由CAEAGLLayer的bounds中size指定，这在处理屏幕旋转时是个非常重要的条件。
    // OpenGL ES 有 Frame buffer、Render buffer、Data buffer等类型的缓冲区，它们的作用各不相同
    GLuint renderbuffer[1];
    glGenRenderbuffers((sizeof(renderbuffer)/sizeof(renderbuffer[0])), renderbuffer);
    // 绑定渲染缓冲区
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer[0]);
    // 存储空间的分配操作
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // 创建帧缓冲区 Frame Buffer 并配置渲染、深度等缓冲区
    // 帧缓冲区由多个render buffer组成，在此只绑定一个渲染缓冲区，即是把颜色缓冲区附着到帧缓冲区中。
    // Frame Buffer 是帧缓冲对象，它是一个容器，但是自身不能用于渲染，需要与一些可渲染的缓冲区绑定在一起，像纹理或者渲染缓冲区。
    /**
     Frame Buffer有什么优点？
     
     允许我们把渲染从窗口的帧缓冲区转移到离屏帧缓冲区，即离屏渲染。
     
     1.Frame BufferObject(FBO) 并不受窗口大小的限制。
     2.纹理可以连接到 FBO，允许直接渲染到纹理，不需要显示 glCopyTexImage。
     3.FBO 可以包含许多颜色缓冲区，可以同时从一个片段着色器写入。
     */
    GLuint framebuffer[1];
    glGenFramebuffers(sizeof(framebuffer)/sizeof(framebuffer[0]), framebuffer);
    // 绑定帧缓冲区
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer[0]);
    // 将渲染缓冲区配置成帧缓冲区的颜色附着（Attachment）(将颜色数据放入帧缓冲区指定的位置让别人看)
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer[0]);
    
    // 配置缓冲区清除颜色
    glClearColor(1.0, 0, 1.0, 1.0);
    // 设置屏幕颜色（清除渲染缓冲区）
    glClear(GL_COLOR_BUFFER_BIT);
    // 交换前后端帧缓冲区
    // iOS系统维护着两个重要的帧缓冲区，当前屏幕使用的是前端帧缓冲区。然而，刚才我们的操作都在后端帧缓冲区执行，若直接写在前端帧缓冲区，那么没完成的绘制也会显示在屏幕上，而屏幕是逐行扫描刷新的，显然这个行为会给用户造成错觉，比如逐行绘制图片。所以，在后端帧缓冲区操作完成后，我们需要通知系统，让其交换前后端帧缓冲区，用户才能看到前面的操作。
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

/** 清理操作, 结束当前上下文 */
- (void)dealloc {
    if ([EAGLContext currentContext] == context) {
        EAGLContext.currentContext = nil;
    }
}

/** 步骤:
 1. 若继承UIView子类，则需覆盖+layerClass
 2. 配置EAGLContext。若使用GLKViewController，应配置GLKView的context属性为新生成的Context。
 3. 配置渲染缓冲区Render Buffer
 4. 创建帧缓冲区Frame Buffer并配置渲染、深度等缓冲区
 5. 设置视口glViewport
 6. 清空缓冲区glClear(指定缓冲区)
 7. 绘制操作
 8. 通知EAGLContext将渲染缓冲区内容发送至屏幕
 */

@end

