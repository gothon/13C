#Include "spawn.bi"

Namespace act
ACTOR_REQUIRED_DEF(Spawn, ActorTypes.SPAWN)
	
Constructor Spawn(parent As ActorBankFwd Ptr, p As Vec2F)
	Base.Constructor(parent)
	setType()

	setKey("SPAWN")
	
	This.p_ = p
End Constructor

Const Function Spawn.getP() As Vec2F
	Return p_
End Function

Function Spawn.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Return New Spawn(parent, p_)
End Function

End Namespace
