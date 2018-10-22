#Ifndef QUADDRAWBUFFER_BI
#Define QUADDRAWBUFFER_BI

#Include "quadmodel.bi"
#Include "image32.bi"
#Include "vertex.bi"
#Include "darray.bi"

Type QuadDrawElement
  As Const Quad Ptr q
  As LongInt parentId
End Type

'A buffer for binding, then drawing bound quad models.
Type QuadDrawBuffer
  Declare Constructor()
  
  'All models must be un-bound before destruction
  Declare Destructor()
  
  'Binds the supplied quad model so that its screen projection will be drawn when draw() is called.
  Declare Sub bind(model As QuadModelBase Ptr)
  
  'Unbinds the supplied quad model so that it will no longer be drawn.
  Declare Sub unbind(model As QuadModelBase Ptr)
  
  'Draws all bound models.
  Declare Sub draw(dst As Image32 Ptr)
 Private:
  Declare Sub sort()
  Declare Static Function backfaceTest(ByRef q As Const Quad) As Boolean
  
  As DArray quads = DARRAY_CREATE(QuadDrawElement)
End Type

#EndIf
