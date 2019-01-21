#Ifndef ACTOR_DRAWBUFFERINTERFACE_BI
#Define ACTOR_DRAWBUFFERINTERFACE_BI

#Include "../actor.bi"
#Include "../quaddrawbuffer.bi"

Namespace act
	
Type DrawBufferInterface Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(DrawBufferInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, drawBuffer As QuadDrawBuffer Ptr)
	
	Declare Sub setGlobalLightDirection(ByRef d As Const Vec3F)
  Declare Sub setGlobalLightMinMax(min As Double, max As Double)
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As QuadDrawBuffer Ptr drawBuffer_ = NULL
 	
End Type

End Namespace

#EndIf