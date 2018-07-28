//
//  NNView.m
//  NNLearnOpenGLES06
//
//  Created by 刘朋坤 on 2018/7/28.
//  Copyright © 2018年 刘朋坤. All rights reserved.
//

#import "NNView.h"
#import <GLKit/GLKit.h>

@interface NNView() {
    GLKBaseEffect *effect;
    EAGLContext *context;
}

@end

@implementation NNView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self creatOpenGLES];
    }
    return self;
}

- (void)creatOpenGLES {
    [self configure];
    [self createEAGContext];
    [self createFramebuffer];
    [self createColorRenderbuffer];
    [self clear];
    [self createTriangleVertices];
    [self createColorbuffer];
    [self showRenderbuffer];
}

/** 配置layer */
- (void)configure {
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    // 提高渲染质量 但会消耗内存
    layer.opaque = true;
    layer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(false), kEAGLColorFormatRGBA8 : @(true)};
    effect = [[GLKBaseEffect alloc] init];
}

/** 创建一个EAGLContext对象 对象管理openGL加载到GPU的内容 */
- (void)createEAGContext {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
}

/** 创建一个帧缓存对象 */
- (void)createFramebuffer {
    GLuint framebuffer;
    // 为帧缓存申请一个内存标示，唯一的 1.代表一个帧缓存
    glGenFramebuffers(1, &framebuffer);
    // 把这个内存标示绑定到帧缓存上
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
}

/** 创建颜色渲染缓存 */
- (void)createColorRenderbuffer {
    GLuint colorFramebuffer;
    // 申请内存标示
    glGenRenderbuffers(1, &colorFramebuffer);
    // 绑定
    glBindRenderbuffer(GL_RENDERBUFFER, colorFramebuffer);
    // 设置帧缓存的颜色渲染缓存地址
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    // 开辟内存空间
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorFramebuffer);
}

/** 清除屏幕 */
- (void)clear {
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (GLint)drawableWidth {
    GLint width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}

- (GLint)drawableHeight {
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return height;
}

/** 绘制三角型顶点 */
- (void)createTriangleVertices {
    [effect prepareToDraw];
    GLuint positionbuffer;
    glGenBuffers(1, &positionbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, positionbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, NULL);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

/** 创建顶点颜色渲染缓冲区 */
- (void)createColorbuffer {
    [effect prepareToDraw];
    GLuint colorbuffer;
    // 申请内存标示
    glGenBuffers(1, &colorbuffer);
    // 绑定
    glBindBuffer(GL_ARRAY_BUFFER, colorbuffer);
    // 将颜色数据加入gpu的内存中
    glBufferData(GL_ARRAY_BUFFER, sizeof(colors), colors, GL_STATIC_DRAW);
    
    // 启动绘制颜色命令
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    // 设置指针
    // glVertexAttribPointer(<#GLuint indx#>, <#GLint size#>, <#GLenum type#>, <#GLboolean normalized#>, <#GLsizei stride#>, <#const GLvoid *ptr#>)
    // <#GLuint indx#> 指示绑定的缓存包含的是顶点位置的信息
    // <#GLint size#> 顶点数量
    // <#GLenum type#> 数据类型
    // <#GLboolean normalized#> 告诉opengl 小数点固定数据是否可以被改变
    // <#GLsizei stride#> 步幅 指定每个顶点保存需要多少个字节
    // <#const GLvoid *ptr#> 告诉opengl 可以从绑定数据的开始位置访问数据
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    
    // 绘图
    // glDrawArrays(<#GLenum mode#>, <#GLint first#>, <#GLsizei count#>)
    // <#GLenum mode#> 告诉opengl 怎么处理顶点缓存数据
    // <#GLint first#> 设置绘制第一个顶点的位置
    // <#GLsizei count#> 绘制顶点的数量
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

/** 将渲染缓存中的内容呈现到视图中去 */
- (void)showRenderbuffer {
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

GLfloat vertices [6] = {-1, 1, // 左上
    -1, -1, // 左下
    1, -1}; // 右下

GLfloat colors[9] = {1, 0, 0,  // 左上
    0, 0, 1,  // 左下
    0, 1, 0}; // 右下

@end
