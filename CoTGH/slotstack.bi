#Ifndef SLOTSTACK_BI
#Define SLOTSTACK_BI

#Include "darray.bi"
#Include "variant.bi"
#Include "vec2f.bi"
#Include "vec3f.bi"

DECLARE_DARRAY(Variant)

Namespace act

Type SlotInvocationElement
  Declare Constructor() 'Disallowed
  Declare Destructor() 'Nop
  
  Declare Constructor(actorUId As ULongInt, slotIndex As UInteger, range As UInteger)
  
  As ULongInt actorUId 'Const
  As UInteger slotIndex 'Const
  As UInteger range 'Const
End Type

'Required to appease the storage element requirements of DArray
Type SlotParameterIndex
  Declare Constructor() 'Disallowed
  Declare Destructor() 'Nop
  
  Declare Constructor(parameterIndex As UInteger)
  
  As UInteger parameterIndex
End Type

DECLARE_DARRAY(SlotInvocationElement)
DECLARE_DARRAY(SlotParameterIndex)

'A stack containing actor slot invocations and associated parameters. This provides a mechanism
'for an actor slot to populate it's parameters with a single copy initiated by the triggering
'actor.
'
'Use pattern is to push some parameters, then push the slot invocation with the number of parameters
'specified as the range.
Type SlotStack
 Public:
  Declare Sub pushParameter(paramIndex As UInteger, ByRef x As Const Integer)
  Declare Sub pushParameter(paramIndex As UInteger, ByRef x As Const Single)
  Declare Sub pushParameter(paramIndex As UInteger, ByRef x As Const String)
  Declare Sub pushParameter(paramIndex As UInteger, ByRef x As Const Vec2F) 
  Declare Sub pushParameter(paramIndex As UInteger, ByRef x As Const Vec3F)
  
  'range denotes how many parameters were pushed with this slot invocation.
  Declare Sub pushSlot(actorUid As ULongInt, slotIndex As UInteger, range As UInteger)
  
  'If NULL is passed for the default, a default-default is supplied.
  Declare Const Function getInteger( _
      paramIndex As UInteger, _
      default As Const Integer Ptr = NULL) As Const Integer Ptr
  Declare Const Function getSingle( _
      paramIndex As UInteger, _
      default As Const Single Ptr = NULL) As Const Single Ptr
  Declare Const Function getString( _
      paramIndex As UInteger, _
      default As Const ZString Ptr = NULL) As Const ZString Ptr
  Declare Const Function getVec2F( _
      paramIndex As UInteger, _
      default As Const Vec2F Ptr = NULL) As Const Vec2F Ptr
  Declare Const Function getVec3F( _
      paramIndex As UInteger, _
      default As Const Vec3F Ptr = NULL) As Const Vec3F Ptr
  
  Declare Const Function getUId() As ULongInt
  Declare Const Function getSlotIndex() As UInteger
  
  Declare Sub pop()
  Declare Const Function size() As UInteger
 Private:
  
  'We make these arrays parallel instead of wrapping a single type to make it easier to emplace a Variant
  'directly into parameters.
  As DArray_SlotParameterIndex parameterIndices
  As DArray_Variant parameters
  
  As DArray_SlotInvocationElement slots
End Type
  
End Namespace

#EndIf
