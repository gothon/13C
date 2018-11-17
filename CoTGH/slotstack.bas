#Include "slotstack.bi"

#Include "debuglog.bi"

Namespace act

Constructor SlotInvocationElement()
  DEBUG_ASSERT(FALSE)
End Constructor

Destructor SlotInvocationElement()
  'Nop
End Destructor
  
Constructor SlotInvocationElement(actorUId As ULongInt, slotIndex As UInteger, range As UInteger)
  This.actorUId = actorUId
  This.slotIndex = slotIndex
  This.range = range
End Constructor

Constructor SlotParameterIndex()
  DEBUG_ASSERT(FALSE)
End Constructor
Destructor SlotParameterIndex()
  'Nop
End Destructor
  
Constructor SlotParameterIndex(parameterIndex As UInteger)
  This.parameterIndex = parameterIndex
End Constructor

Sub SlotStack.pushParameter(paramIndex As UInteger, ByRef x As Const Integer)
  DArray_SlotParameterIndex_Emplace(parameterIndices, paramIndex)
  DArray_Variant_Emplace(parameters, x)
End Sub

Sub SlotStack.pushParameter(paramIndex As UInteger, ByRef x As Const Single)
  DArray_SlotParameterIndex_Emplace(parameterIndices, paramIndex)
  DArray_Variant_Emplace(parameters, x)
End Sub

Sub SlotStack.pushParameter(paramIndex As UInteger, ByRef x As Const String)
  DArray_SlotParameterIndex_Emplace(parameterIndices, paramIndex)
  DArray_Variant_Emplace(parameters, x)  
End Sub

Sub SlotStack.pushParameter(paramIndex As UInteger, ByRef x As Const Vec2F) 
  DArray_SlotParameterIndex_Emplace(parameterIndices, paramIndex)
  DArray_Variant_Emplace(parameters, x)  
End Sub

Sub SlotStack.pushParameter(paramIndex As UInteger, ByRef x As Const Vec3F)
  DArray_SlotParameterIndex_Emplace(parameterIndices, paramIndex)
  DArray_Variant_Emplace(parameters, x)
End Sub
  
Sub SlotStack.pushSlot(actorUId As ULongInt, slotIndex As UInteger, range As UInteger)
  DArray_SlotInvocationElement_Emplace(slots, actorUId, slotIndex, range)
End Sub

Const Function SlotStack.getInteger( _
    paramIndex As UInteger, _
    default As Const Integer Ptr) As Const Integer Ptr
  Static As Integer INTERNAL_DEFAULT = 0
  For i As Integer = (parameterIndices.size() - slots.backConst().range) To parameterIndices.size() - 1  
    If (parameterIndices.getConst(i).parameterIndex = paramIndex) _  
        AndAlso (parameters.getConst(i).getType() = Variant.INTEGER_) Then
      Return parameters.getConst(i).getInteger()
    EndIf         
  Next i
  Return IIf(default = NULL, @INTERNAL_DEFAULT, default)
End Function
                                    
Const Function SlotStack.getSingle( _
    paramIndex As UInteger, _
    default As Const Single Ptr) As Const Single Ptr
  Static As Single INTERNAL_DEFAULT = 0.0f
  For i As Integer = (parameterIndices.size() - slots.backConst().range) To parameterIndices.size() - 1  
    If (parameterIndices.getConst(i).parameterIndex = paramIndex) _  
        AndAlso (parameters.getConst(i).getType() = Variant.SINGLE_) Then
      Return parameters.getConst(i).getSingle()
    EndIf         
  Next i
  Return IIf(default = NULL, @INTERNAL_DEFAULT, default) 
End Function

Const Function SlotStack.getString( _
    paramIndex As UInteger, _
    default As Const ZString Ptr) As Const ZString Ptr
  Static As ZString * 1 INTERNAL_DEFAULT = ""
  For i As Integer = (parameterIndices.size() - slots.backConst().range) To parameterIndices.size() - 1  
    If (parameterIndices.getConst(i).parameterIndex = paramIndex) _  
        AndAlso (parameters.getConst(i).getType() = Variant.STRING_) Then
      Return parameters.getConst(i).getString()
    EndIf         
  Next i
  Return IIf(default = NULL, @INTERNAL_DEFAULT, default)
End Function

Const Function SlotStack.getVec2F( _
    paramIndex As UInteger, _
    default As Const Vec2F Ptr) As Const Vec2F Ptr
  Static As Vec2F INTERNAL_DEFAULT
  For i As Integer = (parameterIndices.size() - slots.backConst().range) To parameterIndices.size() - 1  
    If (parameterIndices.getConst(i).parameterIndex = paramIndex) _  
        AndAlso (parameters.getConst(i).getType() = Variant.VEC2F_) Then
      Return parameters.getConst(i).getVec2F()
    EndIf
  Next i
  Return IIf(default = NULL, @INTERNAL_DEFAULT, default)
End Function
                                  
                                  
Const Function SlotStack.getVec3F( _
    paramIndex As UInteger, _
    default As Const Vec3F Ptr) As Const Vec3F Ptr
  Static As Vec3F INTERNAL_DEFAULT
  For i As Integer = (parameterIndices.size() - slots.backConst().range) To parameterIndices.size() - 1  
    If (parameterIndices.getConst(i).parameterIndex = paramIndex) _  
        AndAlso (parameters.getConst(i).getType() = Variant.VEC3F_) Then
      Return parameters.getConst(i).getVec3F()
    EndIf
  Next i
  Return IIf(default = NULL, @INTERNAL_DEFAULT, default)
End Function
  
Const Function SlotStack.getUId() As ULongInt
  Return slots.backConst().actorUid
End Function

Const Function SlotStack.getSlotIndex() As UInteger
  Return slots.backConst().slotIndex                        
End Function

Sub SlotStack.pop()
  For i As Integer = 0 To slots.back().range - 1
    parameters.pop()
    parameterIndices.pop()
  Next i
  slots.pop()
End Sub

Const Function SlotStack.size() As UInteger
  Return slots.size()   
End Function
  
End Namespace