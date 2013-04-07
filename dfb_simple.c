#include <stdio.h>
#include <unistd.h>
#include <directfb.h>

static IDirectFB *dfb = NULL;
static IDirectFBSurface *primary = NULL;
static int screen_width  = 0;
static int screen_height = 0;

#define DFBCHECK(x...)                                          \
{                                                               \
    DFBResult err = x;                                          \
                                                                \
    if (err != DFB_OK)                                          \
    {                                                           \
        fprintf( stderr, "%s <%d>:\n\t", __FILE__, __LINE__ );  \
        DirectFBErrorFatal( #x, err );                          \
    }                                                           \
}

int main (int argc, char **argv)
{
    int i;
    DFBSurfaceDescription dsc;

    DFBCHECK (DirectFBInit (&argc, &argv));

    DFBCHECK( DirectFBSetOption( "no-vt", NULL ) );                // 由于onyx没有tty0，所以姑且禁用vt
    DFBCHECK( DirectFBSetOption( "disable-module", "tslib" ) );    // 禁用tslib

    DFBCHECK (DirectFBCreate (&dfb));
    DFBCHECK (dfb->SetCooperativeLevel (dfb, DFSCL_FULLSCREEN));

    dsc.flags = DSDESC_CAPS;
    dsc.caps  = DSCAPS_PRIMARY | DSCAPS_FLIPPING;

    DFBCHECK (dfb->CreateSurface( dfb, &dsc, &primary ));
    DFBCHECK (primary->GetSize (primary, &screen_width, &screen_height));
    DFBCHECK (primary->FillRectangle (primary, 0, 0, screen_width, screen_height));
    DFBCHECK (primary->SetColor (primary, 0x80, 0x80, 0xff, 0xff));
    
    for (i=0;i<10;i++)
    {
        DFBCHECK (primary->DrawLine (primary, 0, i*10+1, screen_width - 1, i*10+1));
    }
    DFBCHECK (primary->Flip (primary, NULL, 0));
    sleep (5);
    primary->Release( primary );
    dfb->Release( dfb );
    return 23;
}
