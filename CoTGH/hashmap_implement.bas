#Include "hashmap.bi"

#Include "image32.bi"

Type Image32Ptr As Image32 Ptr 
dsm_HashMap_define(ZString, Image32Ptr)
dsm_HashMap_implement(ZString, Image32Ptr)
