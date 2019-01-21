#Ifndef QUADDRAWBUFFER_BI
#Define QUADDRAWBUFFER_BI

#Include "quadmodel.bi"
#Include "image32.bi"
#Include "vertex.bi"
#Include "darray.bi"
#Include "light.bi"

Type QuadDrawElement
  Declare Constructor() 'Nop
  Declare Destructor() 'Nop
  
  Declare Constructor(q As Quad Ptr, parentId As ULongInt) 'Nop
  
  As Quad Ptr q
  As ULongInt parentId
End Type

DECLARE_DARRAY(QuadDrawElement)
DECLARE_DARRAY(LightPtr)

'A buffer for binding, then drawing bound quad models.
Type QuadDrawBuffer
	Declare Constructor()
  
  'All models must be un-bound before destruction
  Declare Destructor()
  
  'Binds the supplied quad model so that its screen projection will be drawn when draw() is called.
  Declare Sub bind(model As QuadModelBase Ptr)
  'Unbinds the supplied quad model so that it will no longer be drawn.
  Declare Sub unbind(model As QuadModelBase Ptr)
  
  'Binds the supplied light so that it will contribute lighting when calling draw.
  Declare Sub bind(l As Light Ptr)
  'Unbinds the supplied light so that it will no longer be applied.
  Declare Sub unbind(l As Light Ptr)
  
  Declare Sub project(ByRef proj As Const Projection)
  
  'Draws all bound models.
  Declare Sub draw(dst As Image32 Ptr)
  
  Declare Sub setGlobalLightDirection(ByRef d As Const Vec3F)
  Declare Sub setGlobalLightMinMax(min As Double, max As Double)
 Private:
  Declare Sub sort()
  Declare Sub lightQuad(q As Quad Ptr)
  Declare Sub lightQuadConst(q As Quad Ptr)
  Declare Static Function backfaceTest(ByRef q As Const Quad) As Boolean
  
  As Double globalLightMin_ = Any
  As Double globalLightMax_ = Any
  As Vec3F globalLightDirection_ = Any
  
  As DArray_QuadDrawElement quads_
  As DArray_LightPtr lights_
End Type

#EndIf
