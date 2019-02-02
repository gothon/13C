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

Constructor DynamicModelActor()
	DEBUG_ASSERT(parent_ = NULL)
End Constructor

Constructor DynamicModelActor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	DEBUG_ASSERT(model <> NULL)
	Base.Constructor(parent)
	This.model_ = model
End Constructor

Virtual Destructor DynamicModelActor()
	deleteQuadModelBase(model_)
End Destructor

Function DynamicModelActor.getModel() As QuadModelBase Ptr
	Return model_
End Function

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

Constructor DynamicCollidingModelActor()
	DEBUG_ASSERT(parent_ = NULL)
End Constructor

Constructor DynamicCollidingModelActor( _
		parent As ActorBankFwd Ptr, _
		model As QuadModelBase Ptr, _
		colliderPtr As ColliderFwd Ptr)
	DEBUG_ASSERT(colliderPtr <> NULL)
	Base.Constructor(parent, model)
	This.collider_ = colliderPtr
	CPtr(Collider Ptr, This.collider_)->setParent(@This)
End Constructor

Virtual Destructor DynamicCollidingModelActor()
	deleteCollider(CPtr(Collider Ptr, collider_))
End Destructor

Function DynamicCollidingModelActor.getCollider() As ColliderFwd Ptr
	Return collider_
End Function

Constructor DynamicCollidingModelLightActor()
	DEBUG_ASSERT(parent_ = NULL)
End Constructor
  	
Constructor DynamicCollidingModelLightActor( _
		parent As ActorBankFwd Ptr, _
	  model As QuadModelBase Ptr, _
	  colliderPtr As ColliderFwd Ptr, _
	  l As Light Ptr)
	DEBUG_ASSERT(l <> NULL)	
	Base.Constructor(parent, model, colliderPtr)
	This.light_ = l
End Constructor

Virtual Destructor DynamicCollidingModelLightActor()
	Delete(light_)
End Destructor
	
Function DynamicCollidingModelLightActor.getLight() As Light Ptr
	Return light_
End Function

Function maybeUpdate(actorPtr As Actor Ptr, dt As Double) As Boolean
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_LIGHT
			Return CPtr(DecorativeLight Ptr, actorPtr)->update(dt)
		Case ActorTypes.PORTAL
			Return CPtr(Portal Ptr, actorPtr)->update(dt)
		Case ActorTypes.STAGEMANAGER
			Return CPtr(StageManager Ptr, actorPtr)->update(dt)
		Case ActorTypes.PLAYER
			Return CPtr(Player Ptr, actorPtr)->update(dt)
		Case ActorTypes.STATUE
			Return CPtr(Statue Ptr, actorPtr)->update(dt)	
		Case ActorTypes.PAINTING
			Return CPtr(Painting Ptr, actorPtr)->update(dt)		
		Case ActorTypes.CHANDELIER
			Return CPtr(Chandelier Ptr, actorPtr)->update(dt)
		Case ActorTypes.LEECHER
			Return CPtr(Leecher Ptr, actorPtr)->update(dt)			
		Case Else
			Return FALSE
	End Select
End Function

Sub maybeNotify(actorPtr As Actor Ptr)
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_LIGHT
			CPtr(DecorativeLight Ptr, actorPtr)->notify()
		Case ActorTypes.PORTAL
			CPtr(Portal Ptr, actorPtr)->notify()
		Case ActorTypes.STAGEMANAGER
			CPtr(StageManager Ptr, actorPtr)->notify()
		Case ActorTypes.PLAYER
			CPtr(Player Ptr, actorPtr)->notify() 		
		Case ActorTypes.STATUE
			CPtr(Statue Ptr, actorPtr)->notify() 		
		Case ActorTypes.PAINTING
			CPtr(Painting Ptr, actorPtr)->notify() 			
		Case ActorTypes.CHANDELIER
			CPtr(Chandelier Ptr, actorPtr)->notify() 
		Case ActorTypes.LEECHER
			CPtr(Leecher Ptr, actorPtr)->notify() 			
	End Select	
End Sub

Function getLightOrNull(actorPtr As Actor Ptr) As Light Ptr
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_LIGHT
			Return CPtr(DecorativeLight Ptr, actorPtr)->getLight() 
		Case ActorTypes.CHANDELIER
 			Return CPtr(Chandelier Ptr, actorPtr)->getLight()		
		Case Else
			Return NULL
	End Select
End Function

Function getModelOrNull(actorPtr As Actor Ptr) As QuadModelBase Ptr
	Select Case As Const actorPtr->getType()
		Case ActorTypes.DECORATIVE_MODEL
			Return CPtr(DecorativeModel Ptr, actorPtr)->getModel() 			
		Case ActorTypes.DECORATIVE_COLLIDER
			Return CPtr(DecorativeCollider Ptr, actorPtr)->getModel() 
		Case ActorTypes.PLAYER
			Return CPtr(Player Ptr, actorPtr)->getModel() 
		Case ActorTypes.STATUE
			Return CPtr(Statue Ptr, actorPtr)->getModel() 	
		Case ActorTypes.PAINTING
			Return CPtr(Painting Ptr, actorPtr)->getModel()
		Case ActorTypes.FAKESTATUE
			Return CPtr(FakeStatue Ptr, actorPtr)->getModel()		
		Case ActorTypes.CHANDELIER
 			Return CPtr(Chandelier Ptr, actorPtr)->getModel()	
		Case Else
			Return NULL
	End Select
End Function

