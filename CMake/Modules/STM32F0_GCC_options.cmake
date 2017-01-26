set(CMAKE_C_FLAGS "-mthumb -mcpu=cortex-m0 -fno-builtin -std=c11 -g -Wall -ffunction-sections -fdata-sections -fomit-frame-pointer -mlong-calls -mabi=aapcs -fno-exceptions -fno-unroll-loops -ftree-vectorize -specs=nano.specs" CACHE INTERNAL "c compiler flags")
set(CMAKE_CXX_FLAGS "-mthumb -mcpu=cortex-m0 -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mlong-calls -mabi=aapcs -fno-exceptions -fno-unroll-loops -ftree-vectorize -specs=nano.specs" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "-c -mthumb -mcpu=cortex-m0 -g -Wa,--no-warn -x assembler-with-cpp " CACHE INTERNAL "asm compiler flags")

set(CMAKE_EXE_LINKER_FLAGS "-mthumb -mcpu=cortex-m0 -static -mabi=aapcs -Wl,-gc-sections" CACHE INTERNAL "executable linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m0 -specs=nano.specs " CACHE INTERNAL "module linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m0 -specs=nano.specs " CACHE INTERNAL "shared linker flags")

set(STM32_CHIP_TYPES 030x6 030x8 031x6 038xx 042x6 048x6 051x8 058xx 070x6 070xB 071xB 072xB 078xx 091xC 098xx 030xC CACHE INTERNAL "stm32f0 chip types")
set(STM32_CODES "030.[46]" "030.8" "031.[46]" "038.6" "042.[46]" "048.6" "051.[468]" "058.8" "070.6" "070.B" "071.[8B]" "072.[8B]" "078.B" "091.[BC]" "098.C" "030.C")

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(REGEX REPLACE "^[S][T][M]32[F]((03[018].[468C])|(04[28].[46])|(05[18].[468])|(07[0128].[68B])|(09[18].[BC])).+$" "\\1" STM32_CODE ${CHIP})
    set(INDEX 0)
    foreach(C_TYPE ${STM32_CHIP_TYPES})
        list(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        if(STM32_CODE MATCHES ${CHIP_TYPE_REGEXP})
            set(RESULT_TYPE ${C_TYPE})
        endif()
        math(EXPR INDEX "${INDEX}+1")
    endforeach()
    set(${CHIP_TYPE} ${RESULT_TYPE})
endmacro()

macro(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE)
    string(REGEX REPLACE "^[S][T][M]32[F](0[34579][0128]).[468BC]" "\\1" STM32_CODE ${CHIP})
    string(REGEX REPLACE "^[S][T][M]32[F]0[34579][0128].([468BC])" "\\1" STM32_SIZE_CODE ${CHIP})

    if(STM32_SIZE_CODE STREQUAL "4")
        set(FLASH "16K")
    elseif(STM32_SIZE_CODE STREQUAL "6")
        set(FLASH "32K")
    elseif(STM32_SIZE_CODE STREQUAL "8")
        set(FLASH "64K")
    elseif(STM32_SIZE_CODE STREQUAL "B")
        set(FLASH "128K")
    elseif(STM32_SIZE_CODE STREQUAL "C")
        set(FLASH "256K")
    endif()

    STM32_GET_CHIP_TYPE(${CHIP} TYPE)

    if(${TYPE} STREQUAL 030x6)
        set(RAM "4K")
    elseif(${TYPE} STREQUAL 030x8)
        set(RAM "8K")
    elseif(${TYPE} STREQUAL 030xC)
        set(RAM "32K")
    elseif(${TYPE} STREQUAL 031x6)
        set(RAM "4K")
    elseif(${TYPE} STREQUAL 038xx)
        set(RAM "4K")
    elseif(${TYPE} STREQUAL 042x6)
        set(RAM "6K")
    elseif(${TYPE} STREQUAL 048x6)
        set(RAM "6K")
    elseif(${TYPE} STREQUAL 051x8)
        set(RAM "8K")
    elseif(${TYPE} STREQUAL 058xx)
        set(RAM "8K")
    elseif(${TYPE} STREQUAL 070x6)
        set(RAM "6K")
    elseif(${TYPE} STREQUAL 070xB)
        set(RAM "16K")
    elseif(${TYPE} STREQUAL 071xB)
        set(RAM "16K")
    elseif(${TYPE} STREQUAL 072xB)
        set(RAM "16K")
    elseif(${TYPE} STREQUAL 078xx)
        set(RAM "16K")
    elseif(${TYPE} STREQUAL 091xC)
        set(RAM "32K")
    elseif(${TYPE} STREQUAL 098xx)
        set(RAM "32K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    
    if(TYPE_INDEX EQUAL -1)
        message(FATAL_ERROR "${CHIP_TYPE} is not supported.")
    endif()
    
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F0;STM32F${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F0;STM32F${CHIP_TYPE}")
    endif()
    
    set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
