#Ifndef MAPUTILS_BI
#Define MAPUTILS_BI

#Include "physics.bi"
#Include "quadmodel.bi"

Namespace maputils
	
Type ParseResult
	As physics.BlockGrid Ptr blockGrid
	As QuadModelBase Ptr model
End Type

Declare Function parseMap(tmxPath As Const ZString Ptr) As ParseResult
	
End Namespace

#EndIf
