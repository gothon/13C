#Ifndef ACTORTYPES_BI
#Define ACTORTYPES_BI

Namespace bw
	
'An index into the actor table paired with an actor's unique id
Type ActorId
  actorIndex As UInteger 'Const
  actorUid As ULongInt 'Const
End Type

'An index into the actor create table.
Type ActorCreateIndex As UInteger

'A hash of a parmeter name used to match pushed parameters to slot parameters.
Type SlotParameterUid As ULongInt

'Indicies into an actor's signal/slot table.
Type SignalIndex As UInteger 
Type SlotIndex As UInteger

'Indicies into an actor's published values table.
Type ValueIndex As UInteger

Type PublishedValuePair
 	As ActorId id
	As ValueIndex index
End Type

Type PublishedSlotPair
 	As ActorId id
	As SlotIndex index
End Type

End Namespace

#EndIf
