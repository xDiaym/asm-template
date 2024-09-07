CMAKE_COMMON_FLAGS ?= -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
CMAKE_DEBUG_FLAGS ?=
CMAKE_RELEASE_FLAGS ?=
NPROCS ?= $(shell nproc)
CLANG_FORMAT ?= clang-format
BLACK ?= black
BLACK_FLAGS ?= -l79

# Use this for overriding Makefile
-include Makefile.local

CMAKE_DEBUG_FLAGS += -DCMAKE_BUILD_TYPE=Debug $(CMAKE_COMMON_FLAGS)
CMAKE_RELEASE_FLAGS += -DCMAKE_BUILD_TYPE=Release $(CMAKE_COMMON_FLAGS)

.PHONY: cmake-debug
cmake-debug:
	cmake -B build_debug $(CMAKE_DEBUG_FLAGS)

.PHONY: cmake-release
cmake-release:
	cmake -B build_release $(CMAKE_RELEASE_FLAGS)

.PHONY: build-debug build-release
build-debug build-release: build-%: cmake-%
	cmake --build build_$* -j $(NPROCS)

.PHONY: run-debug run-release
run-debug run-release: run-%: build-%
	cmake --build build_$* -v --target start-lab1

.PHONY: format
format:
	find src -name '*pp' -type f  | xargs $(CLANG_FORMAT) -i
	$(BLACK) $(BLACK_FLAGS) vissuite

.PHONY: dist-clean
dist-clean:
	rm -rf build_*
	rm -rf vissuite/__pycache__/
	#rm *.png *.jpg *.jpeg
