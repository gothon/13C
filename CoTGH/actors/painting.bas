#Include "painting.bi"

#Include "../actortypes.bi"
#Include "../actor.bi"
#Include "../actordefs.bi"
#Include "../aabb.bi"
#Include "../indexgraph.bi"
#Include "../vec3f.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"
#Include "../actorbank.bi"

Namespace act
ACTOR_REQUIRED_DEF(Painting, ActorTypes.PAINTING)

Const As UInteger PAINTING_W = 64
Const As UInteger PAINTING_H = 48

Const As UInteger INTERSECT_BUFFER_X = 4
Const As UInteger INTERSECT_BUFFER_Y = 0

Function createModel(srcImage As Image32 Ptr) As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(PAINTING_W, PAINTING_H), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {srcImage}
	Return New QuadModel(Vec3F(PAINTING_W, PAINTING_H, 0), QuadModelTextureCube(1, 0, 0, 0, 0), uvIndex(), tex())
End Function
	
Constructor Painting(parent As ActorBankFwd Ptr, p As Vec3F)
	This.paintingImage_ = New Image32(64, 48)
	This.updatedImage_ = New Image32(64, 48)
	Base.Constructor(parent, createModel(updatedImage_))
	setType()
	model_->translate(p + Vec3F(0, 0, -8))
	
	This.emptyImage_ = TextureCache.get("res/emptyframe.png")
	This.frameImage_ = TextureCache.get("res/paintingframe.png")
	This.z_ = p.z
	This.box_ = AABB(Vec2F(p.x, p.y), Vec2F(PAINTING_W, PAINTING_H))
	This.hasSnapshot_ = FALSE
	This.playerData_.embedId = -1

	Put This.paintingImage_->fbImg(), (0, 0), This.emptyImage_->constFbImg(), PSET
End Constructor

Virtual Destructor Painting()
	Delete(paintingImage_)
	Delete(updatedImage_)
End Destructor

Function Painting.updateInternal(dt As Double) As Boolean
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	
	Dim As AABB bounds = box_
	bounds.o += Vec2F(INTERSECT_BUFFER_X, INTERSECT_BUFFER_Y)
	bounds.s -= 2*Vec2F(INTERSECT_BUFFER_X, INTERSECT_BUFFER_Y)
	
	If Not player_->getBounds().intersects(bounds) Then Return FALSE
	
	Dim As GraphInterface Ptr graph = @GET_GLOBAL("GRAPH INTERFACE", GraphInterface)
	
	If hasSnapshot_ AndAlso player_->pressedDown() Then 
		player_->disableCollision()
		player_->setWarp(playerData_.p, playerData_.v, playerData_.leadingX, playerData_.musicPos, playerData_.facingRight)
		graph->requestGoIndex(graph->unembedToIndex(playerData_.embedId))
		Return FALSE
	EndIf	
	
	If Not player_->hasSnapshot() Then Return FALSE
	
	If player_->pressedActivate() Then 
		player_->placeSnapshot(playerData_.embedId)
		Return FALSE
	End If 
	
	If Not player_->readyToPlace() Then Return FALSE
	
	hasSnapshot_ = TRUE
	
	Dim As Image32 Ptr image = Any
	player_->claimSnapshot( _
			@(playerData_.embedId), _
			@image, _
			@(playerData_.p), _
		  @(playerData_.v), _
		  @(playerData_.leadingX), _
		  @(playerData_.musicPos), _
		  @(playerData_.facingRight))
	
	Put paintingImage_->fbImg(), (0, 0), image->fbImg(), PSet
	Put paintingImage_->fbImg(), (0, 0), frameImage_->constFbImg(), Trans	
		
	Delete(image)

	Return FALSE
End Function
 	

Function Painting.update(dt As Double) As Boolean
	Dim As boolean retValue = updateInternal(dt)
	
	Put updatedImage_->fbImg(), (0, 0), paintingImage_->constFbImg(), PSET	
	
	If hasSnapshot_ Then 
		Dim As Pixel32 Ptr pixels = updatedImage_->pixels()
		For y As UInteger = 8 To updatedImage_->h() - 9
			For x As UInteger = 8 To updatedImage_->w() - 9
				Dim As Pixel32 Ptr col = @(pixels[y*updatedImage_->w() + x]) 'const
				
				Dim As Integer r = col->r
				Dim As Integer g = col->g
				Dim As Integer b = col->b + Int(Rnd * 50) - 25
				If b < 0 Then 
					b = 0
				ElseIf b > 255 Then
					b = 255
				EndIf
			
				*col = Pixel32(r, g, b)
			Next x
		Next y
	EndIf 
	
	Return FALSE
End Function

Sub Painting.notify()
	''
End Sub
 	
Function Painting.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As Painting Ptr newPainting = New Painting(parent, Vec3F(box_.o.x, box_.o.y, z_))
	newPainting->playerData_ = playerData_
	newPainting->hasSnapshot_ = hasSnapshot_
	Put newPainting->paintingImage_->fbImg(), (0, 0), paintingImage_->fbImg(), PSet
	Put newPainting->updatedImage_->fbImg(), (0, 0), paintingImage_->fbImg(), PSET	
	Return newPainting
End Function

End Namespace