Function getColliderOrNull(actorPtr As Actor Ptr) As ColliderFwd Ptr
	Select Case As Const actorPtr->getType()		
		Case ActorTypes.DECORATIVE_COLLIDER
			Return CPtr(DecorativeCollider Ptr, actorPtr)->getCollider() 
		Case ActorTypes.PLAYER
			Return CPtr(Player Ptr, actorPtr)->getCollider() 
		Case ActorTypes.STATUE
			Return CPtr(Statue Ptr, actorPtr)->getCollider() 	
		Case ActorTypes.CHANDELIER
 			Return CPtr(Chandelier Ptr, actorPtr)->getCollider()
		Case Else
			Return NULL
	End Select
End Function	
 
Sub DeleteActor(x As Actor Ptr)
 	Select Case As Const x->getType()
 		Case ActorTypes.DECORATIVE_LIGHT
			Delete(CPtr(DecorativeLight Ptr, x)) 		
 		Case ActorTypes.DECORATIVE_MODEL
			Delete(CPtr(DecorativeModel Ptr, x))	
 		Case ActorTypes.DECORATIVE_COLLIDER
			Delete(CPtr(DecorativeCollider Ptr, x))
 		Case ActorTypes.PORTAL
			Delete(CPtr(Portal Ptr, x))
 		Case ActorTypes.GRAPHINTERFACE
			Delete(CPtr(GraphInterface Ptr, x)) 		
 		Case ActorTypes.CAMERAINTERFACE
 			Delete(CPtr(CameraInterface Ptr, x)) 			
 		Case ActorTypes.DRAWBUFFERINTERFACE
 			Delete(CPtr(DrawBufferInterface Ptr, x)) 
 		Case ActorTypes.STAGEMANAGER
 			Delete(CPtr(StageManager Ptr, x)) 			
 		Case ActorTypes.TRANSITIONNOTIFIER
 			Delete(CPtr(TransitionNotifier Ptr, x))
 		Case ActorTypes.PLAYER
 			Delete(CPtr(Player Ptr, x)) 			
 		Case ActorTypes.SPAWN
 			Delete(CPtr(Spawn Ptr, x))
 		Case ActorTypes.SIMULATIONINTERFACE
			Delete(CPtr(SimulationInterface Ptr, x))
 		Case ActorTypes.STATUE
 			Delete(CPtr(Statue Ptr, x))		
 		Case ActorTypes.SNAPSHOTINTERFACE
 			Delete(CPtr(SnapshotInterface Ptr, x))		
 		Case ActorTypes.PAINTING
 			Delete(CPtr(Painting Ptr, x))		
 		Case ActorTypes.FAKESTATUE
 			Delete(CPtr(FakeStatue Ptr, x))
 		Case ActorTypes.ACTIVEBANKINTERFACE
 			Delete(CPtr(ActiveBankInterface Ptr, x)) 		
 		Case ActorTypes.CHANDELIER
 			Delete(CPtr(Chandelier Ptr, x)) 	
 		Case ActorTypes.LEECHER
 			Delete(CPtr(Leecher Ptr, x))
 		Case Else
			DEBUG_ASSERT(FALSE)
	End Select
End Sub

Function cloneActor(x As Actor Ptr, bank As ActorBankFwd Ptr) As Actor Ptr
 	Select Case As Const x->getType()
 		Case ActorTypes.DECORATIVE_LIGHT
			Return CPtr(DecorativeLight Ptr, x)->clone(bank)
 		Case ActorTypes.DECORATIVE_MODEL
			Return CPtr(DecorativeModel Ptr, x)->clone(bank)
 		Case ActorTypes.DECORATIVE_COLLIDER
			Return CPtr(DecorativeCollider Ptr, x)->clone(bank)
 		Case ActorTypes.PORTAL
			Return CPtr(Portal Ptr, x)->clone(bank)
 		Case ActorTypes.GRAPHINTERFACE
			Return CPtr(GraphInterface Ptr, x)->clone(bank)	
 		Case ActorTypes.CAMERAINTERFACE
 			Return CPtr(CameraInterface Ptr, x)->clone(bank)		
 		Case ActorTypes.DRAWBUFFERINTERFACE
 			Return CPtr(DrawBufferInterface Ptr, x)->clone(bank) 		
 		Case ActorTypes.PLAYER
 			Return CPtr(Player Ptr, x)->clone(bank)		
 		Case ActorTypes.SPAWN
 			Return CPtr(Spawn Ptr, x)->clone(bank) 		
 		Case ActorTypes.SIMULATIONINTERFACE
			Return CPtr(SimulationInterface Ptr, x)->clone(bank) 
 		Case ActorTypes.STATUE
 			Return CPtr(Statue Ptr, x)->clone(bank) 		
 		Case ActorTypes.SNAPSHOTINTERFACE
 			Return CPtr(SnapshotInterface Ptr, x)->clone(bank) 		
 		Case ActorTypes.PAINTING
 			Return CPtr(Painting Ptr, x)->clone(bank) 			
 		Case ActorTypes.FAKESTATUE
 			Return CPtr(FakeStatue Ptr, x)->clone(bank) 				
 		Case ActorTypes.ACTIVEBANKINTERFACE
 			Return CPtr(ActiveBankInterface Ptr, x)->clone(bank) 		 
 		Case ActorTypes.CHANDELIER
 			Return CPtr(Chandelier Ptr, x)->clone(bank) 		
 		Case ActorTypes.LEECHER
 			Return CPtr(Leecher Ptr, x)->clone(bank) 						
		Case Else
			DEBUG_ASSERT(FALSE)
	End Select	
End Function

End Namespace
