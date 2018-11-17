
Namespace act
  
Type __act_TestActor
 
 Public:
 	 
 	
 Private:
  
  
End Type


Sub __act_TestActor.serialize(pB As BinaryBlob Ptr)
End Sub

Sub __act_TestActor.deserialize(pB As BinaryBlob Ptr)
End Sub
  
Sub __act_TestActor.dispatchSlot(index As UInteger, ByRef stack As Const SlotStack)
  Select Case As Const stack.getSlotIndex()
    Case 1
      __slot_wrap_INTERACT(stack)
    Case 2
      __slot_wrap_KABOOM(stack)
    Case Else
      DEBUG_ASSERT(FALSE)
  End Select
End Sub  
  
Sub __act_TestActor.__slot_wrap_INTERACT(ByRef stack As Const SlotStack)
  Static As Integer __default_PARAMA = 10
  Static As ZString*5 __default_PARAMB = "test"
  __slot_INTERACT(*stack.getInteger(902, @__default_PARAMA), *stack.getString(24, @__default_PARAMB))
End Sub
  
Sub __act_TestActor.__slot_INTERACT(ByRef paramA As Const Integer, ByRef paramB As Const ZString)
  Print "wheee"
  Print paramA
  Print paramB
End Sub
    
Sub __act_TestActor.__slot_wrap_KABOOM(ByRef stack As Const SlotStack)
  __slot_KABOOM(*stack.getVec3F(30))
End Sub
    
Sub __act_TestActor.__slot_KABOOM(ByRef paramQ As Const Vec3F)
  Print "Kaboom?"
  Print paramQ
End Sub

End Namespace
