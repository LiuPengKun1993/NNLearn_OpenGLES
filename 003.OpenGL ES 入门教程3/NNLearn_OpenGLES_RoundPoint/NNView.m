//
//  NNView.m
//  NNLearn_OpenGLES_RoundPoint
//
//  Created by liupengkun on 2018/7/21.
//  Copyright © 2018年 以梦为马. All rights reserved.
//

#import "NNView.h"
#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#define kDrawRoundPoint 1

@interface NNView() {
    CAEAGLLayer *glLayer;
    EAGLContext *context;
}

@end

@implementation NNView

// 一开始写成了这样🤣
//+ (Class)class {
//    return [CAEAGLLayer class];
//}

/** 每一个 UIView 都是寄宿在一个 CALayer 的示例上。这个图层是由视图自动创建和管理的，那我们可以用别的图层类型替代它么？一旦被创建，我们就无法代替这个图层了。但是如果我们继承了 UIView，那我们就可以重写 +layerClass 方法使得在创建的时候能返回一个不同的图层子类。UIView 会在初始化的时候调用 +layerClass 方法，然后用它的返回类型来创建宿主图层 */
/** 官方解释: default is [CALayer class]. Used when creating the underlying layer for the view. */
+ (Class)layerClass {
    // CAEAGLLayer 是苹果专门为 OpenGL ES 准备的一个图层类，它用于分配渲染缓冲区的存储空间
    return [CAEAGLLayer class];
}

/** Michael-Lfx(https://github.com/Michael-Lfx) 大神的代码里用的是 layoutSubviews 方法, 但 layoutSubviews 方法会走多次, 因此我这里用了 initWithFrame 方法, 不知道有没有什么坑 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // CAEAGLLayer 是苹果专门为 OpenGL ES 准备的一个图层类，它用于分配渲染缓冲区的存储空间
        glLayer = (CAEAGLLayer *)self.layer;
        glLayer.contentsScale = [UIScreen mainScreen].scale;
        
        // 配置OpenGL ES上下文
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:context];
        
        // 配置渲染缓冲区Render Buffer
        // 渲染缓冲区类似一个平面，用于保存绘制内容，并使用某种数据类型加以填充，比如颜色值。我们在此创建的是颜色缓冲区，用以保存所绘制的颜色信息，缓冲区大小由CAEAGLLayer的bounds中size指定，这在处理屏幕旋转时是个非常重要的条件。
        // OpenGL ES 有 Frame buffer、Render buffer、Data buffer等类型的缓冲区，它们的作用各不相同
        GLuint renderbuffer;
        glGenRenderbuffers(1, &renderbuffer);
        // 绑定渲染缓冲区
        glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
        // 存储空间的分配操作
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:glLayer];
        
        GLint renderbufferWidth, renderbufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderbufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderbufferHeight);
        
        
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
        GLuint framebuffer;
        glGenFramebuffers(1, &framebuffer);
        // 绑定帧缓冲区
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        // 将渲染缓冲区配置成帧缓冲区的颜色附着（Attachment）(将颜色数据放入帧缓冲区指定的位置让别人看)
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
        
        // 顶点着色器
        // 着色器语言 GLSL 写顶点着色器, 然后编译这个着色器
        // in: 输入参数, 无修饰符时默认为此修饰符
        // out: 输出参数
        // gl_Position: 顶点坐标(顶点着色器从应用程序中获得原始的顶点位置的数据, 这些原始的顶点数据在顶点着色器中经过平移、旋转、缩放等数学变换后, 生成新的顶点位置)
        // gl_PointSize: 点的大小，没有赋值则为默认值1，通常设置绘图为点绘制才有意义
        char *vertexShaderContent =
        "#version 300 es \n"
        "layout(location = 0) in vec4 position; "
        "layout(location = 1) in float point_size; "
        "void main() { "
        "    gl_Position = position; "
        "    gl_PointSize = point_size;"
        "}";
        NSLog(@"%s", vertexShaderContent);
        
        // 创建一个新的顶点着色器
        GLuint vertexShader = nnCompileShader(vertexShaderContent, GL_VERTEX_SHADER);
        
        // #version 300 es: 声明着色器版本, 通知着色器编译器预期在着色器中出现的语法和结构，检查着色器语法
        // vec4 包含了4个浮点数的向量(OpenGL ES着色语言中, 向量可以看做是用同样类型的标量组成, 其基本类型也分为bool、int和float三种。每个向量可以由2个、3个、4个相同的标量组成)
        /** 忽略半径大于0.5的点，实现圆点绘制
         // 函数 length(x)：计算向量 x 的长度
         if (length(gl_PointCoord - vec2(0.5)) > 0.5)
            discard;
         }
         */
        // fragColor 颜色
        // highp: 浮点精度, 表示高精度, 16 位(与顶点着色器不同, 在片元着色器中使用浮点型时, 必须指定浮点类型的精度, 否则编译会报错。精度有三种, lowp: 低精度, 8位; mediump: 中精度, 10位; highp: 高精度, 16位)
