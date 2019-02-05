#ifndef HASHMAP_BI
#define HASHMAP_BI

#Include "null.bi"

'from dsm\dsmstd.bi
namespace dsm

    enum bool
        false = 0
        true = 1
    end enum
    type char as ubyte
    type size_t as ulong

end namespace

#define HASHMAP_CONTIGUOUS_BLOCK_N 4
#define HASHMAP_INITIAL_ROW_N 8
#define HASHMAP_SPLIT_RATIO 0.8
#define HASHMAP_COMPACT_RATIO 0.2

namespace dsm
    #macro HASHMAP_DELETION_LOGIC()
        for j = i to start - 1
            cur_row->slots(j) = cur_row->slots(j + 1)
        next j
        cur_row->size -= 1
        if cur_row->size = 0 then
            if last_row then
                last_row->next_block = cur_row->next_block
                deallocate(cur_row)
            else
                if cur_row->next_block then
                    *(cur_row) = *(cur_row->next_block)
                end If
            end if
        end if
        used_size -= 1
        return false
    #endmacro
    ' -------------------------- LONG ----------------------------
    #macro HASHMAP_long_STORAGE_DATA()
        key as long
    #endmacro
    #macro HASHMAP_long_DESTRUCT_LOGIC()
        for j = 0 to cur_block->size - 1
            cur_block->slots(j).data_.Destructor()
        next j 
    #endmacro
    #macro HASHMAP_long_INSERTION_LOGIC()
        .key = _key
    #endmacro
    #macro HASHMAP_long_DELETION_LOGIC()
        if _key = cur_row->slots(i).key then
            HASHMAP_DELETION_LOGIC()
        end if
    #endmacro
    #macro HASHMAP_long_EXISTS_LOGIC()
        if _key = cur_row->slots(i).key then return true
    #endmacro
    #macro HASHMAP_long_RETRIEVE_LOGIC()
        if _key = cur_row->slots(i).key then
            _item = cur_row->slots(i).data_
            return true
        end if
    #endmacro
    #macro HASHMAP_long_RETRIEVE_R_LOGIC()
        if _key = cur_row->slots(i).key then
            return cur_row->slots(i).data_
        end if
    #endmacro   
    #macro HASHMAP_long_RETRIEVE_R_PTR_LOGIC()
        if _key = cur_row->slots(i).key then
            return @(cur_row->slots(i).data_)
        end if
    #endmacro 
    #macro HASHMAP_long_CALC_NEW_POS(_KEYTYPE_, _INDEX_)
        new_pos = hash_##_KEYTYPE_(this, cur_row->slots(_INDEX_).key)
    #endmacro
    #macro HASHMAP_DECLARE_HASH_WRAP_long(_KEYTYPE_, _TYPENAME_)
    declare const function hash_wrap_long naked cdecl _
    ( _
        byref _table as const HashMap_##_KEYTYPE_##_TYPENAME_, _
        _key as long _
    ) as size_t   
    #endmacro
    #macro HASHMAP_DEFINE_HASH_WRAP_long(_KEYTYPE_, _TYPENAME_)
    const function HashMap_##_KEYTYPE_##_TYPENAME_.hash_wrap_long naked cdecl _
    ( _
        byref _table as const HashMap_##_KEYTYPE_##_TYPENAME_, _
        _key as long _
    ) as size_t
        asm
        #ifdef __FB_64BIT__
                mov     rcx,                    &h890390f1daf308c
                mov     rax,                    qword ptr [rsp+16]
                shr     qword ptr [rsp+16],     32
                xor     rax,                    qword ptr [rsp+16]
                mul     rcx
        #ifndef HASHMAP_FAST
                mov     qword ptr [rsp+16],     rax
                shr     qword ptr [rsp+16],     32
                xor     rax,                    qword ptr [rsp+8]
                mul     rcx
        #endif
                mov     qword ptr [rsp+16],     rax
                shr     qword ptr [rsp+16],     32
                xor     rax,                    qword ptr [rsp+16]
                mov     rcx,                    qword ptr [rsp+8]
                mov     rdx,                    rax
                and     rax,                    qword ptr [rcx+40]
                cmp     rax,                    qword ptr [rcx+8]
                jl      dsm_hashmap_hashw_long_upperlevel_64
                ret
            dsm_hashmap_hashw_long_upperlevel_64:
                and     rdx,                    qword ptr [rcx+48]
                mov     rax,                    rdx
                ret
        #else
                mov     ecx,                    &h45D9F3B
                mov     eax,                    dword ptr [esp+8]
                shr     dword ptr [esp+8],      16
                xor     eax,                    dword ptr [esp+8]
                mul     ecx
        #ifndef HASHMAP_FAST
                mov     dword ptr [esp+8],      eax
                shr     dword ptr [esp+8],      16
                xor     eax,                    dword ptr [esp+8]
                mul     ecx
        #endif
                mov     dword ptr [esp+8],      eax
                shr     dword ptr [esp+8],      16
                xor     eax,                    dword ptr [esp+8]
                mov     ecx,                    dword ptr [esp+4]
                mov     edx,                    eax
                and     eax,                    dword ptr [ecx+20]
                cmp     eax,                    dword ptr [ecx+4]
                jl      dsm_hashmap_hashw_long_upperlevel_32
                ret
            dsm_hashmap_hashw_long_upperlevel_32:
                and     edx,                    dword ptr [ecx+24]
                mov     eax,                    edx
                ret
        #endif       
        end asm
    end Function
    #endmacro
    #macro HASHMAP_DECLARE_HASH_long(_KEYTYPE_, _TYPENAME_)
    declare const function hash_long naked cdecl _
    ( _
        _key as long _
    ) as size_t   
    #endmacro
    #macro HASHMAP_DEFINE_HASH_long(_KEYTYPE_, _TYPENAME_)
    const function HashMap_##_KEYTYPE_##_TYPENAME_.hash_long naked cdecl _
    ( _
        _key as long _
    ) as size_t
        asm
        #ifdef __FB_64BIT__
                mov     rcx,                    &h890390f1daf308c
                mov     rax,                    qword ptr [rsp+8]
                shr     qword ptr [rsp+8],      32
                xor     rax,                    qword ptr [rsp+8]
                mul     rcx
        #ifndef HASHMAP_FAST
                mov     qword ptr [rsp+8],      rax
                shr     qword ptr [rsp+8],      32
                xor     rax,                    qword ptr [rsp+8]
                mul     rcx
        #endif
                mov     qword ptr [rsp+8],      rax
                shr     qword ptr [rsp+8],      32
                xor     rax,                    qword ptr [rsp+8]
                ret
        #else
                mov     ecx,                    &h45D9F3B
                mov     eax,                    dword ptr [esp+4]
                shr     dword ptr [esp+4],      16
                xor     eax,                    dword ptr [esp+4]
                mul     ecx
        #ifndef HASHMAP_FAST
                mov     dword ptr [esp+4],      eax
                shr     dword ptr [esp+4],      16
                xor     eax,                    dword ptr [esp+4]
                mul     ecx
        #endif
                mov     dword ptr [esp+4],      eax
                shr     dword ptr [esp+4],      16
                xor     eax,                    dword ptr [esp+4]
                ret
        #endif       
        end asm         
    end Function
    #endmacro
    ' -------------------------- ZSTRING ----------------------------
    #define HASHMAP_zstring_BUFFER_N 32
    #macro HASHMAP_zstring_STORAGE_DATA()
        is_contiguous as bool
        union
            key_internal as zstring * HASHMAP_zstring_BUFFER_N
            key_external as zstring ptr
        end union
    #endmacro
    #macro HASHMAP_zstring_DESTRUCT_LOGIC()
        dim as integer j
        for j = 0 to cur_block->size - 1
            if cur_block->slots(j).is_contiguous = false then
                deallocate(cur_block->slots(j).key_external)
            end if
            cur_block->slots(j).data_.Destructor()
        next j 
    #endmacro
    #macro HASHMAP_zstring_INSERTION_LOGIC()
        dim as size_t key_length = len(_key)
        if key_length < HASHMAP_zstring_BUFFER_N then
            .key_internal = _key
            .is_contiguous = true
        else
            .key_external = allocate(key_length + 1)
            *(.key_external) = _key
            .is_contiguous = false 
        end if     
    #endmacro
    #macro HASHMAP_zstring_DELETION_LOGIC()
        if cur_row->slots(i).is_contiguous = false then
            if _key = *(cur_row->slots(i).key_external) then
                deallocate(cur_row->slots(i).key_external)
                HASHMAP_DELETION_LOGIC()
            end if
        else
            if _key = cur_row->slots(i).key_internal then
                HASHMAP_DELETION_LOGIC()
            end if             
        end if
    #endmacro
    #macro HASHMAP_zstring_EXISTS_LOGIC()
        if cur_row->slots(i).is_contiguous = true then
            if _key = cur_row->slots(i).key_internal then
                return true
            end if
        else
            if _key = *(cur_row->slots(i).key_external) then
                return true
            end if             
        end if
    #endmacro
    #macro HASHMAP_zstring_RETRIEVE_LOGIC()
        if cur_row->slots(i).is_contiguous = true then
            if _key = cur_row->slots(i).key_internal then
                _item = cur_row->slots(i).data_
                return true
            end if
        else
            if _key = *(cur_row->slots(i).key_external) then
                _item = cur_row->slots(i).data_
                return true
            end if             
        end if
    #endmacro 
    #macro HASHMAP_zstring_RETRIEVE_R_LOGIC()
        if cur_row->slots(i).is_contiguous = true then
            if _key = cur_row->slots(i).key_internal then
                return cur_row->slots(i).data_
            end if
        else
            if _key = *(cur_row->slots(i).key_external) then
                return cur_row->slots(i).data_
            end if             
        end if
    #endmacro   
    #macro HASHMAP_zstring_RETRIEVE_R_PTR_LOGIC()
        if cur_row->slots(i).is_contiguous = true then
            if _key = cur_row->slots(i).key_internal then
                return @(cur_row->slots(i).data_)
            end if
        else
            if _key = *(cur_row->slots(i).key_external) then
                return @(cur_row->slots(i).data_)
            end if             
        end if
    #endmacro   
    #macro HASHMAP_zstring_CALC_NEW_POS(_KEYTYPE_, _INDEX_)
        if cur_row->slots(_INDEX_).is_contiguous = true then
            new_pos = hash_##_KEYTYPE_ _
            ( _
                cur_row->slots(_INDEX_).key_internal _
            )
        else
            new_pos = hash_##_KEYTYPE_ _
            ( _
                *(cur_row->slots(_INDEX_).key_external) _
            )
        end if
    #endmacro
    #macro HASHMAP_DECLARE_HASH_WRAP_zstring(_KEYTYPE_, _TYPENAME_)
    declare const function hash_wrap_zstring naked cdecl _
    ( _
        byref _table as const HashMap_##_KEYTYPE_##_TYPENAME_, _
        _key as zstring _
    ) as size_t   
    #endmacro
    #macro HASHMAP_DEFINE_HASH_WRAP_zstring(_KEYTYPE_, _TYPENAME_)
    Const function HashMap_##_KEYTYPE_##_TYPENAME_.hash_wrap_zstring naked cdecl _
    ( _
        byref _table as const HashMap_##_KEYTYPE_##_TYPENAME_, _
        _key as zstring _
    ) as size_t
        asm
        #ifdef __FB_64BIT__
                push    rbx
                mov     rax,                    14695981039346656037
                mov     rcx,                    1099511628211
                mov     rbx,                    dword ptr [esp+32]
            dsm_hashmap_hashw_zstring##_TYPENAME_##_loopstart_64:
                mov     dl,                     byte ptr [rbx]
                or      dl,                     dl
                jz      dsm_hashmap_hashw_zstring##_TYPENAME_##_return_64
                xor     al,                     dl         
                mul     rcx
                inc     rbx
                jmp     dsm_hashmap_hashw_zstring##_TYPENAME_##_loopstart_64
            dsm_hashmap_hashw_zstring##_TYPENAME_##_return_64:
                pop     rbx
                mov     rcx,                    qword ptr [rsp+8]
                mov     rdx,                    rax
                and     rax,                    qword ptr [rcx+40]
                cmp     rax,                    qword ptr [rcx+8]
                jl      dsm_hashmap_hashw_zstring##_TYPENAME_##_upperlevel_64
                ret
            dsm_hashmap_hashw_zstring##_TYPENAME_##_upperlevel_64:
                and     rdx,                    qword ptr [rcx+48]
                mov     rax,                    rdx
                ret                         
        #else   
                push    ebx
                mov     eax,                    2166136261
                mov     ecx,                    16777619
                mov     ebx,                    dword ptr [esp+16]
            dsm_hashmap_hashw_zstring##_TYPENAME_##_loopstart_32:
                mov     dl,                     byte ptr [ebx]
                or      dl,                     dl
                jz      dsm_hashmap_hashw_zstring##_TYPENAME_##_return_32
                xor     al,                     dl
                mul     ecx
                inc     ebx
                jmp     dsm_hashmap_hashw_zstring##_TYPENAME_##_loopstart_32
            dsm_hashmap_hashw_zstring##_TYPENAME_##_return_32:
                pop     ebx
                mov     ecx,                    dword ptr [esp+4]
                mov     edx,                    eax
                and     eax,                    dword ptr [ecx+20]
                cmp     eax,                    dword ptr [ecx+4]
                jl      dsm_hashmap_hashw_zstring##_TYPENAME_##_upperlevel_32
                ret
            dsm_hashmap_hashw_zstring##_TYPENAME_##_upperlevel_32:
                and     edx,                    dword ptr [ecx+24]
                mov     eax,                    edx
                ret
        #endif   
        end asm     
    end Function
    #endmacro
    #macro HASHMAP_DECLARE_HASH_zstring(_KEYTYPE_, _TYPENAME_)
    declare const function hash_zstring naked cdecl (_key as zstring) as size_t   
    #endmacro
    #macro HASHMAP_DEFINE_HASH_zstring(_KEYTYPE_, _TYPENAME_)
    const function HashMap_##_KEYTYPE_##_TYPENAME_.hash_zstring naked cdecl _
    ( _
        _key as zstring _
    ) as size_t
        asm
        #ifdef __FB_64BIT__
                push    rbx
                mov     rax,                    14695981039346656037
                mov     rcx,                    1099511628211
                mov     rbx,                    dword ptr [esp+24]
            dsm_hashmap_hash_zstring##_TYPENAME_##_loopstart_64:
                mov     dl,                     byte ptr [rbx]
                or      dl,                     dl
                jz      dsm_hashmap_hash_zstring##_TYPENAME_##_return_64
                xor     al,                     dl         
                mul     rcx
                inc     rbx
                jmp     dsm_hashmap_hash_zstring##_TYPENAME_##_loopstart_64
            dsm_hashmap_hash_zstring##_TYPENAME_##_return_64:
                pop     rbx         
                ret
        #else   
                push    ebx
                mov     eax,                    2166136261
                mov     ecx,                    16777619
                mov     ebx,                    dword ptr [esp+12]
            dsm_hashmap_hash_zstring##_TYPENAME_##_loopstart_32:
                mov     dl,                     byte ptr [ebx]
                or      dl,                     dl
                jz      dsm_hashmap_hash_zstring##_TYPENAME_##_return_32
                xor     al,                     dl
                mul     ecx
                inc     ebx
                jmp     dsm_hashmap_hash_zstring##_TYPENAME_##_loopstart_32
            dsm_hashmap_hash_zstring##_TYPENAME_##_return_32:
                pop     ebx
                ret
        #endif   
        end asm       
    end Function
    #endmacro
