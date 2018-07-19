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

- (void)creatVertexData {
    // 顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
    // 根据三角形的绘制顺序来定义
    // 三角形顺序都是顺时针, 先左再右, 左边的三角形从 "右下" 开始, 右边的三角形从 "左上" 开始
    GLfloat vertexData[] = {
        0.8, -0.5, 0.0f, 0.0f, 0.0f,  //右下
        0.8, 0.5, -0.0f, 0.0f, 1.0f,  //右上
        0.0, 0.5, 0.0f, 1.0f, 1.0f,   //中上
        0.0, -0.5, 0.0f, 1.0f, 0.0f,  //中下
        
        -0.8, 0.5, 0.0f, 0.0f, 1.0f,  //左上
        -0.8, -0.5, 0.0f, 0.0f, 0.0f, //左下
        0.0, -0.5, 0.0f, 1.0f, 0.0f,  //中下
        0.0, 0.5, 0.0f, 1.0f, 1.0f,   //中上
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
    
    // 开启对应的顶点属性, 顶点数据缓存
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // 设置合适的格式从buffer里面读取数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    // 开启对应的顶点属性, 纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    // 设置合适的格式从buffer里面读取数据
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

/** 渲染场景代码 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 界面背景色
    glClearColor(0.5f, 0.5f, 0.5, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // 启动着色器
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
