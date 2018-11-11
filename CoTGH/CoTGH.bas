#Include "simpleaabbindex.bi"
#Include "aabb.bi"
#Include "vec2f.bi"

DECLARE_SIMPLEAABBINDEX(String)
DECLARE_DARRAY(SimpleAABBIndex_String_Element)

Dim As SimpleAABBIndex_String test
test.add(AABB(Vec2F(-1, -1), Vec2F(2, 2)), "Is it secret, is it safe?")
test.add(AABB(Vec2F(5, 5), Vec2F(5, 1.3)), "Unrelated tExt.")

Dim As DArray_SimpleAABBIndex_String_Element elements

test.query(AABB(Vec2F(-100, -100), Vec2F(200, 200)), @elements)

Print elements.size()
test.filter(AABB(Vec2F(-100, -100), Vec2F(100, 100)), @elements)


Print elements.size()
Print elements[0].x

Sleep
