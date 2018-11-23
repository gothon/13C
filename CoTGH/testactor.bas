/'
#Include "actor.bi"
#Include "byteblob.bi"
#Include "variant.bi"

Namespace act
  
Type __act_TestActor
  
  Declare Sub __enter( _
      ByRef paramValues As Const DArray_Variant, _
      ByRef paramIds As Const DArray_ULongInt) Override
  Declare Sub __exit() Override
 
  '
  ' sets up published parameters
  '
  Declare Sub __register() Override
  Declare Sub __deserialize(ByRef blob As ByteBlob) Override
  Declare Const Sub __serialize(ByRef blob As ByteBlob) Override

  Declare Const Function __get_p_COOLNAME() ByRef As Const String

  Declare Sub __signal_assign_ENABLEPANEL(dest As SlotUId)  
  Declare Const Sub __fire_ENABLEPANEL(paramCount As UInteger))

 Public:
 	 
 
 Private:
  Declare Static Function __getParameter(paramId As ULongInt, _
      ByRef paramValues As Const DArray_Variant, _
      ByRef paramIds As Const DArray_ULongInt) As Const Variant Ptr
 
  'Actor State=========================================================================================================
  'Signal Targets-------------------------------- 
  As SlotUId __signal_ENABLEPANEL
 
  'Parameters------------------------------------
  As String __p_COOLNAME
  
  'Data------------------------------------------
  As Integer __d_TEST
  As Double __d_COOL
  
  'Values----------------------------------------
  As Double __v_AVALUE
  As String __v_AVALUETHATSASTRING
End Type

Sub __act_TestActor.__enter( _
    ByRef paramValues As Const DArray_Variant, _
    ByRef paramIds As Const DArray_ULongInt) Override
  __p_COOLNAME = *__getParameter(1234, paramValues, paramIds)
  
  
  
End Sub

Sub __act_TestActor.__exit()

End Sub

Sub __act_TestActor.__step(dT As Double)
  
End Sub

'Default
Sub __act_TestActor.__deserialize(ByRef blob As ByteBlob) Override
  blob.write(__v_AVALUETHATSASTRING)
  blob.write(__v_AVALUE)
  
  blob.write(__d_COOL)
  blob.write(__d_TEST)

  blob.write(__p_COOLNAME)
End Sub

'Default
Const Sub __act_TestActor.__serialize(ByRef blob As ByteBlob) Override
  blob.write(__p_COOLNAME)
  
  blob.write(__d_TEST)
  blob.write(__d_COOL)

  blob.write(__v_AVALUE)
  blob.write(__v_AVALUETHATSASTRING)
End Sub

Const Sub __act_TestActor.__getValue(index As UInteger, emplacementLoc As Variant Ptr)
  Select Case As Const index
    Case 1:
      Dim As Any Ptr unused = New(emplacementLoc) Variant(__v_AVALUE)
    Case 2:
      Dim As Any Ptr unused = New(emplacementLoc) Variant(__v_AVALUETHATSASTRING)
    Case Else 
      DEBUG_ASSERT(FALSE)
  End Select
End Sub
  
Sub __act_TestActor.__dispatchSlot(index As UInteger, ByRef stack As Const SlotStack, ByRef ref As Const ActorRef)
  Select Case As Const stack.getSlotIndex()
    Case 1
      __slot_wrap_INTERACT(stack, ref)
    Case 2
      __slot_wrap_KABOOM(stack, ref)
    Case Else
      DEBUG_ASSERT(FALSE)
  End Select
End Sub  
    
Sub __act_TestActor.__signal_assign_ENABLEPANEL(dest As SlotUId)  
  __signal_ENABLEPANEL = dest
End Sub

Const Sub __act_TestActor.__fire_ENABLEPANEL(paramCount As UInteger))
  '
  'get parent stack, push slot uid
  '
End Sub

Sub __act_TestActor.__slot_wrap_INTERACT(ByRef stack As Const SlotStack, ByRef ref As Const ActorRef)
  Static As Integer __default_PARAMA = 10
  Static As ZString*5 __default_PARAMB = "test"
  __slot_INTERACT(ref, *stack.getInteger(902, @__default_PARAMA), *stack.getString(24, @__default_PARAMB))
End Sub
  
Sub __act_TestActor.__slot_INTERACT(ByRef paramA As Const Integer, ByRef paramB As Const ZString, ByRef __act_ref As Const ActorRef)
  Print "wheee"
  Print paramA
  Print paramB
End Sub
    
Sub __act_TestActor.__slot_wrap_KABOOM(ByRef stack As Const SlotStack, ByRef ref As Const ActorRef)
  __slot_KABOOM(*stack.getVec3F(30))
End Sub
    
Sub __act_TestActor.__slot_KABOOM(ByRef paramQ As Const Vec3F, ByRef __act_ref As Const ActorRef)
  Print "Kaboom?"
  Print paramQ
  Print __act_ref '$ref
End Sub

End Namespace
'/