#if kDrawRoundPoint
        char *fragmentShaderContent =
        "#version 300 es \n"
        "precision highp float; "
        "out vec4 fragColor; "
        "void main() { "
        "    if (length(gl_PointCoord - vec2(0.5, 0.5)) > 0.5) { discard; }"
        "    fragColor = vec4(0.7, 0.15, 0.15, 1.0);"
        "}";
#else
        char *fragmentShaderContent =
        "#version 300 es \n"
        "precision highp float; "
        "out vec4 fragColor; "
        "void main() { "
        "fragColor = vec4(0.7, 0.15, 0.15, 1.0);"
        "}";
#endif
        // 创建一个新的片元着色器
        GLuint fragmentShader = nnCompileShader(fragmentShaderContent, GL_FRAGMENT_SHADER);
        
        // 创建着色器程序
        GLuint program = glCreateProgram();
        // 向程序中加入顶点着色器
        glAttachShader(program, vertexShader);
        // 向程序中加入片元着色器
        glAttachShader(program, fragmentShader);
        
        // 链接程序
        glLinkProgram(program);
        GLint linkStatus;
        // 使用 glGetProgramiv 获取连接情况
        glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
        if (linkStatus == GL_FALSE) {
            GLint infoLength;
            // 使用 glGetProgramiv 获取连接情况
            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLength);
            if (infoLength) {
                GLchar *infoLog = malloc(sizeof(GLchar) * infoLength);
                // glGetProgramInfoLog 获取连接错误
                glGetProgramInfoLog(program, infoLength, NULL, infoLog);
                NSLog(@"%s\n", infoLog);
                free(infoLog);
            }
        }
        
        // 加载并使用连接好的程序
        glUseProgram(program);
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        // 配置缓冲区清除颜色
        glClearColor(0, 0, 0, 1.0);
        // 设置屏幕颜色（清除渲染缓冲区）
        glClear(GL_COLOR_BUFFER_BIT);
        
        glViewport(0, 0, renderbufferWidth, renderbufferHeight);
        
        GLfloat vertex[2];
        GLfloat size[] = {50.f};
        for (GLfloat i = -0.9; i <= 1.0; i += 0.4f, size[0] += 30) {
            
            // 绘制点
            vertex[0] = i;
            vertex[1] = 0.f;
            
            // 允许使用顶点坐标数组
            glEnableVertexAttribArray(0);
            // 上传点大小至GPU
            glVertexAttribPointer(0, 2/* 坐标分量个数 */, GL_FLOAT, GL_FALSE, 0, vertex);
            
            // 允许使用顶点坐标数组
            glEnableVertexAttribArray(1);
            // 上传点大小至GPU
            glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, 0, size);
            
            // 绘制
            glDrawArrays(GL_POINTS, 0, 1);
        }
        
        // 交换前后端帧缓冲区
        // iOS系统维护着两个重要的帧缓冲区，当前屏幕使用的是前端帧缓冲区。然而，刚才我们的操作都在后端帧缓冲区执行，若直接写在前端帧缓冲区，那么没完成的绘制也会显示在屏幕上，而屏幕是逐行扫描刷新的，显然这个行为会给用户造成错觉，比如逐行绘制图片。所以，在后端帧缓冲区操作完成后，我们需要通知系统，让其交换前后端帧缓冲区，用户才能看到前面的操作。
        [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    return self;
}

GLuint nnCompileShader(char *shaderContent, GLenum shaderType) {
    // 创建一个新 shader
    GLuint shader = glCreateShader(shaderType);
    // 加载 shader 的源代码
    glShaderSource(shader, 1, &shaderContent, NULL);
    // 编译 shader
    glCompileShader(shader);
    
    GLint compileStatus;
    // 获取 shader 的编译情况
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    // 编译失败
    if (compileStatus == GL_FALSE) {
        GLint infoLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength) {
            // 如果编译失败则显示错误日志并释放此 shader
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
            printf("%s -> %s\n", shaderType == GL_VERTEX_SHADER ? "vertex shader" : "fragment shader", infoLog);
            free(infoLog);
        }
    }
    return shader;
}

/** 清理操作, 结束当前上下文 */
- (void)dealloc {
    if ([EAGLContext currentContext] == context) {
        EAGLContext.currentContext = nil;
    }
}

@end
