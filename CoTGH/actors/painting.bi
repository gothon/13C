#Ifndef ACTOR_PAINTING_BI
#Define ACTOR_PAINTING_BI

#Include "../actor.bi"
#Include "../aabb.bi"
#Include "../indexgraph.bi"
#Include "../vec3f.bi"

Namespace act
	
Type PaintingPlayerData
	As Vec2F p
	As Vec2F v
	As Double leadingX
	As LongInt musicPos
	As Boolean facingRight
	As UInteger embedId
End Type
	
Type Painting Extends DynamicModelActor
 Public:
 	ACTOR_REQUIRED_DECL(Painting)
 
	Declare Constructor(parent As ActorBankFwd Ptr, p As Vec3F)
	Declare Constructor( _
			parent As ActorBankFwd Ptr, _
			p As Vec3F, _
			fixedPath As String, _
			toMap As String, _
			ByRef toPos As Const Vec2F, _
			faceRight As Boolean)
	
	Declare Destructor()
	
	Declare Const Function isFixed() As Boolean
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Function updateInternal(dt As Double) As Boolean
 
 	As Double z_ = Any 'const 
 	As AABB box_ = Any 'const
 	As Boolean hasSnapshot_
 	As PaintingPlayerData playerData_ = Any
 	As Image32 Ptr paintingImage_ = Any
 	As Image32 Ptr updatedImage_ = Any
 	As Const Image32 Ptr frameImage_ = Any
 	As Const Image32 Ptr emptyImage_ = Any
 	As Integer warpCountdown_ = Any
 	
 	As Boolean fixed_ = Any
 	As String toMap_
End Type

End Namespace

#EndIf