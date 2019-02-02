#Include "fakestatue.bi"

#Include "../actortypes.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"
#Include "../debuglog.bi"

Namespace act
ACTOR_REQUIRED_DEF(FakeStatue, ActorTypes.FAKESTATUE)
	
Constructor FakeStatue(parent As ActorBankFwd Ptr)
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(16, 32), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {TextureCache.get("res/bhust.png")}
	Dim As QuadModel Ptr model = New QuadModel( _
			Vec3F(16, 32, 0), _
			QuadModelTextureCube(1, 0, 0, 0, 0), _
			uvIndex(), _
			tex(), _
			FALSE)
	Base.Constructor(parent, model)
	setType()
End Constructor
	
Function FakeStatue.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace