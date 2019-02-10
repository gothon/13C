#Include "menucontroller.bi"

#Include "../actortypes.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"
#Include "../debuglog.bi"
#Include "../actordefs.bi"
#Include "../actorbank.bi"

Namespace act
ACTOR_REQUIRED_DEF(MenuController, ActorTypes.MENUCONTROLLER)
	
Constructor MenuController(parent As ActorBankFwd Ptr, ByRef bounds As Const AABB)
	Base.Constructor(parent)
	setType()
	
	This.bounds_ = bounds
End Constructor
	
Function MenuController.update(dt As Double) As Boolean
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	player_->setCameraRelease(TRUE)
	player_->getModel()->hide()

	Dim As CameraInterface Ptr camera = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
	camera->snap(bounds_.o + bounds_.s*0.5 + Vec2F(-1, 25), 0)	
	
	Return FALSE
End Function

Sub MenuController.notify()
	''
End Sub
	
Function MenuController.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace