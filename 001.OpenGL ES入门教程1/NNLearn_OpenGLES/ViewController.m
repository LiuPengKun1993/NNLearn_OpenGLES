//
//  ViewController.m
//  NNLearn_OpenGLES
//
//  Created by liupengkun on 2018/7/19.
//  Copyright © 2018年 以梦为马. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/** 上下文 */
@property (nonatomic, strong) EAGLContext *context;

/** 着色器 */
@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation ViewController

/** OpenGL ES 不支持直接使用多边形数据，只能用三角形模拟多边形。而 OpenGL 是直接支持多边形的，因为 PC 的显卡性能更强。 */
/** 模拟器内存占用内存比较大: The OpenGL ES support in Simulator should be used to help you get started writing an OpenGL ES app. Never assume that Simulator reflects the real-world performance or the precise capabilities of the graphics processors used in iOS devices. Always profile and optimize your drawing code on a real device。 */

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatConfig];
    [self creatVertexData];
    [self creatFilePath];
}

- (void)creatConfig {
    
    // 新建 OpenGL ES 上下文
    /**
      * OpenGL ES 版本号
     kEAGLRenderingAPIOpenGLES1 = 1,
     kEAGLRenderingAPIOpenGLES2 = 2,
     kEAGLRenderingAPIOpenGLES3 = 3,
     */
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // storyboard 中需要设置成 GLKViewController 的控制器为跟控制器
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    // 颜色缓冲区格
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.context];
}

//- (void)creatVertexData {
//    // 顶点数据，前三个是顶点坐标，后面两个是纹理坐标
//    GLfloat squareVertexData[] = {
//        0.5, -0.5, 0.0f, 1.0f, 0.0f, //右下
//        0.5, 0.5, -0.0f, 1.0f, 1.0f, //右上
//        -0.5, 0.5, 0.0f, 0.0f, 1.0f, //左上
//        -0.5, -0.5, 0.0f, 0.0f, 0.0f, //左下
//    };
//    GLbyte indices[] =
//    {
//        0,1,2,
//        2,3,0
//    };
//
//
//    // 顶点数据缓存
//    GLuint buffer;
//    glGenBuffers(1, &buffer);
//    glBindBuffer(GL_ARRAY_BUFFER, buffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
//
//    GLuint texturebuffer;
//    glGenBuffers(1, &texturebuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, texturebuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
//
//    glEnableVertexAttribArray(GLKVertexAttribPosition); // 顶点数据缓存
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
//
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); // 纹理
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
//}

- (void)creatVertexData {
    // 顶点数组和索引数组，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（s，t）
    // 根据三角形的绘制顺序来定义
    // 索引绘制能够节省存储空间，共享顶点属性数据，但存在的限制是共享的数据的属性是相同的。当我们需要为同一个顶点指定不同的属性，例如颜色和法向量时，索引绘制无法满足需求，这时候需要使用顶点数组为同一个顶点指定不同属性。
    //  OpenGL ES 的顶点坐标也可以是二维的, 有几种办法实现，（1）把 attribute 声明成 vec2，（2）还是声明为 vec3，但是 attribPointer 指定成按照二维读取。这些都是常用的技巧
    // 两个三角形 180 度对称
//    GLfloat vertexData[] = {
//        0.8, -0.5, 0.0f, 0.0f, 0.0f,  //右下
//        0.8, 0.5, -0.0f, 0.0f, 1.0f,  //右上
//        0.0, 0.5, 0.0f, 1.0f, 1.0f,   //中上
//        0.0, -0.5, 0.0f, 1.0f, 0.0f,  //中下
//
//        -0.8, 0.5, 0.0f, 0.0f, 1.0f,  //左上
//        -0.8, -0.5, 0.0f, 0.0f, 0.0f, //左下
//        0.0, -0.5, 0.0f, 1.0f, 0.0f,  //中下
//        0.0, 0.5, 0.0f, 1.0f, 1.0f,   //中上
//    };

    GLfloat vertexData[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上

        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };

    // 核心内容
    // 顶点数据缓存
    GLuint buffer;
    // 申请一个标识符
    glGenBuffers(1, &buffer);
    // 把标识符绑定到 GL_ARRAY_BUFFER 上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    // 把顶点数据从 cpu 内存复制到 gpu 内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);

    // 开启对应的顶点属性, 顶点
    // 不调用 glEnableVertexAttribArray，就算上传了数据到 OpenGL 命令队列，Shader 端也不读取数据，结果就是画不出来你要的图形。
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // 设置合适的格式从 buffer 里面读取数据()
    //     glVertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid *ptr) 因为当前代码没有用到z, 因此这里 GLint size 改成 2 也是可以的,
    // https://www.jianshu.com/u/c68741efc396 作者在定义数组时写了x y z三个坐标分量，AttribPointer也指定了三个分量，一一对应。而你的想法是，这是二维场景，只需要x y两个分量，只使用x y两个参数的操作没问题，但是，需要处理好stride参数。作者硬编码了sizeof GLfloat * 5，这表明隔五个浮点数读取一组数据，所以，你改成2也能正常工作。
    // sizeof(GLfloat) * 5: 5个float长度代表一个顶点数据的长度

    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);

    // 开启对应的顶点属性, 纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    // 上传纹理坐标, 顶点的 (GLfloat *)NULL 加 0, 纹理的 (GLfloat *)NULL 加 3, 是因为前面定义的数组是 x y z，s t 这种形式，前三个是顶点坐标，后两个是纹理坐标，所以纹理坐标得跳过 x y z 三个数, 因此要加 3
    //     glVertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid *ptr) 纹理的是两位, 所以写成 2
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

- (void)creatFilePath {
    // 纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"hader" ofType:@"jpeg"];
    // GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    // GLKTextureLoader 读取图片
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    // 创建纹理 GLKTextureInfo
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // 创建着色器 GLKBaseEffect
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.texture2d0.enabled = GL_TRUE;
    // 把纹理赋值给着色器
    self.effect.texture2d0.name = textureInfo.name;
}


/** 如果你只有一个 glProgram，就像这个文档一样（只有一个 GLKBaseEffect，它包含一个glProgram ），在初始化 EAGLContext 后只调一次 prepareToDraw 是可以的。但是，有多个 Program 切换时，就得在每次绘制时 prepareToDraw（它内部用了 glUseProgram ）成当前 Program 才能接收到正确的 uniform 等状态设置 */
/** 渲染场景代码 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 界面背景色
    glClearColor(0.5f, 0.5f, 0.5, 1.0f);
    /*
     glClear 指定清除的 buffer
     共可设置三个选项 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT 和 GL_STENCIL_BUFFER_BIT
     也可组合如:glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
     */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // 启动着色器
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    //
//    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
