#Ifndef ACTORMANAGER_BI
#Define ACTORMANAGER_BI

'actors have a non-static method that consumes the 
'last slot pushed onto its parent's stack (using it as an index into its table)

Type ActorManager
 Public:

  
  'Push a parameter onto the stack
  Declare Sub pushParameter(paramId As SlotParameterId, ByRef x As Const Integer)
  Declare Sub pushParameter(paramId As SlotParameterId, ByRef x As Const ULongInt)
  Declare Sub pushParameter(paramId As SlotParameterId, ByRef x As Const Double)
  Declare Sub pushParameter(paramId As SlotParameterId, ByRef x As Const String)
  Declare Sub pushParameter(paramId As SlotParameterId, ByRef x As Const Vec2F)
  Declare Sub pushParameter(paramId As SlotParameterId, ByRef x As Const Vec3F)
  
  'Push a slot invocation onto the stack by way of resolving a signal destination or invoking the slot directly.
  Declare Sub pushSlot(src As ActorId, signalId As SignalId, parameterN As Integer)
  Declare Sub pushSlot(dst As ActorId, slotId As SlotId, parameterN As Integer)
  
  Declare Function querySlots(preds() As Const PublishQueryPredicate) As SlotList
  Declare Function queryValues(preds() As Const PublishQueryPredicate) As ValueList
  
  Declare Sub connect(src As ActorId, signalId As SignalId, dst As ActorRef, slotId As ActorId) 
  
  Declare Function create(createId As ActorCreateId, params() As Const CreateParameter) As ActorId
  Declare Function createGlobal(createId As ActorCreateId, params() As Const CreateParameter) As ActorId  
 Private:
  
  
End Type


#EndIf
