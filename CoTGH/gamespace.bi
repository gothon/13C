#Ifndef GAMESPACE_BI
#Define GAMESPACE_BI

#Include "quaddrawbuffer.bi"
#Include "physics.bi"
#Include "actorbank.bi"
#Include "cameracontroller.bi"
#Include "graphwrapper.bi"
#Include "image32.bi"
#Include "hashmap.bi"
#Include "actordefs.bi"

dsm_HashMap_define(ZString, ActorPtr)

Type Gamespace
 Public:
	Declare Constructor( _
			camera As CameraController Ptr, _
			graph As GraphWrapper Ptr, _
			target As Image32 Ptr, _
			globalBank As ActorBank Ptr)
	Declare Destructor()
	
	Declare Sub init(stage As Const ZString Ptr)
	
	Declare Sub update(dt As Double)
	Declare Sub draw() 
	
	Declare Function getDrawBuffer() As QuadDrawBuffer Ptr
	Declare Function getSimulation() As Simulation Ptr
	
	Declare Sub addGlobalActor(key As Const ZString Ptr, actor As act.Actor Ptr)
	Declare Function getGlobalActor(key As Const ZString Ptr) As act.Actor Ptr
	Declare Sub removeGlobalActor(key As Const ZString Ptr)
	
	Declare Sub go(key As Const ZString Ptr)
	Declare Sub go(index As ig_Index Ptr)
	
	Declare Sub requestEmbed(index As ig_Index, existingEmbed As UInteger, indexToUpdate As UInteger Ptr)
	
	Declare Function unembedToIndex(ref As UInteger) As ig_Index
	Declare Function clone() As ig_Index
	Declare Sub deleteIndex(index As ig_Index Ptr)
	
 Private:
	Declare Sub addSystemActors()
	Declare Sub embed()
	
	As act.GraphInterface Ptr graphInterfaceActor_ = NULL
	As act.CameraInterface Ptr cameraInterfaceActor_ = NULL
	
	As ig_Index indexToEmbed_ = Any
	As UInteger existingEmbed_ = Any
	As UInteger Ptr indexToUpdate_ = Any
	
	As Boolean transitionOccured_
		
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
