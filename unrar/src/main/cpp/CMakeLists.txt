# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(unrar)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH} ${NATIVERENDER_ROOT_PATH}/include)

# 日志打印配置
add_definitions( "-DLOG_DOMAIN=0xd0d0" )
add_definitions( "-DLOG_TAG=\"unrar\"" )

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DLITTLE_ENDIAN")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fvisibility=hidden")

set(SELF_LIB_NAME unrar)
file(GLOB SELF_TEMP_SRC_FILES RELATIVE ${NATIVERENDER_ROOT_PATH} *.cc *.cpp *.h)
list(APPEND SELF_SRC_FILES ${SELF_TEMP_SRC_FILES})
add_library(${SELF_LIB_NAME} SHARED ${SELF_SRC_FILES})
target_link_libraries(${SELF_LIB_NAME} PUBLIC libace_napi.z.so libhilog_ndk.z.so)
target_link_libraries(${SELF_LIB_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/libunrar.a)
