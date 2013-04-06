onyx-directfb
=============

port directfb to onyx boox device.

1. surface.DrawString()
--------------------------------

        ~/src/display/idirectfbsurface.c                        IDirectFBSurface_DrawString()
            ~/src/core/gfxcard.c                                dfb_gfxcard_drawstring()        该函数会把字符串拆成单个字符，支持charset，以字符索引的形式保存各个字符。然后依次Blit各个字符。
                ~/src/core/CoreGraphicsStateClient.cpp          CoreGraphicsStateClient_Blit()  
                    ~/src/core/CoreGraphicsState.cpp            CoreGraphicsState_Blit()
                        ~/src/core/CoreGraphicsState_real.cpp   IGraphicsState_Real::Blit()     如果不启用加速的话，会调用dfb_gfxcard_batchblit；如果启用加速的话，还会判断是硬件加速还是其他加速，硬件加速调用card->funcs.Blit，其他加速调用gBlit。
                            ~/src/gfx/generic/generic_blit.c    gBlit()                         gBlit支持翻转和旋转。
                            
gBlit的流程是：
        
        Aop_xy, Bop_xy
        操作流水线
        Aop_advance
        操作流水线
        Aop_advance
        Bop_advance
        Bop_advance
        ABacc_flush
~/src/gfx/generic是directfb实现的虚拟GPU——“Genefx”（发音：genie facts）

上述这些软件显卡流水线操作都在~/src/gfx/generic/generic\_util.c中。好像到底了，可是在哪里操作实际的fb呢？在“操作流水线”中，会依次调用流水线函数，这些函数看起来都是内存操作。

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
        ~/src/misc/conf.c   dfb_config_init()

5. DirectFBCreate(&directfb\_interface\_instance)
-------------------------------------------------
        ~/src/directfb.c                                DirectFBCreate()
    ~/lib/direct/direct.c                       direct_initialize()                初始化direct。功能未知
    ~/src/core/core.c                           dfb_core_create()                 创建CoreDFB对象
        ~/src/core/system.c                     dfb_system_lookup()               检测系统模块
            ~/lib/direct/modules.c              direct_module_ref()                 direct提供模块的ref机制。成功的话，会把模块的所有可用函数返回。
    ~/lib/fusion/fusion.c                       fusion_enter()                     创建一个fusion world，作为内部逻辑的核心。
    ~/lib/fusion/call.c                         fusion_call_init()                将handler挂在call上，成为一个FusionCall。
    ~/src/core/core.c                           dfb_core_arena_initialize()         初始化CoreDFB。
        ~/src/core/CoreDFB.cpp                  CoreDFB_Initialize()                从调试输出判断，此处应该进入COREDFB_CALL_DIRECT分支。Core具有"调用"栈机制，这是从字面上推测的，并没有直接的证明。实际的初始化由ICore_Real接口完成。
            ~/src/core/CoreDFB_real.cpp         ICore_Real::Initialize()            调用dfb_core_initialize()
                ~/src/core/core.c               dfb_core_initialize()             创建各种池
                    ~/src/core/graphics_state.c dfb_graphics_state_pool_create()    创建图像状态池
                    ~/src/core/layer_context.c  dfb_layer_context_pool_create()     创建图层上下文池
                    ~/src/core/layer_region.c   dfb_layer_region_pool_create()      创建图层区域池
    ~/src/idirectfb.c                           IDirectFB_Construct()               从CoreDFB创建IDirectFB
    完成
6. D\_MAGIC\_XXX(prt, magic)
-------------------------------
通过magic机制进行运行期类型检查

        D_MAGIC(spell)                      根据结构体生成magic
        D_MAGIC_SET(ptr, magic)             设置对象的magic
        D_MAGIC_CLEAR(ptr)                  清除对象的magic
        D_MAGIC_SET_ONLY(ptr, magic)        强制设置对象的magic
        D_MAGIC_CHECK(ptr, magic)           检查ptr的magic
        D_MAGIC_ASSERT(ptr, magic)          检查ptr的magic，ptr的magic与给定magic不符便assert
        D_MAGIC_ASSUME(ptr, magic)          假定ptr的magic为magic

7. core\_parts.h
---------------
~/src/core/core\_parts.h定义了core part的成员与方法，以及定义core part对象的宏。
directfb中被定义为Core Part的对象共有9个，分别是：

    * clipboard\_core
    * colorhash\_core
    * graphics\_core
    * input\_core
    * layer\_core
    * screen\_core
    * surface\_core
    * system\_core       对于directfb来说，system指不同的平台，如：fbdev,x11,osx...
    * wm\_core

8. IDirectFB::CreateSurface()
-----------------------------
本体是IDirectFB\_CreateSurface()

        ~/src/idirectfb.c                           IDirectFB_CreateSurface()   由surface_desc.caps的DSCAPS_PRIMARY标志来控制创建的表面是否为主表面。如果是普通表面的话，将调用CoreDFB\_CreateSurface()来创建。
            ~/src/core/CoreDFB.cpp                  CoreDFB_CreateSurface()     由real.CreateSurface()实际完成。CoreDFB的调用堆栈是为了实现什么功能？
                ~/src/core/CoreDFB_real.cpp         ICore_Real::CreateSurface()
                    ~/src/core/surface.c            dfb_surface_create()
                        ~/src/core/core.c           dfb_core_create_surface()   合法性判断之后，创建fusion对象
                            ~/lib/fusion/object.c   fusion_object_create()      coredfb具有几个池，保存了诸如表面、图像状态、图层上下文等等。所有这些池都是由fusion处理的。

9. IDirectFBSurface::BatchBlit()
--------------------------------
本体是IDirectFBSurface\_BatchBlit()

        ~/src/display/idirectfbsurface.c                    IDirectFBSurface_BatchBlit()
            ~/src/core/CoreGraphicsStateClient.cpp          CoreGraphicsStateClient_Blit()  
                ~/src/core/CoreGraphicsState.cpp            CoreGraphicsState_Blit()
                    ~/src/core/CoreGraphicsState_real.cpp   IGraphicsState_Real::Blit()     如果不启用加速的话，会调用dfb_gfxcard_batchblit；如果启用加速的话，还会判断是硬件加速还是其他加速，硬件加速调用card->funcs.Blit，其他加速调用gBlit。
                        ~/src/gfx/generic/generic_blit.c    gBlit()                         gBlit支持翻转和旋转。
