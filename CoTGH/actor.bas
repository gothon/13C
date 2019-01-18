#Include "actor.bi"

#Include "debuglog.bi"

Namespace act

DEFINE_PRIMITIVE_PTR(Actor)
 	 	
Constructor Actor(parent As ActorBankFwd Ptr)
	This.parent_ = parent
End Constructor
 	 	
Virtual Destructor Actor()
	DEBUG_ASSERT(refs_ = 0)
End Destructor
 	
Sub Actor.ref()
	refs_ += 1
End Sub
 	
Sub Actor.unref()
	DEBUG_ASSERT(refs_ > 0)
	refs_ -= 1
End Sub

Constructor DynamicActor(parent As ActorBankFwd Ptr)
	Actor.Constructor(parent)
End Constructor

Constructor ModelActor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	DEBUG_ASSERT(model <> NULL)
	Actor.Constructor(parent)
	This.model_ = model
End Constructor

Virtual Destructor ModelActor() Override
	Delete(model_)
End Destructor

Function ModelActor.getModel() As QuadModelBase Ptr
	Return model_
End Function

Constructor LightActor(parent As ActorBankFwd Ptr, light As Light Ptr)
	DEBUG_ASSERT(light <> NULL)
	DynamicActor.Constructor(parent)
	This.light_ = light
End Constructor

Virtual Destructor LightActor() Override
	Delete(model_)
End Destructor

Function ModelActor.getModel() As QuadModelBase Ptr
	Return light_
End Function

Constructor CollidingModelActor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, collider As ColliderFwd Ptr)
	DEBUG_ASSERT(collider <> NULL)
	ModelActor.Constructor(parent, model)
	This.collider_ = collider
	This.collider_->setParent(@This)
End Constructor

Virtual Destructor CollidingModelActor()
	Delete(collider_)
End Destructor

Function CollidingModelActor.getCollider() As ColliderFwd Ptr
	Return collider_
End Function
	