end namespace

#define HashMap(_KEYTYPE_, _TYPENAME_) HashMap_##_KEYTYPE_##_TYPENAME_
#define HASHMAP_ROWSIZE(_K_, _T_) sizeof(HashMap_##_K_##_T_##_Row)

#macro dsm_HashMap_define(_KEYTYPE_, _TYPENAME_)
#ifndef HASHMAP_##_KEYTYPE_##_TYPENAME_##_DECL
#define HASHMAP_##_KEYTYPE_##_TYPENAME_##_DECL

namespace dsm
   
    type HashMap_##_KEYTYPE_##_TYPENAME_##_key_pair
        HASHMAP_##_KEYTYPE_##_STORAGE_DATA()
        as _TYPENAME_ data_
    end type
    type HashMap_##_KEYTYPE_##_TYPENAME_##_Row
        as size_t size
        as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr next_block
        as HashMap_##_KEYTYPE_##_TYPENAME_##_key_pair _
            slots(0 to HASHMAP_CONTIGUOUS_BLOCK_N-1)
    end Type
    
    type HashMap_##_KEYTYPE_##_TYPENAME_##_Initialization_Object
        public:
            declare constructor(_hashmap_construct as sub(),_
                                _hashmap_destruct as sub())
            declare destructor()
        private:
            as sub() hashmap_destruct
    end Type
   
    type HashMap_##_KEYTYPE_##_TYPENAME_
       
        public:
           
            declare constructor()
            declare destructor()
   
            declare sub insert(_key as _KEYTYPE_, byref _item as _TYPENAME_)
            declare function remove(_key as _KEYTYPE_) as bool
            declare function exists(_key as _KEYTYPE_) as bool           
            declare function retrieve(_key as _KEYTYPE_, _
                                      byref _item as _TYPENAME_) as bool           
            declare function retrieve(_key as _KEYTYPE_) byref as _TYPENAME_   
            declare function retrieve_ptr(_key as _KEYTYPE_) as _TYPENAME_ ptr
            Declare const function retrieve_constptr(_key as _KEYTYPE_) As const _TYPENAME_ ptr
            
            declare sub clear()
            
        private:
            HASHMAP_DECLARE_HASH_WRAP_##_KEYTYPE_(_KEYTYPE_, _TYPENAME_)
            HASHMAP_DECLARE_HASH_##_KEYTYPE_(_KEYTYPE_, _TYPENAME_)
           
            declare sub init()
            declare sub clear_data()
            declare sub up_split_entry()

            as char ptr data_ = Any
            as size_t split = Any 
            as size_t capacity = Any
            as size_t used_size = Any
            as size_t level = Any
            as size_t level_wrap_mask = Any
            as size_t level_wrap_mask_2x = Any

            as size_t row_size_adjust = Any
            as size_t row_shift_mul = Any
    end Type    
