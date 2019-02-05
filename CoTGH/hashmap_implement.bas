#Include "hashmap.bi"

#Include "texturecache.bi"
#Include "tilesetcache.bi"
#Include "primitive.bi"
#Include "actorbank.bi"

dsm_HashMap_define(ZString, ConstZStringPtr)
dsm_HashMap_implement(ZString, ConstZStringPtr)

dsm_HashMap_define(ZString, Image32Ptr)
dsm_HashMap_implement(ZString, Image32Ptr)

dsm_HashMap_define(ZString, TilesetPtr)
dsm_HashMap_implement(ZString, TilesetPtr)

dsm_HashMap_define(ZString, ActorPtr)
dsm_HashMap_implement(ZString, ActorPtr)

dsm_HashMap_define(ZString, Integer_)
dsm_HashMap_implement(ZString, Integer_)
