#Ifndef ACTORS_DECORATIVELIGHT_BI
#Define ACTORS_DECORATIVELIGHT_BI

#Include "../actor.bi"
#Include "../light.bi"

Namespace act
	
Type DecorativeLight Extends LightActor
 Public:
 	ACTOR_REQUIRED_DECL(DecorativeLight)
 
  'Takes ownership of light
	Declare Constructor(parent As ActorBankFwd Ptr, light As Light Ptr)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
End Type
	
End Namespace

#EndIf
