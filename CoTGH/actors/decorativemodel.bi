#Ifndef ACTORS_DECORATIVEMODEL_BI
#Define ACTORS_DECORATIVEMODEL_BI

#Include "../actor.bi"
#Include "../quadmodel.bi"

Namespace act
	
Type DecorativeModel Extends ModelActor
 Public:
  'Takes ownership of model
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	
	Declare Constructor(ByRef other As Const DecorativeModel) 'disallowed
  Declare Operator Let(ByRef other As Const DecorativeModel) 'disallowed
	
 	Declare Function clone() As Actor Ptr Override
End Type
	
End Namespace

#EndIf
