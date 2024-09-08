include_guard(GLOBAL)

set(PYTHON_PATH "python3" CACHE FILEPATH "Path to python3 executable")
message(STATUS "Python: ${PYTHON_PATH}")

function(_append_requirements_from_file output_variable)
    set(venv_requirements "")
    foreach(requirement IN LISTS ARGN)
        file(READ "${requirement}" requirement_contents)
        if(NOT requirement_contents MATCHES "\n$")
             message(FATAL_ERROR "venv requirements file must end with a newline")
        endif()
        string(APPEND venv_requirements "${requirement_contents}")
    endforeach()

    # Remove duplicates and comments
    string(REPLACE "\n" ";" venv_requirements_list ${venv_requirements})
    list(FILTER venv_requirements_list EXCLUDE REGEX "[ \t\r\n]*#.*")
    list(SORT venv_requirements_list)
    list(REMOVE_DUPLICATES venv_requirements_list)
    string(REPLACE ";" "\n" venv_requirements "${venv_requirements_list}")

    set(${output_variable} ${venv_requirements} PARENT_SCOPE)
endfunction()

function(setup_venv)
    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs REQUIREMENTS)

    cmake_parse_arguments(
        ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")

    _append_requirements_from_file(venv_params ${ARG_REQUIREMENTS})

    set(venv_name ".venv")

    set(venv_additional_args)
    if(USERVER_PIP_USE_SYSTEM_PACKAGES)
        list(APPEND venv_additional_args "--system-site-packages")
    endif()

    set(venv_dir "${CMAKE_CURRENT_SOURCE_DIR}/${venv_name}")
    set(venv_bin_dir "${venv_dir}/bin")

    message(STATUS "Setting up the venv at ${venv_dir}")

    if(NOT EXISTS "${venv_dir}")
        execute_process(
            COMMAND
            "${PYTHON_PATH}"
            -m venv
            "${venv_dir}"
            RESULT_VARIABLE status
        )
        if(status)
            file(REMOVE_RECURSE "${venv_dir}")
            message(FATAL_ERROR
                "Failed to create Python virtual environment. "
                "On Debian-based systems, venv is installed separately:\n"
                "sudo apt install python3-venv"
            )
        endif()
    endif()

    execute_process(
        COMMAND
        "${venv_dir}/bin/activate"
    )

    set(should_run_pip TRUE)
    set(venv_params_file "${venv_dir}/venv-params.txt")
    if(EXISTS "${venv_params_file}")
        file(READ "${venv_params_file}" venv_params_old)
        if(venv_params_old STREQUAL venv_params)
            set(should_run_pip FALSE)
        endif()
    endif()

    if(should_run_pip)
        message(STATUS "Installing requirements:")
        foreach(requirement IN LISTS ARG_REQUIREMENTS)
            message(STATUS "  ${requirement}")
        endforeach()
        list(
            TRANSFORM ARG_REQUIREMENTS
            PREPEND "--requirement="
            OUTPUT_VARIABLE pip_requirements
        )
        execute_process(
            COMMAND
            "${venv_bin_dir}/python3" -m pip install
            --disable-pip-version-check
            ${pip_requirements}
            RESULT_VARIABLE status
        )
        if(status)
            message(FATAL_ERROR "Failed to install venv requirements")
        endif()
        file(WRITE "${venv_params_file}" "${venv_params}")
    endif()
endfunction()
