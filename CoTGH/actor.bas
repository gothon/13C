#Include "actor.bi"

#Include "debuglog.bi"
#Include "physics.bi"
#Include "util.bi"
#Include "actortypes.bi"
#Include "actordefs.bi"

Namespace act
 	 
Constructor Actor()
	''
End Constructor
 	 	
Constructor Actor(parent As ActorBankFwd Ptr)
	DEBUG_ASSERT(parent <> NULL)
	This.parent_ = parent
End Constructor
 	 	
Virtual Destructor Actor()
	If key_ <> NULL Then DeAllocate(key_)
End Destructor

Sub Actor.setParent(parent As ActorBankFwd Ptr)
	parent_ = parent
End Sub

Function Actor.getParent() As ActorBankFwd Ptr
	Return parent_
End Function

Sub Actor.setParentRef(parentRef As UInteger)
	DEBUG_ASSERT(parentRef <> -1)
	parentRef_ = parentRef
End Sub

Function Actor.getParentRef() As UInteger
	Return parentRef_
End Function

Sub Actor.setKey(key As Const ZString Ptr)
	If key_ <> NULL Then DeAllocate(key_)
	key_ = NULL
	If key = NULL Then Return
	key_ = util.cloneZString(key)
End Sub

Function Actor.getKey() As Const ZString Ptr
	Return key_
End Function

Const Function Actor.getType() As ActorTypes
	Return actorType_
End Function

Constructor DynamicActor()
	DEBUG_ASSERT(parent_ = NULL)
End Constructor

Constructor DynamicActor(parent As ActorBankFwd Ptr)
	Base.Constructor(parent)
End Constructor

Virtual Destructor DynamicActor()
	'' 
End Destructor 

Constructor ModelActor()
	DEBUG_ASSERT(parent_ = NULL)
End Constructor

Constructor ModelActor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	DEBUG_ASSERT(model <> NULL)
	Base.Constructor(parent)
	This.model_ = model
End Constructor

Virtual Destructor ModelActor()
	deleteQuadModelBase(model_)
End Destructor

Function ModelActor.getModel() As QuadModelBase Ptr
	Return model_
End Function

Constructor LightActor()
	DEBUG_ASSERT(parent_ = NULL)
End Constructor

Constructor LightActor(parent As ActorBankFwd Ptr, light As Light Ptr)
	DEBUG_ASSERT(light <> NULL)
	Base.Constructor(parent)
	This.light_ = light
End Constructor

Virtual Destructor LightActor()
	Delete(light_)
End Destructor

Function LightActor.getLight() As Light Ptr
	Return light_
End Function

Constructor CollidingModelActor()
	DEBUG_ASSERT(parent_ = NULL)
End Constructor

Constructor CollidingModelActor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, colliderPtr As ColliderFwd Ptr)
	DEBUG_ASSERT(colliderPtr <> NULL)
	Base.Constructor(parent, model)
	This.collider_ = colliderPtr
	CPtr(Collider Ptr, This.collider_)->setParent(@This)
End Constructor

Virtual Destructor CollidingModelActor()
	deleteCollider(CPtr(Collider Ptr, collider_))
End Destructor

Function CollidingModelActor.getCollider() As ColliderFwd Ptr
	Return collider_
End Function

Function maybeUpdate(actorPtr As Actor Ptr, dt As Double) As Boolean
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_LIGHT
			Return CPtr(act.DecorativeLight Ptr, actorPtr)->update(dt)
		Case ActorTypes.PORTAL
			Return CPtr(act.Portal Ptr, actorPtr)->update(dt)
		Case Else
			Return FALSE
	End Select
End Function

Sub maybeNotify(actorPtr As Actor Ptr)
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_LIGHT
			CPtr(act.DecorativeLight Ptr, actorPtr)->notify()
		Case ActorTypes.PORTAL
			CPtr(act.Portal Ptr, actorPtr)->notify()
	End Select	
End Sub

Function getLightOrNull(actorPtr As Actor Ptr) As Light Ptr
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_LIGHT
			Return CPtr(LightActor Ptr, actorPtr)->getLight() 
		Case Else
			Return NULL
	End Select
End Function

Function getModelOrNull(actorPtr As Actor Ptr) As QuadModelBase Ptr
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_MODEL
			Return CPtr(ModelActor Ptr, actorPtr)->getModel() 			
		Case ActorTypes.DECORATIVE_COLLIDER
			Return CPtr(ModelActor Ptr, actorPtr)->getModel() 
		Case Else
			Return NULL
	End Select
End Function

Function getColliderOrNull(actorPtr As Actor Ptr) As ColliderFwd Ptr
	Select Case As Const actorPtr->getType()		
		Case ActorTypes.DECORATIVE_COLLIDER
			Return CPtr(CollidingModelActor Ptr, actorPtr)->getCollider() 
		Case Else
			Return NULL
	End Select
End Function	
 
Sub DeleteActor(x As Actor Ptr)
 	Select Case As Const x->getType()
 		Case act.ActorTypes.DECORATIVE_LIGHT
			Delete(CPtr(act.DecorativeLight Ptr, x)) 		
 		Case act.ActorTypes.DECORATIVE_MODEL
			Delete(CPtr(act.DecorativeModel Ptr, x))	
 		Case act.ActorTypes.DECORATIVE_COLLIDER
			Delete(CPtr(act.DecorativeCollider Ptr, x))
 		Case act.ActorTypes.PORTAL
			Delete(CPtr(act.Portal Ptr, x))
		Case Else
			DEBUG_ASSERT(FALSE)
	End Select
End Sub
 	
End Namespace
