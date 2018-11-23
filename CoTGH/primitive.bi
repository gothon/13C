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

#EndIf
