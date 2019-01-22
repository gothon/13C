#Include "actorbank.bi"

#Include "gamespace.bi"
#Include "debuglog.bi"
#Include "actordefs.bi"  
#Include "primitive.bi"
#Include "actortypes.bi"

DEFINE_PRIMITIVE_PTR(Actor)

Constructor ActorBank()
	''
End Constructor

Destructor ActorBank()
	DEBUG_ASSERT(parent_ = NULL)
	Dim As UInteger index = -1
	While(actors_.getNext(@index))
		act.deleteActor(actors_.get(index).getValue())
	Wend 
End Destructor

Constructor ActorBank(ByRef other As Const ActorBank) 'disallowed
	DEBUG_ASSERT(FALSE)
End Constructor

Operator ActorBank.Let(ByRef other As Const ActorBank) 'disallowed
	DEBUG_ASSERT(FALSE)
End Operator

Function ActorBank.clone() As ActorBank Ptr
	DEBUG_ASSERT(parent_ = NULL)
	Dim As ActorBank Ptr newBank = New ActorBank()
	Dim As UInteger index = -1
	While(actors_.getNext(@index))
		newBank->add(act.cloneActor(actors_.get(index), newBank))
	Wend
	Return newBank
End Function
	
Sub ActorBank.add(actor As act.Actor Ptr)
	DEBUG_ASSERT(actor->getParent() = @This)
	Dim As UInteger indexRet
	StaticList_ActorPtr_Emplace(actors_, indexRet, actor)
	actor->setParentRef(indexRet)
	If parent_ <> NULL Then bindIntoParent(actor)
End Sub

Sub ActorBank.remove(actor As act.Actor Ptr)
	actors_.remove(actor->getParentRef())
	If parent_ <> NULL Then unbindFromParent(actor)
	actor->setParent(NULL)
	Delete(actor)
End Sub

Sub ActorBank.bindIntoParent(actor As act.Actor Ptr)
	Dim As Gamespace Ptr gs = CPtr(Gamespace Ptr, parent_)
	gs->getDrawBuffer()->bind(act.getLightOrNull(actor))
	gs->getDrawBuffer()->bind(act.getModelOrNull(actor))
	gs->getSimulation()->add(CPtr(Collider Ptr, act.getColliderOrNull(actor)))
	gs->addGlobalActor(actor->getKey(), actor)
End Sub

Sub ActorBank.unbindFromParent(actor As act.Actor Ptr)
	Dim As Gamespace Ptr gs = CPtr(Gamespace Ptr, parent_)
	gs->getDrawBuffer()->unbind(act.getLightOrNull(actor))
	gs->getDrawBuffer()->unbind(act.getModelOrNull(actor))
	gs->getSimulation()->remove(CPtr(Collider Ptr, act.getColliderOrNull(actor)))
	gs->removeGlobalActor(actor->GetKey())
End Sub

Function ActorBank.getGlobalActor(key As Const ZString Ptr) As act.Actor Ptr
	DEBUG_ASSERT(parent_ <> NULL)
	Dim As Gamespace Ptr gs = CPtr(Gamespace Ptr, parent_)
	Return gs->getGlobalActor(key)
End Function

Sub ActorBank.transferIf(predicate As Function(As act.Actor Ptr) As Boolean, other As ActorBank Ptr)
	DEBUG_ASSERT(other->parent_ = NULL)
	DEBUG_ASSERT(parent_ = NULL)
	Dim As DArray_ActorPtr removeFromThis
	Dim As UInteger index = -1
	While actors_.getNext(@index)
		Dim As act.Actor Ptr actor = actors_.get(index)
		If Not predicate(actor) Then Continue While
		removeFromThis.push(actor)
	Wend

	For i As Integer = 0 To removeFromThis.size() - 1
		Dim As act.Actor Ptr actor = removeFromThis[i].getValue()
		actors_.remove(actor->getParentRef())
		actor->setParent(other)
		other->add(actor)
	Next i
End Sub
 	
Sub ActorBank.update(dt As Double)
	DEBUG_ASSERT(parent_ <> NULL)
	Dim As UInteger index = -1
	While(actors_.getNext(@index))
		Dim As act.Actor Ptr actor = actors_.get(index)
		If act.maybeUpdate(actor, dt) Then toRemove_.push(actor)
	Wend
End Sub

Sub ActorBank.project(ByRef proj As Const Projection)
	Dim As UInteger index = -1
	While(actors_.getNext(@index))
		Dim As QuadModelBase Ptr model = act.getModelOrNull(actors_.get(index))
		If model <> NULL Then projectQuadModelBase(model, proj)
	Wend	
End Sub

Sub ActorBank.purge()
	DEBUG_ASSERT(parent_ <> NULL)
	For i As Integer = 0 To toRemove_.size() - 1
		remove(toRemove_[i])
	Next i
	toRemove_.clear()
End Sub

Sub ActorBank.notify()
	DEBUG_ASSERT(parent_ <> NULL)	
	While toNotify_.size() > 0
		act.maybeNotify(toNotify_[0])
		Swap toNotify_.back(), toNotify_[0]
		toNotify_.pop()
	Wend
End Sub
 	
Const Function ActorBank.hasNotifyQueued() As Boolean
	Return toNotify_.size() <> 0 	
End Function
 	
Sub ActorBank.markForNotify(actor As act.Actor Ptr)
	toNotify_.push(actor)
End Sub
 	
Sub ActorBank.bindInto(parent As GamespaceFwd Ptr)
	DEBUG_ASSERT(parent_ = NULL)
	parent_ = parent
	Dim As Gamespace Ptr gs = CPtr(Gamespace Ptr, parent_)	
	Dim As UInteger index = -1
	While(actors_.getNext(@index))
		bindIntoParent(actors_.get(index))
	Wend	
End Sub

Sub ActorBank.unbindFrom()
	DEBUG_ASSERT(parent_ <> NULL)
	Dim As Gamespace Ptr gs = CPtr(Gamespace Ptr, parent_)	
	Dim As UInteger index = -1
	While(actors_.getNext(@index))
		unbindFromParent(actors_.get(index))
	Wend		
	parent_ = NULL
End Sub

Function ActorBank.size() As UInteger
	return actors_.size()
End Function
