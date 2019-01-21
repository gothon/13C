#Ifndef ACTORBANK_BI
#Define ACTORBANK_BI

#Include "actor.bi"
#Include "darray.bi"
#Include "staticlist.bi"
#Include "physics.bi"
#Include "quaddrawbuffer.bi"
#Include "primitive.bi"
#Include "projection.bi"

Type Actor As act.Actor
DECLARE_PRIMITIVE_PTR(Actor)

DECLARE_DARRAY(ActorPtr)
DECLARE_STATICLIST(ActorPtr)

Type GamespaceFwd As Any

Type ActorBank
 Public:
 	Declare Constructor()
 	Declare Destructor()
 	
 	Declare Sub bindInto(parent As GamespaceFwd Ptr)
 	Declare Sub unbindFrom()
 	
	Declare Constructor(ByRef other As Const ActorBank) 'disallowed
  Declare Operator Let(ByRef other As Const ActorBank) 'disallowed
	Declare Function clone() As ActorBank Ptr
 	Declare Sub remove(actor As act.Actor Ptr)
 	
 	Declare Sub update(dt As Double)
 	Declare Sub notify()
	Declare Sub purge()
 	Declare Sub project(ByRef proj As Const Projection)
 	 	
 	Declare Sub transferIf(predicate As Function(As act.Actor Ptr) As Boolean, other As ActorBank Ptr)
 	
 	Declare Function size() As UInteger
 	Declare Const Function hasNotifyQueued() As Boolean

 	'------------------ STUFF ITS OKAY FOR ACTORS TO CALL ON THEIR PARENT -------------------
 	Declare Sub markForNotify(actor As act.Actor Ptr)
 	Declare Sub add(actor As act.Actor Ptr)
 	Declare Function getGlobalActor(key As Const ZString Ptr) As act.Actor Ptr
 	'----------------------------------------------------------------------------------------
 	 	
 Private:
 	Declare Sub bindIntoParent(actor As act.Actor Ptr)
 	Declare Sub unbindFromParent(actor As act.Actor Ptr)
 
 	As DArray_ActorPtr toNotify_
 	As DArray_ActorPtr toRemove_
 	As StaticList_ActorPtr actors_

	As GamespaceFwd Ptr parent_ = NULL
End Type

#EndIf
