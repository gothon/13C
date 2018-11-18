#Ifndef ACTOR_BI
#Define ACTOR_BI

#Include "actorgroup.bi"
#Include "byteblob.bi"
#Include "slotstack.bi"
#Include "variant.bi"
#Include "vec2f.bi"

Type ActorRef As ULongInt

Type Actor Extends Object
 Public:
  Declare Constructor(parent As ActorGroup Ptr)
  
  Declare Abstract Sub __enter()
  Declare Abstract Sub __dispatchSlot(index As UInteger, ByRef stack As Const SlotStack, ByRef ref As Const ActorRef)
  Declare Abstract Const Sub __getValue(index As UInteger, emplacementLoc As Variant Ptr)
  Declare Abstract Sub __deserialize(ByRef blob As ByteBlob)
  Declare Abstract Const Sub __serialize(ByRef blob As ByteBlob)
  Declare Abstract Sub __step(dT As Double)
  
 Private:
  As ActorRef thisRef 'Const
  As ActorGroup Ptr parent
    
  As DArray_UInteger publishTagRefs
  As DArray_UInteger publishSpatialRefs

  As Vec2F origin
End Type



#EndIf
