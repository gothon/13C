#Ifndef ACTOR_BI
#Define ACTOR_BI

#Include "quadmodel.bi"
#Include "light.bi"
#Include "primitive.bi"
#Include "actortypes.bi"

#Macro ACTOR_REQUIRED_DECL(_ACTORNAME_)
  Declare Constructor(ByRef other As Const _ACTORNAME_) 'disallowed
  Declare Operator Let(ByRef other As Const _ACTORNAME_) 'disallowed
 Protected:
	Declare Sub setType() Override
 Public:
#EndMacro

#Macro ACTOR_REQUIRED_DEF(_ACTORNAME_, _ACTORTYPE_)
Constructor _ACTORNAME_(ByRef other As Const _ACTORNAME_)
	DEBUG_ASSERT(FALSE)
End Constructor

Operator _ACTORNAME_.Let(ByRef other As Const _ACTORNAME_)
	DEBUG_ASSERT(FALSE)	
End Operator

Sub _ACTORNAME_.setType()
	actorType_ = _ACTORTYPE_
End Sub
#EndMacro

Namespace act

Type ActorBankFwd As Any
Type ColliderFwd As Any 

Type Actor Extends Object
 Public:
 	Declare Constructor() 'No-op required
 	
 	Declare Constructor(parent As ActorBankFwd Ptr)
 	Declare Virtual Destructor()
 	
 	Declare Abstract Function clone(parent as ActorBankFwd Ptr) As Actor Ptr
 	
	Declare Sub setParentRef(ref As UInteger)
	Declare Function getParentRef() As UInteger
	
	Declare Sub setParent(parent As ActorBankFwd Ptr)
	Declare Function getParent() As ActorBankFwd Ptr
	
	Declare Function getKey() As Const ZString Ptr
	
	Declare Const Function getType() As ActorTypes

 Protected:
 	As ActorBankFwd Ptr parent_ = NULL
	As ActorTypes actorType_ = ActorTypes.UNKNOWN
	
	Declare Sub setKey(key As Const ZString Ptr)
	Declare Abstract Sub setType()
	
 Private:
 	As UInteger parentRef_ = -1
 	As ZString Ptr key_ = NULL
End Type

Type DynamicActor Extends Actor
 Public:
  Declare Constructor() 'No-op required
  Declare Virtual Destructor()
  	
 	Declare Constructor(parent As ActorBankFwd Ptr)
 	
 	Declare Abstract Function update(dt As Double) As Boolean
 	Declare Abstract Sub notify()
End Type

Type DynamicModelActor Extends DynamicActor
 Public:
 	Declare Constructor() 'No-op required
 	
 	'Takes ownership of model
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	Declare Virtual Destructor()
	
	Declare Function getModel() As QuadModelBase Ptr
 
 Protected:
 	As QuadModelBase Ptr model_
End Type

Type DynamicCollidingModelActor Extends DynamicModelActor
 Public:
	Declare Constructor() 'No-op required
  	
 	'Takes ownership of model and collider
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, colliderPtr As ColliderFwd Ptr)
	Declare Virtual Destructor()
 	
	Declare Function getCollider() As ColliderFwd Ptr
	
 Protected:
 	As ColliderFwd Ptr collider_
End Type

Type ModelActor Extends Actor
 Public:
 	Declare Constructor() 'No-op required
 	
 	'Takes ownership of model
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	Declare Virtual Destructor()
	
	Declare Function getModel() As QuadModelBase Ptr
 
 Protected:
 	As QuadModelBase Ptr model_
End Type

Type CollidingModelActor Extends ModelActor
 Public:
	Declare Constructor() 'No-op required
  	
 	'Takes ownership of model and collider
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, colliderPtr As ColliderFwd Ptr)
	Declare Virtual Destructor()
 	
	Declare Function getCollider() As ColliderFwd Ptr
	
 Protected:
 	As ColliderFwd Ptr collider_
End Type

Type LightActor Extends DynamicActor
 Public:
  Declare Constructor() 'No-op required
  	
 	'Takes ownership of light
	Declare Constructor(parent As ActorBankFwd Ptr, light As Light Ptr)
	Declare Virtual Destructor()
	
	Declare Function getLight() As Light Ptr
 
 Protected:
 	As Light Ptr light_
End Type

Declare Function maybeUpdate(actorPtr As Actor Ptr, dt As Double) As Boolean
Declare Sub maybeNotify(actorPtr As Actor Ptr)
Declare Function getLightOrNull(actorPtr As Actor Ptr) As Light Ptr
Declare Function getModelOrNull(actorPtr As Actor Ptr) As QuadModelBase Ptr
Declare Function getColliderOrNull(actorPtr As Actor Ptr) As ColliderFwd Ptr
Declare Sub deleteActor(x As Actor Ptr)
Declare Function cloneActor(x As Actor Ptr, bank As ActorBankFwd Ptr) As Actor Ptr

End Namespace

#EndIf
