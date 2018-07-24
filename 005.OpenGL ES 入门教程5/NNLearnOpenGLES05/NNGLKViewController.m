//
//  NNGLKViewController.m
//  NNLearnOpenGLES05
//
//  Created by 刘朋坤 on 2018/7/24.
//  Copyright © 2018年 刘朋坤. All rights reserved.
//

#import "NNGLKViewController.h"
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES1/gl.h>

@interface NNGLKViewController() {
    EAGLContext *context;
}

@end

@implementation NNGLKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建EAGContext
    [self createContext];
    // 配置view
    [self configure];
}

// 创建EAGContext
- (void)createContext {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
}

// 配置view
- (void)configure {
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 设置清除颜色
    [self clear];
    // 创建投影坐标
    [self initProjectionMatrix];
    // 创建自身坐标
    [self initModelView];
    // 加载顶点数据
    [self loadVetexData];
    // 加载颜色数据
    [self loadColorData];
    // 开始绘制
    [self draw];
}

// 设置清除颜色
- (void)clear {
    // 第一条语句表示清除颜色设为(0.5, 0.5, 0.5, 1.0)，第二条语句表示把整个窗口清除为当前的清除颜色，glClear（）的唯一参数表示需要被清除的缓冲区。
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

// 创建投影坐标
- (void)initProjectionMatrix {
    /**
     glMatrixMode设置当前矩阵模式，mode允许的值有：
     GL_MODELVIEW——应用视图矩阵堆的后续矩阵操作
     GL_PROJECTION——应用投射矩阵堆的后续矩阵操作
     GL_TEXTURE——应用纹理矩阵堆的后续矩阵操作
     GL_MATRIX_PALETTE_OES（OES_matrix_palette扩展）——启用矩阵调色板堆栈扩展，并应用矩阵调色板堆栈后续矩阵操作
     */
    glMatrixMode(GL_PROJECTION);
    // glLoadIdentity使特征矩阵代替当前矩阵, 语义上等价于调用glLoadMatrix方法并以特征矩阵为参数
    glLoadIdentity();
}

// 创建自身坐标
- (void)initModelView {
    static float transY = 0.0;
    /**
     glMatrixMode设置当前矩阵模式，mode允许的值有：
     GL_MODELVIEW——应用视图矩阵堆的后续矩阵操作
     GL_PROJECTION——应用投射矩阵堆的后续矩阵操作
     GL_TEXTURE——应用纹理矩阵堆的后续矩阵操作
     GL_MATRIX_PALETTE_OES（OES_matrix_palette扩展）——启用矩阵调色板堆栈扩展，并应用矩阵调色板堆栈后续矩阵操作
     */
    glMatrixMode(GL_MODELVIEW);
    // glLoadIdentity使特征矩阵代替当前矩阵, 语义上等价于调用glLoadMatrix方法并以特征矩阵为参数
    glLoadIdentity();
    // 用平移矩阵乘以当前矩阵。
    glTranslatef(0.0, (GLfloat)(sinf(transY)/2.0), 0.0);
    transY += 0.075;
}

// 加载顶点数据
- (void)loadVetexData {
    // 定义一个顶点坐标矩阵
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    // 启用客户端的某项功能
    glEnableClientState(GL_VERTEX_ARRAY);
}

// 加载颜色数据
- (void)loadColorData {
    /**
    glColorPointer指明渲染时使用的颜色矩阵。size指明每个颜色的元素数量，必须为4。type指明每个颜色元素的数据类型，stride指明从一个颜色到下一个允许的顶点的字节增幅，并且属性值被挤入简单矩阵或存储在单独的矩阵中（简单矩阵存储可能在一些版本中更有效率）。
    当一个颜色矩阵被指定，size, type, stride和pointer将被保存在客户端状态。
     size——指明每个颜色的元素数量，必须为4。
     type——指明每个矩阵中颜色元素的数据类型，允许的符号常量有GL_UNSIGNED_BYTE, GL_FIXED和GL_FLOAT，初始值为GL_FLOAT。
     stride——指明连续的点之间的位偏移，如果stride为0时，颜色被紧密挤入矩阵，初始值为0。
     pointer——指明包含颜色的缓冲区，如果pointer为null，则为设置缓冲区。
    glColorPointer(<#GLint size#>, <#GLenum type#>, <#GLsizei stride#>, <#const GLvoid *pointer#>)
    */
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    // 启用客户端的某项功能
    glEnableClientState(GL_COLOR_ARRAY);
}

// 开始绘制
- (void)draw {
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

static const GLfloat squareVertices[] = {
    -0.5, -0.33,
    0.5, -0.33,
    -0.5,  0.33,
    0.5,  0.33,
};

static const GLubyte squareColors[] = {
    255,  0,   0, 255,
     0,  255,  0,  255,
     0,  255,  0,  255,
    255,  0,  255,  255,
};

@end
