#Include "islandzone.bi"

#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"

Namespace act
ACTOR_REQUIRED_DEF(IslandZone, ActorTypes.ISLANDZONE)
	
Constructor IslandZone(parent As ActorBankFwd Ptr, bounds As AABB)
	Base.Constructor(parent)
	setType()
	
	This.bounds_ = bounds
End Constructor

Function IslandZone.update(dt As Double) As Boolean
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)	
	If player_->getBounds().intersects(bounds_) Then player_->setOnIsland()
	
	Return FALSE
End Function

Sub IslandZone.notify()
	''
End Sub

Function IslandZone.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Return New IslandZone(parent, bounds_)
End Function

End Namespace
