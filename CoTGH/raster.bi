#Ifndef RASTER_BI
#Define RASTER_BI

#Include "image32.bi"
#Include "vertex.bi"

'Utilities for rasterizing vector primitives 
Namespace raster

Declare Sub drawPlanarQuad OverLoad ( _
    ByRef src As Const Image32, _
    ByRef colorMod As Const Vec3F, _
    ByRef v0 As Const Vertex Ptr, _
    ByRef v1 As Const Vertex Ptr, _
    ByRef v2 As Const Vertex Ptr, _
    ByRef v3 As Const Vertex Ptr, _
    dst As Image32 Ptr)

End Namespace

#EndIf
