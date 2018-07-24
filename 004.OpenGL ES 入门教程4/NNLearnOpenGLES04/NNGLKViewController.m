//
//  NNGLKViewController.m
//  NNLearnOpenGLES04
//
//  Created by 刘朋坤 on 2018/7/23.
//  Copyright © 2018年 刘朋坤. All rights reserved.
//

#import "NNGLKViewController.h"
#import <OpenGLES/ES3/glext.h>

@interface NNGLKViewController() {
    float rotation;
    GLuint vertexBuffer;
    EAGLContext *context;
    GLKBaseEffect *effect;
}

@end

@implementation NNGLKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建管理上下文
    [self createEAGContext];
    // 配置
    [self configure];
    // 创建渲染管理
    [self createBaseEffect];
    // 添加顶点坐标和法线坐标
    [self addVertexAndNormal];
}

// 1. 创建管理上下文
- (void)createEAGContext {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"手机不支持opengl es3");
    }
    // 设置为当前上下文
    [EAGLContext setCurrentContext:context];
}

// 2.配置
- (void)configure {
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    /**
     在OpenGL的上下文中还有一个可配置的缓冲区---深度缓冲区.深度缓冲区保证离观察者更近的物体”盖住”远的物体.
     OpenGL默认的工作方式是对每个像素点都保存一个更近的物体是谁,保存的这些值放在深度缓冲区离.当OpenGl绘制每一个像素的时候都检测深度缓冲区,判断一下OpenGL是不是已经绘制过一个离观察者更近的物体,如果确实绘制过,OpenGl就会丢弃这个点,不然OpenGl就会把这个像素添加到深度缓冲区和颜色缓冲区.
     
     你可以设置drawableDepthFormat属性来选择深度缓冲区的格式.默认值是GLKViewDrawableDepthFormatNone----代表不开启深度缓冲区.
     
     如果想要开启这个特性,可以选择GLKViewDrawableDepthFormat16或者GLKViewDrawableDepthFormat24. GLKViewDrawableDepthFormat16消耗的资源少,但是当物体非常接近的时候,深度缓冲区的绘制可能会有一些不准确.
     */
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

// 3.创建渲染管理
- (void)createBaseEffect {
    effect = [[GLKBaseEffect alloc] init];
    effect.light0.enabled = GL_TRUE;
    // 漫反射颜色
    effect.light0.diffuseColor = GLKVector4Make(0.5, 0.2, 0.4, 1.0);
}

// 4.添加顶点坐标和法线坐标
- (void)addVertexAndNormal {
    // 开启深度测试 让被挡住的像素隐藏
    glEnable(GL_DEPTH_TEST);
    
    // 将顶点数据和法线数据加载到 GUP 中去
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    // 开启绘制命令 GLKVertexAttribPosition(位置)
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, 0);
    
    // 开启绘制命令 GLKVertexAttribPosition(法线)
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, ((char *)NULL + 12));
}

#pragma mark - GLKView and GLKViewController delegate methods
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 5.清理屏幕
    glClearColor(0.9, 0.9, 0.9, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 6. 绘制
    [effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

// 7. 改变运动轨迹
- (void)update {
    [self changeMoveTrack];
}

- (void)changeMoveTrack {
    // 获取一个屏幕比例值
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    
    // 透视转换
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    effect.transform.projectionMatrix = projectionMatrix;
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -10.0);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotation, 0.0, 1.0, 0.0);
    
    // 计算自身的坐标和旋转状态
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1.0, 1.0, 1.0);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    effect.transform.modelviewMatrix = modelViewMatrix;
    rotation += self.timeSinceLastUpdate * 0.5f;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

// 8.清理工作
- (void)dealloc {
    if ([EAGLContext currentContext] == context) {
        EAGLContext.currentContext = nil;
    }
}

GLfloat gCubeVertexData[216] = {
    // 坐标数据                               法线
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@end
