#Ifndef PRIMITIVE_BI
#Define PRIMITIVE_BI

'Convenience types for data structures that require primitive values with default constructors and destructors. 
Type Short_
 Public:
  Const As Short DEFAULT_VALUE = 0
 
  Declare Constructor(value As Short = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As Short
  Declare Operator Let(ByRef rhs As Short)
  
  Declare Const Function getValue() As Short
 Private:
  As Short value = Any
End Type

Type UShort_
 Public:
  Const As UShort DEFAULT_VALUE = 0
 
  Declare Constructor(value As UShort = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As UShort
  Declare Operator Let(ByRef rhs As UShort)
  
  Declare Const Function getValue() As UShort
 Private:
  As UShort value = Any
End Type

Type Integer_
 Public:
  Const As Integer DEFAULT_VALUE = 0
 
  Declare Constructor(value As Integer = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As Integer
  Declare Operator Let(ByRef rhs As Integer)

  Declare Const Function getValue() As Integer
 Private:
  As Integer value = Any
End Type

Type UInteger_
 Public:
  Const As UInteger DEFAULT_VALUE = 0
 
  Declare Constructor(value As UInteger = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As UInteger
  Declare Operator Let(ByRef rhs As UInteger)
  
  Declare Const Function getValue() As UInteger
 Private:
  As UInteger value = Any
End Type

Type LongInt_
 Public:
  Const As LongInt DEFAULT_VALUE = 0
 
  Declare Constructor(value As LongInt = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As LongInt
  Declare Operator Let(ByRef rhs As LongInt)
  
  Declare Const Function getValue() As LongInt
 Private:
  As LongInt value = Any
End Type

Type ULongInt_
 Public:
  Const As ULongInt DEFAULT_VALUE = 0
 
  Declare Constructor(value As ULongInt = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As ULongInt
  Declare Operator Let(ByRef rhs As ULongInt)
  
  Declare Const Function getValue() As ULongInt
 Private:
  As ULongInt value = Any
End Type

Type Single_
 Public:
  Const As Single DEFAULT_VALUE = 0
 
  Declare Constructor(value As Single = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Operator Cast() As Single
  Declare Operator Let(ByRef rhs As Single)
  
  Declare Const Function getValue() As Single
 Private:
  As Single value = Any
End Type

Type Double_
 Public:
  Const As Double DEFAULT_VALUE = 0
 
  Declare Constructor(value As Double = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As Double
  Declare Operator Let(ByRef rhs As Double)
  
  Declare Const Function getValue() As Double
 Private:
  As Double value = Any
End Type

Type ConstZStringPtr
 Public:
  Const As ZString Ptr DEFAULT_VALUE = 0 'NULL
 
  Declare Constructor(value As Const ZString Ptr = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As Const ZString Ptr
  Declare Operator Let(ByRef rhs As Const ZString Ptr)
  
  Declare Const Function getValue() As Const ZString Ptr
 Private:
  As Const ZString Ptr value = Any
End Type

#Macro DECLARE_PRIMITIVE_PTR(_TYPENAME_)
#Ifndef PRIMITIVE_PTR_##_TYPENAME_##_DECL
#Define PRIMITIVE_PTR_##_TYPENAME_##_DECL
Type _TYPENAME_##Ptr
 Public:
  Const As _TYPENAME_ Ptr DEFAULT_VALUE = CPtr(_TYPENAME_ Ptr, 0)
 
  Declare Constructor(value As _TYPENAME_ Ptr = DEFAULT_VALUE)
  Declare Destructor() 'Nop
    
  Declare Const Operator Cast() As _TYPENAME_ Ptr
  Declare Operator Let(ByRef rhs As _TYPENAME_ Ptr)
  
  Declare Const Function getValue() As _TYPENAME_ Ptr
 Private:
  As _TYPENAME_ Ptr value = Any
End Type
#EndIf
#EndMacro 

#Macro DEFINE_PRIMITIVE_PTR(_TYPENAME_)
Constructor _TYPENAME_##Ptr(value As _TYPENAME_ Ptr)
	This.value = value
End Constructor

Destructor _TYPENAME_##Ptr()
	'Nop
End Destructor

Const Operator _TYPENAME_##Ptr.Cast() As _TYPENAME_ Ptr
	Return value
End Operator

Operator _TYPENAME_##Ptr.Let(ByRef rhs As _TYPENAME_ Ptr)
	value = rhs
End Operator
  
Const Function _TYPENAME_##Ptr.getValue() As _TYPENAME_ Ptr
	Return value
End Function
#EndMacro 

#EndIf
