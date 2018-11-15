#Include "darray.bi"
#Include "quadmodel.bi"
#Include "quaddrawbuffer.bi"
#Include "image32.bi"
#Include "simpletagindex.bi"
#Include "slotstack.bi"

DECLARE_DARRAY(Quad)
DEFINE_DARRAY(Quad)

DECLARE_DARRAY(QuadDrawElement)
DEFINE_DARRAY(QuadDrawElement)

DECLARE_DARRAY(Image32)
DEFINE_DARRAY(Image32)

DECLARE_SIMPLETAGINDEX(String)
DECLARE_DARRAY(SimpleTagIndex_String_Element)
DEFINE_DARRAY(SimpleTagIndex_String_Element)

DECLARE_DARRAY(Variant)
DEFINE_DARRAY(Variant)

Namespace act
DECLARE_DARRAY(SlotInvocationElement)
DEFINE_DARRAY(SlotInvocationElement)

DECLARE_DARRAY(SlotParameterIndex)
DEFINE_DARRAY(SlotParameterIndex)
End Namespace
