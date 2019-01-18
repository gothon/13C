#Ifndef GAMESPACE_BI
#Define GAMESPACE_BI

#Include "quaddrawbuffer.bi"
#Include "physics.bi"
#Include "actorbank.bi"
#Include "cameracontroller.bi"
#Include "image32.bi"
#Include "projection.bi"

Type Gamespace
	
	Declare Constructor(ByRef proj As Const Projection)
	Declare Destructor()
	
	Declare Sub update(dt As Double)
	Declare Sub draw(dest As Image32 Ptr) 
	
	Declare Sub 
	
 Private:
  
  As QuadDrawBuffer drawBuffer_
  As Simulation sim_
  As CameraController camera_
  
  As ActorBank Ptr globalBank_
    
  As ActorBank Ptr activeBank_
  As ActorBank Ptr staticBank_
End Type

#EndIf
