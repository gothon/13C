#Ifndef ACTORS_DECORATIVECOLLIDER_BI
#Define ACTORS_DECORATIVECOLLIDER_BI

#Include "../actor.bi"
#Include "../quadmodel.bi"
#Include "../physics.bi"

Type DecorativeCollider Extends CollidingModelActor
 Public:
  'Takes ownership of model
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, collider As Collider Ptr)
	
	Declare Constructor(ByRef other As Const DecorativeCollider) 'disallowed
  Declare Operator Let(ByRef other As Const DecorativeCollider) 'disallowed
	
 	Declare Function clone() As Actor Ptr Override
End Type

#EndIf
