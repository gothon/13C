#Ifndef MAPUTILS_BI
#Define MAPUTILS_BI

#Include "physics.bi"
#Include "quadmodel.bi"
#Include "light.bi"
#Include "darray.bi"

DECLARE_DARRAY(QuadModelBasePtr)
DECLARE_DARRAY(LightPtr)

Namespace maputils
	
Type ParseResult
	As BlockGrid Ptr blockGrid
	As DArray_QuadModelBasePtr models
	As DArray_LightPtr lights
End Type

Declare Function parseMap(tmxPath As Const ZString Ptr) As ParseResult
	
End Namespace

#EndIf
