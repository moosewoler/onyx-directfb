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
* 上述这些函数都在~/src/gfx/generic/generic\_util.c。好像到底了，可是在哪里操作实际的fb呢？在“操作流水线”中，会依次调用流水线函数，这些函数看起来都是内存操作。

2. Pixel format
---------------
directfb支持41种像素格式，用DFBSurfacePixelFormat枚举类型将所有这些像素格式编号，并且将相关信息压缩到一起保存起来。用一组宏可以提取相应的信息。（~/include/directfb.h）

3. fbdev.c
----------
fbdev.c中定义的system开头的函数，都由~/src/core/core\_system.h声明过了。
换句话说，~/systems中的各个子目录都代表了一个系统，它们都按照core\_system.h的声明实现了一组函数。这些系统间是互不相容的——使用了x11就不能用fbdev，用了sdl就不能用vnc，等等。

4. DirectFBInit()
-----------------
处理命令行参数。这个函数之后，可以用DirectFBSetOption()调整系统设置。
~/src/directfb.c    DirectFBInit()
~/src/misc/conf.c   dfb\_config\_init()

5. DirectFBCreate(&directfb\_interface\_instance)
-------------------------------------------------
~/src/directfb.c                                DirectFBCreate()
    ~/lib/direct/direct.c                       direct\_initialize()                初始化direct。功能未知
    ~/src/core/core.c                           dfb\_core\_create()                 创建CoreDFB对象
        ~/src/core/system.c                     dfb\_system\_lookup()               检测系统模块
            ~/lib/direct/modules.c              direct_module_ref()                 direct提供模块的ref机制。成功的话，会把模块的所有可用函数返回。
    ~/lib/fusion/fusion.c                       fusion\_enter()                     创建一个fusion world，作为内部逻辑的核心。
    ~/lib/fusion/call.c                         fusion\_call\_init()                将handler挂在call上，成为一个FusionCall。
    ~/src/core/core.c                           dfb_core_arena_initialize()         初始化CoreDFB。
        ~/src/core/CoreDFB.cpp                  CoreDFB_Initialize()                从调试输出判断，此处应该进入COREDFB_CALL_DIRECT分支。Core具有"调用"栈机制，这是从字面上推测的，并没有直接的证明。实际的初始化由ICore_Real接口完成。
            ~/src/core/CoreDFB_real.cpp         ICore_Real::Initialize()            调用dfb_core_initialize()
                ~/src/core/core.c               dfb\_core\_initialize()             创建各种池
                    ~/src/core/graphics_state.c dfb_graphics_state_pool_create()    创建图像状态池
                    ~/src/core/layer_context.c  dfb_layer_context_pool_create()     创建图层上下文池
                    ~/src/core/layer_region.c   dfb_layer_region_pool_create()      创建图层区域池
    ~/src/idirectfb.c                           IDirectFB_Construct()               从CoreDFB创建IDirectFB
    完成
6. D\_MAGIC\_XXX(prt, magic)
-------------------------------
通过magic机制进行运行期类型检查
D\_MAGIC(spell)                     根据结构体生成magic
D\_MAGIC\_SET(ptr, magic)           设置对象的magic
D\_MAGIC\_CLEAR(ptr)                清除对象的magic
D\_MAGIC\_SET\_ONLY(ptr, magic)     强制设置对象的magic
D\_MAGIC\_CHECK(ptr, magic)         检查ptr的magic
D\_MAGIC\_ASSERT(ptr, magic)        检查ptr的magic，ptr的magic与给定magic不符便assert
D\_MAGIC\_ASSUME(ptr, magic)        假定ptr的magic为magic
