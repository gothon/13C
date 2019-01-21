#Ifndef GRAPHWRAPPER_BI
#Define GRAPHWRAPPER_BI

#Include "actorbank.bi"
#Include "indexgraph.bi"

Type GraphWrapper
 Public:
 	Declare Constructor(entryMap As Const ZString Ptr)
 	Declare Destructor()
	
	Declare Function getGraph() As ig_IndexGraph
	Declare Sub compact()
	 	
 Private:
 	Declare Static Function separateIntoSharedBank(bank As ActorBank Ptr) As ActorBank Ptr
 	Declare Static Sub addActorsToBuilder( _
 			builder As ig_GraphBuilder, _
 			stageName As Const ZString Ptr, _
 			bank As ActorBank Ptr)
 
 	As ig_IndexGraph indexGraph_ = NULL
End Type

#EndIf
