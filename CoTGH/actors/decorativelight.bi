#Ifndef ACTORS_DECORATIVELIGHT_BI
#Define ACTORS_DECORATIVELIGHT_BI

#Include "../actor.bi"
#Include "../light.bi"

Namespace act
	
Type DecorativeLight Extends LightActor
 Public:
  'Takes ownership of light
	Declare Constructor(parent As ActorBankFwd Ptr, light As Light Ptr)
	
  Declare Constructor(ByRef other As Const DecorativeLight) 'disallowed
  Declare Operator Let(ByRef other As Const DecorativeLight) 'disallowed
	
	Declare Sub update(dt As Double) Override
 	Declare Sub notify() Override
 	
 	Declare Function clone() As Actor Ptr Override
End Type
	
End Namespace

#EndIf
