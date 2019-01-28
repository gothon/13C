#Include "primitive.bi"

#Macro DEFINE_PRIMITIVE(_CLASSNAME_, _TYPENAME_)
Constructor _CLASSNAME_(value As _TYPENAME_)
  This.value = value
End Constructor

Destructor _CLASSNAME_()
  'Nop
End Destructor
    
Operator _CLASSNAME_.Cast() As _TYPENAME_
  Return value
End Operator

Operator _CLASSNAME_.Let(ByRef rhs As _TYPENAME_)
  value = rhs
End Operator

Const Function _CLASSNAME_.getValue() As _TYPENAME_
  Return value
End Function
#EndMacro
  
DEFINE_PRIMITIVE(Short_, Short)
DEFINE_PRIMITIVE(UShort_, UShort)
DEFINE_PRIMITIVE(Integer_, Integer)
DEFINE_PRIMITIVE(UInteger_, UInteger)
DEFINE_PRIMITIVE(LongInt_, LongInt)
DEFINE_PRIMITIVE(ULongInt_, ULongInt)
DEFINE_PRIMITIVE(Single_, Single)
DEFINE_PRIMITIVE(Double_, Double)

Constructor ConstZStringPtr(value As Const ZString Ptr)
  This.value = value
End Constructor

Destructor ConstZStringPtr()
  'Nop
End Destructor
    
Const Operator ConstZStringPtr.Cast() As Const ZString Ptr
  Return value
End Operator

Operator ConstZStringPtr.Let(ByRef rhs As Const ZString Ptr)
  value = rhs
End Operator

Const Function ConstZStringPtr.getValue() As Const ZString Ptr
  Return value
End Function

DEFINE_PRIMITIVE_PTR(ZString)
DEFINE_PRIMITIVE_PTR(Any)
