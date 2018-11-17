#Include "hashmap.bi"

#Include "texturecache.bi"
#Include "simpletagindex.bi"

dsm_HashMap_define(ZString, Image32Ptr)
dsm_HashMap_implement(ZString, Image32Ptr)

DECLARE_SIMPLETAGINDEX(String)
dsm_HashMap_define(ZString, DArray_SimpleTagIndex_String_Element)
dsm_HashMap_implement(ZString, DArray_SimpleTagIndex_String_Element)
