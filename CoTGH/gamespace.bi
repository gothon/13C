#Ifndef GAMESPACE_BI
#Define GAMESPACE_BI

#Include "quaddrawbuffer.bi"
#Include "physics.bi"
#Include "actorbank.bi"
#Include "cameracontroller.bi"
#Include "graphwrapper.bi"
#Include "image32.bi"
#Include "hashmap.bi"

dsm_HashMap_define(ZString, ActorPtr)

Type Gamespace
 Public:
	Declare Constructor( _
			camera As CameraController Ptr, _
			graph As GraphWrapper Ptr, _
			target As Image32 Ptr, _
			globalBank As ActorBank Ptr, _
			timeStep As Double)
	Declare Destructor()
	
	Declare Sub init(stage As Const ZString Ptr)
	
	Declare Sub update(dt As Double)
	Declare Sub draw() 
	
	Declare Function getDrawBuffer() As QuadDrawBuffer Ptr
	Declare Function getSimulation() As Simulation Ptr
	
	''DISALLOW KEY CLASH, IGNORE IF NULL ON ADD/REMOVE, COMPLAIN IF DOESN'T EXIST
	Declare Sub addGlobalActor(key As Const ZString Ptr, actor As act.Actor Ptr)
	Declare Function getGlobalActor(key As Const ZString Ptr) As act.Actor Ptr
	Declare Sub removeGlobalActor(key As Const ZString Ptr)
	
 Private:
  As QuadDrawBuffer drawBuffer_
  As Simulation sim_
  As dsm.HashMap(ZString, ActorPtr) globals_
  
  As CameraController Ptr camera_ = NULL
  As GraphWrapper Ptr graph_ = NULL
  
  As Image32 Ptr target_ = NULL
  
  As Double timeStep_ = 0.0
  
  As ig_Index primaryIndex_ = NULL
  
  As ActorBank Ptr globalBank_ = NULL
    
  As ActorBank Ptr activeBank_ = NULL
  As ActorBank Ptr staticBank_ = NULL
End Type

#EndIf
