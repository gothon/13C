#Ifndef INDEXGRAPH_BI
#Define INDEXGRAPH_BI

#inclib "isg"

Type ig_GraphBuilder As Any Ptr
Type ig_IndexGraph As Any Ptr
Type ig_Index As Any Ptr

Type ig_Data
	As UInteger size
	As Any Ptr raw
End Type

Extern "C"

Declare Function ig_CreateGraphBuilder() As ig_GraphBuilder

Declare Sub ig_DeleteGraphBuilder(graph_builder As ig_GraphBuilder Ptr)

Declare Sub ig_AddBaseToBuilder(graph_builder As ig_GraphBuilder, key As Const ZString Ptr, _
                                ByVal sc As ig_Data, ByVal c As ig_Data)
                                
Declare Function ig_Build(graph_builder As ig_GraphBuilder Ptr) As ig_IndexGraph
Declare Sub ig_DeleteGraph(graph As ig_IndexGraph Ptr)

Declare Function ig_GetVersionN(graph As Const ig_IndexGraph) As UInteger

Declare Function ig_CreateIndex(graph As ig_IndexGraph, key As Const ZString Ptr) As ig_Index
Declare Function ig_CloneIndex(index As ig_Index) As ig_Index
Declare Sub ig_DeleteIndex(index As ig_Index Ptr)
Declare Sub ig_ConsumeIndex(dest As ig_Index, src As ig_Index Ptr)

Declare Function ig_Embed(index As ig_Index, to_embed As ig_Index Ptr) As UInteger
Declare Sub ig_Unembed(index As ig_Index, elem As UInteger)

Declare Function ig_IndexFromEmbedded(index As ig_Index, elem As UInteger) As ig_Index

Declare Function ig_GetKey(index As Const ig_Index) As Const ZString Ptr

Declare Function ig_GetSharedContent(index As Const ig_Index) As ig_Data
Declare Sub ig_SetSharedContent(index As ig_Index, sc As ig_Data)

Declare Function ig_GetContent(index As Const ig_Index) As ig_Data
Declare Sub ig_SetContent(index As ig_Index, c As ig_Data)

Declare Sub ig_Go(index As ig_Index, key As Const ZString Ptr)

End Extern
#EndIf
