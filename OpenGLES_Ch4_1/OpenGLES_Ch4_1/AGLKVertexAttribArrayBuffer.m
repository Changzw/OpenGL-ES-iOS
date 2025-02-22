//
//  AGLKVertexAttribArrayBuffer.m
//  OpenGLES_Ch4_1
//
//  Created by frank.zhang on 2019/1/22.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"
@interface AGLKVertexAttribArrayBuffer ()
@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;
@property (nonatomic, assign) GLsizeiptr stride;
@end

@implementation AGLKVertexAttribArrayBuffer
@synthesize name;
@synthesize bufferSizeBytes;
@synthesize stride;

- (id)initWithAttribStride:(GLsizeiptr)aStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage{
  NSParameterAssert(0 < aStride);
  NSAssert((0 < count && NULL != dataPtr) || (0 ==  count && NULL == dataPtr),@"data must not be NULL or count > 0");
  if (nil != (self = [super init])) {
    stride = aStride;
    bufferSizeBytes = stride * count;
    glGenBuffers(1, &name);
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, dataPtr, usage);
    NSAssert(0 != name, @"failed to generate name");
  }
  return self;
}

- (void)reinitWithAttribStride:(GLsizeiptr)aStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr{
  NSParameterAssert(0 < aStride);
  NSParameterAssert(0 < count);
  NSParameterAssert(NULL != dataPtr);
  NSAssert(0 != name, @"Invaild name");
  self.stride = aStride;
  self.bufferSizeBytes = aStride * count;
  glBindBuffer(GL_ARRAY_BUFFER, self.name);
  glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, dataPtr, GL_DYNAMIC_DRAW);
}

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable{
  NSParameterAssert((0 < count) && (count < 4));
  NSParameterAssert(offset < self.stride);
  NSAssert(0 != name, @"Invalid name");
  glBindBuffer(GL_ARRAY_BUFFER, self.name);
  if (shouldEnable) {
    glEnableVertexAttribArray(index);
  }
  glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride, NULL + offset);
#ifdef DEBUG
  {
    GLenum error = glGetError();
    if (GL_NO_ERROR != error) {
      NSLog(@"GL Error: 0x%x", error);
    }
  }
#endif
}

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
  NSAssert(self.bufferSizeBytes >= ((first + count) * self.stride), @"Attempt to draw more vertex data than available.");
  glDrawArrays(mode, first, count);
}

+ (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
  glDrawArrays(mode, first, count);
}

- (void)dealloc
{
  if (0 != name) {
    glDeleteBuffers(1, &name);
    name = 0;
  }
}
@end
