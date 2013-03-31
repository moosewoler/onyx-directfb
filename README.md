onyx-directfb
=============

port directfb to onyx boox device.

1. surface.DrawString()调用顺序
--------------------------------
* DrawString函数指针指向IDirectFBSurface\_DrawString(~/src/display/idirectfbsurface.c)。IDirectFBSurface\_DrawString在最后调用dfb\_gfxcard\_drawstring继续完成文字输出。
* dfb\_gfxcard\_drawstring(~/src/core/gfxcard.c)会把字符串拆开，支持charset，并以字符索引的形式保存各个字符。然后依次Blit各个字符。Blit使用CoreGraphicsStateClient\_Blit。
* CoreGraphicsStateClient\_Blit(~/src/core/CoreGraphicsStateClient.cpp)。调用CoreGraphicsState\_Blit。
* CoreGraphicsState\_Blit(~/src/core/CoreGraphicsState.cpp)，调用IGraphicsState\_Real.Blit。
* IGraphicsState\_Real::Blit(~/src/core/CoreGraphicsState\_real.cpp)。如果不启用加速的话，会调用dfb\_gfxcard\_batchblit；如果启用加速的话，还会判断是硬件加速还是其他加速，硬件加速调用card\->funcs.Blit，其他加速调用gBlit。
* gBlit(~/src/gfx/generic/generic\_blit.c)。在gBlit中支持翻转和旋转。定好旋转和翻转的方向后，就选择了位置参数以及Genefx\_Aop\_xxxx。Blit的流程是：
    Aop\_xy, Bop\_xy
    操作流水线
    Aop\_advance
    操作流水线
    Aop\_advance
    Bop\_advance
    Bop\_advance
    ABacc\_flush
gfx/generic是directfb实现的虚拟GPU——“Genefx”（发音：genie facts）
* 上述这些函数都在~/src/gfx/generic/generic\_util.c。好像到底了，可是在哪里操作实际的fb呢？

