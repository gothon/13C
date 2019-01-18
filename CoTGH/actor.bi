#Ifndef ACTOR_BI
#Define ACTOR_BI

#Include "quadmodel.bi"
#Include "light.bi"
#Include "primitive.bi"

Namespace act

Type ActorBankFwd As ActorBank
Type ColliderFwd As Collider 

Type Actor Extends Object
 Public:
 	Declare Constructor(parent As ActorBankFwd Ptr)
 	Declare Virtual Destructor()
 	
 	Declare Abstract Function clone() As Actor Ptr
 	
 	Declare Sub ref()
 	Declare Sub unref()

 Protected:
 	As ActorBankFwd Ptr parent_ = NULL

 Private:
 	As UInteger refs_ = 0
End Type

DECLARE_PRIMITIVE_PTR(Actor)

Type DynamicActor Extends Actor
 Public:
 	Declare Constructor(parent As ActorBankFwd Ptr)
 	
 	Declare Abstract Sub update(dt As Double)
 	Declare Abstract Sub notify()
 	
 	Declare Abstract Function clone() As Actor Ptr
End Type

Type ModelActor Extends Actor
 Public:
 	'Takes ownership of model
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	Declare Virtual Destructor()
	
 	Declare Abstract Function clone() As Actor Ptr
 	
	Declare Function getModel() As QuadModelBase Ptr
 
 Private:
 	As QuadModelBase Ptr model_
End Type

Type CollidingModelActor Extends ModelActor
 Public:
 	'Takes ownership of model and collider
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, collider As ColliderFwd Ptr)
	Declare Virtual Destructor()
 	
 	Declare Abstract Function clone() As Actor Ptr
 	
	Declare Function getCollider() As ColliderFwd Ptr
	
 Private:
 	As ColliderFwd Ptr collider_
End Type

Type LightActor Extends DynamicActor
 Public:
 	'Takes ownership of light
	Declare Constructor(parent As ActorBankFwd Ptr, light As Light Ptr)
	Declare Virtual Destructor()
	
	Declare Abstract Sub update(dt As Double)
 	Declare Abstract Sub notify()
 	
 	Declare Abstract Function clone() As Actor Ptr
	
	Declare Function getLight() As Light Ptr
 
 Private:
 	As Light Ptr light_
End Type

End Namespace

#EndIf
