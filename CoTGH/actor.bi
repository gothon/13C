#Ifndef ACTOR_BI
#Define ACTOR_BI

#Include "quadmodel.bi"
#Include "light.bi"
#Include "primitive.bi"


Type ActorBankFwd As ActorBank
Type ColliderFwd As Collider 

Type Actor Extends Object
 Public:
 	Declare Virtual Destructor()
 	
 	Declare Constructor(ByRef rhs As Const Actor) 'disallowed
  Declare Operator Let(ByRef rhs As Const Actor) 'disallowed
 	
 	Declare Virtual Function update(t As Single) As Boolean
 	
 	Declare Sub ref()
 	Declare Sub unref()
 Private:
 	
 	As ActorBankFwd Ptr parent_ = NULL
 	As QuadModel Ptr model_ = NULL
 	As Light Ptr light_ = NULL
 	As ColliderFwd Ptr collision_ = NULL
 	
 	As UInteger refs_ = 0
End Type

DECLARE_PRIMITIVE_PTR(Actor)

#EndIf
