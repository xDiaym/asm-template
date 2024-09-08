cmake_minimum_required(VERSION 3.14)
project(lab1 LANGUAGES CXX ASM_NASM)


include(cmake/SetupCompiler.cmake)
include(cmake/SetupVenv.cmake)
setup_venv(REQUIREMENTS "${CMAKE_CURRENT_SOURCE_DIR}/requirements.txt")
include(cmake/SetupVissuite.cmake)


file(GLOB_RECURSE CXX_SOURCES
	${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
)

file(GLOB_RECURSE ASM_SOURCES
	${CMAKE_CURRENT_SOURCE_DIR}/src/*.asm
)


add_executable(${PROJECT_NAME}
	${CXX_SOURCES}
	${ASM_SOURCES}
)