end Namespace
#endif
#endmacro
    
#macro dsm_HashMap_implement(_KEYTYPE_, _TYPENAME_)
namespace dsm
   
    sub HashMap_##_KEYTYPE_##_TYPENAME_.init()
        split = 0
        level = HASHMAP_INITIAL_ROW_N
        level_wrap_mask = level - 1
        level_wrap_mask_2x = level shl 1 - 1
        used_size = 0
        capacity = HASHMAP_INITIAL_ROW_N
        
        dim as size_t temp_size
        temp_size = sizeof(HashMap_##_KEYTYPE_##_TYPENAME_##_Row)        
        row_shift_mul = 0
        do
            row_shift_mul += 1
            temp_size shr= 1
        loop while (temp_size <> 0)
        
        row_size_adjust = 1 shl row_shift_mul
        if ((row_size_adjust shr 1) = sizeof( _
            HashMap_##_KEYTYPE_##_TYPENAME_##_Row)) then
           
            row_shift_mul -= 1
            row_size_adjust shr= 1
        end If
    end sub
   
    constructor HashMap_##_KEYTYPE_##_TYPENAME_()
        init()
        data_ = callocate(row_size_adjust * capacity)
    end constructor
   
    sub HashMap_##_KEYTYPE_##_TYPENAME_.clear_data()
        dim as integer i
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_block
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr next_block
        dim as bool not_first_block
       
        for i = 0 to capacity - 1
            cur_block = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                             data_ + i shl row_shift_mul)
            not_first_block = false
            while(cur_block)
                next_block = cur_block->next_block
                HASHMAP_##_KEYTYPE_##_DESTRUCT_LOGIC()
                cur_block->next_block = NULL
                cur_block->size = 0
                if not_first_block then deallocate(cur_block)
                not_first_block = true
                cur_block = next_block
            wend
        next i
        used_size = 0
    end sub
   
    destructor HashMap_##_KEYTYPE_##_TYPENAME_()
        clear_data()
        deallocate(data_)
    end destructor
   
    HASHMAP_DEFINE_HASH_WRAP_##_KEYTYPE_(_KEYTYPE_, _TYPENAME_)
    HASHMAP_DEFINE_HASH_##_KEYTYPE_(_KEYTYPE_, _TYPENAME_)

    sub HashMap_##_KEYTYPE_##_TYPENAME_.insert _
    ( _
        _key as _KEYTYPE_, _
        byref _item as _TYPENAME_ _
    )
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + hash_wrap_##_KEYTYPE_##(this, _key) shl _
                       row_shift_mul)
        while(cur_row->next_block)
            cur_row = cur_row->next_block
        wend
        if cur_row->size = HASHMAP_CONTIGUOUS_BLOCK_N then
            cur_row->next_block = callocate(HASHMAP_ROWSIZE(_KEYTYPE_, _
                                                            _TYPENAME_))
            cur_row = cur_row->next_block
        end if
        with cur_row->slots(cur_row->size)
            .data_ = _item
            HASHMAP_##_KEYTYPE_##_INSERTION_LOGIC()
        end with
        cur_row->size += 1
        used_size += 1
        if (cdbl(used_size) / (capacity * HASHMAP_CONTIGUOUS_BLOCK_N)) > _
            HASHMAP_SPLIT_RATIO then up_split_entry()
    end sub
      
    function HashMap_##_KEYTYPE_##_TYPENAME_.remove _
    ( _
        _key as _KEYTYPE_ _
    ) as bool
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr last_row
        dim as integer i
        dim as integer j
        dim as integer start
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + hash_wrap_##_KEYTYPE_##(this, _key) shl _
                       row_shift_mul)
        last_row = NULL
        do
            start = cur_row->size - 1
            for i = start to 0 step -1
                HASHMAP_##_KEYTYPE_##_DELETION_LOGIC()
            next i
            last_row = cur_row
            cur_row = cur_row->next_block
        loop while (cur_row)
        return true
    end function
   
    function HashMap_##_KEYTYPE_##_TYPENAME_.exists _
    ( _
        _key as _KEYTYPE_ _
    ) as bool
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        dim as integer i
        dim as integer start
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + hash_wrap_##_KEYTYPE_##(this, _key) shl _
                       row_shift_mul)
        do
            start = cur_row->size - 1
            for i = start to 0 step -1
                HASHMAP_##_KEYTYPE_##_EXISTS_LOGIC()
            next i
            cur_row = cur_row->next_block
        loop while (cur_row)
        return false   
    end Function
    
    function HashMap_##_KEYTYPE_##_TYPENAME_.retrieve_ptr _
    ( _
        _key as _KEYTYPE_ _
    ) as _TYPENAME_ Ptr
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        dim as integer i
        dim as integer start
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + hash_wrap_##_KEYTYPE_##(this, _key) shl _
                       row_shift_mul)
        do
            start = cur_row->size - 1
            for i = start to 0 step -1
                HASHMAP_##_KEYTYPE_##_RETRIEVE_R_PTR_LOGIC()
            next i
            cur_row = cur_row->next_block
        loop while (cur_row)
        Return NULL
    end function
   
    const function HashMap_##_KEYTYPE_##_TYPENAME_.retrieve_constptr _
    ( _
        _key as _KEYTYPE_ _
    ) as Const _TYPENAME_ Ptr
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        dim as integer i
        dim as integer start
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + hash_wrap_##_KEYTYPE_##(this, _key) shl _
                       row_shift_mul)
        do
            start = cur_row->size - 1
            for i = start to 0 step -1
                HASHMAP_##_KEYTYPE_##_RETRIEVE_R_PTR_LOGIC()
            next i
            cur_row = cur_row->next_block
        loop while (cur_row)
        Return NULL
    end Function
   
    function HashMap_##_KEYTYPE_##_TYPENAME_.retrieve _
    ( _
        _key as _KEYTYPE_, _
        byref _item as _TYPENAME_ _
    ) as bool
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        dim as integer i
        dim as integer start
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + hash_wrap_##_KEYTYPE_##(this, _key) shl _
                       row_shift_mul)
        do
            start = cur_row->size - 1
            for i = start to 0 step -1
                HASHMAP_##_KEYTYPE_##_RETRIEVE_LOGIC()
            next i
            cur_row = cur_row->next_block
        loop while (cur_row)
        return false                     
    end function
   
    function HashMap_##_KEYTYPE_##_TYPENAME_.retrieve _
    ( _
        _key as _KEYTYPE_ _
    ) byref as _TYPENAME_
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        dim as integer i
        dim as integer start
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + hash_wrap_##_KEYTYPE_##(this, _key) shl _
                       row_shift_mul)
        do
            start = cur_row->size - 1
            for i = start to 0 step -1
                HASHMAP_##_KEYTYPE_##_RETRIEVE_R_LOGIC()
            next i
            cur_row = cur_row->next_block
        loop while (cur_row)
    end function
   
    sub HashMap_##_KEYTYPE_##_TYPENAME_.clear()
        clear_data()
    end sub
   
    sub HashMap_##_KEYTYPE_##_TYPENAME_.up_split_entry()
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_row
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr next_row
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr last_row       
        dim as HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr cur_insert_row 
        dim as integer i
        dim as integer j
        dim as integer start
        dim as integer insert_i
        dim as size_t new_pos

        capacity += 1
        data_ = reallocate(data_, capacity * row_size_adjust)
        cur_insert_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                              data_ + (capacity - 1) shl row_shift_mul)
        cur_insert_row->size = 0
        cur_insert_row->next_block = NULL
        cur_row = cast(HashMap_##_KEYTYPE_##_TYPENAME_##_Row ptr, _
                       data_ + split shl row_shift_mul)
                       
        if cur_row->size > 0 then
            last_row = NULL
            do
                next_row = cur_row->next_block
                start = cur_row->size - 1
                i = cur_row->size - 1
                while(i >= 0)
                    HASHMAP_##_KEYTYPE_##_CALC_NEW_POS(_KEYTYPE_, i)
                    new_pos and= level_wrap_mask_2x
                    if new_pos <> split then
                        if cur_insert_row->size < _
                           HASHMAP_CONTIGUOUS_BLOCK_N then
                            cur_insert_row->size += 1
                            cur_insert_row->slots _
                            ( _
                                cur_insert_row->size - 1 _
                            ) = cur_row->slots(i)
                        else
                            cur_insert_row->next_block = callocate _
                            ( _
                                HASHMAP_ROWSIZE(_KEYTYPE_, _TYPENAME_) _
                            )
                            cur_insert_row = cur_insert_row->next_block
                            cur_insert_row->slots(0) = cur_row->slots(i)
                            cur_insert_row->size = 1
                        end if
                        for j = i to start - 1
                            cur_row->slots(j) = cur_row->slots(j + 1)
                        next j
                        cur_row->size -= 1
                        start -= 1
                    end if
                    i -= 1
                wend
                if cur_row->size = 0 then
                    if last_row = NULL then
                        if next_row then
                            *cur_row = *next_row
                            deallocate(next_row)
                        else
                            cur_row = next_row
                        end if
                    else
                        last_row->next_block = next_row
                        deallocate(cur_row)
                        cur_row = next_row
                    end if
                else
                    last_row = cur_row
                    cur_row = next_row     
                end if
            loop while cur_row
        end if
        split += 1
        if split >= level then
            level shl= 1
            split = 0
            level_wrap_mask = level - 1
            level_wrap_mask_2x = level shl 1 - 1
        end if
    end sub
end namespace
#endmacro
#endif
