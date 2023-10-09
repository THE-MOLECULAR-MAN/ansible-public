#!/bin/bash
set -e
# echo "[python-upgrade-test] started."

# echo "defining functions"

list_all_python_executable_paths() {
     # this function returns a line delimited list of all the absolute paths
     # to all installed versions of Python3. Example output:
     # /Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10
     # /Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9
     # /usr/bin/python3
     #
     # want to use the -type f so it will only return actual files, and
     # NOT any symbolic links - avoids duplicates
     # the 2> /dev/null skips errors from permissions

     # can also just list every pip3 executable
     # gfind ~/Library/Python -name 'pip3' -executable -exec {} --version \;


    #gfind "$HOME/Library/Python" -executable -name 'python3*' ! -name "python3*-*" -type f
    # "$HOME/Library/Python" is where pip's executable tools get installed
    #     not where Python is installed

    # dirty slow find:
    # sudo gfind / -executable -name 'python3*' ! -name "python3*-*" -ls

    for ITER_PATH in ${PATH//:/ } 
    do
        if [[ -d "$ITER_PATH" ]]; then
            gfind "$ITER_PATH" -executable -name 'python3*' \
                ! -name "python3*-*" -type f 2>/dev/null
        fi
    done
}

slow_upgrade_all_pip() {

    # finds all versions, but very slow:
    # PYTHONS=$(sudo gfind / -executable -name 'python3*' ! -name "python3*-*" -type f 2>/dev/null)

    # faster (1.8 seconds) but makes assumptions and may not find all of them
    PYTHONS=$(sudo gfind /usr/bin /usr/local/Cellar /Library/Frameworks/Python.framework/Versions -executable -name 'python3*' ! -name "python3*-*" -type f 2>/dev/null)
    
    # don't use a for loop here, use while
    while IFS= read -r ITER_PP ; do
        ls -lah "$ITER_PP"
        "$ITER_PP" -m pip install --user --upgrade pip 
    done <<< "$PYTHONS"

}



upgrade_pip_modules_on_single_python_instance() {
    echo "[START] upgrade_pip_modules_on_single_python_instance: $1"
    INSTANCE_OF_PYTHON_PATH="$1"

    if [[ -f "$INSTANCE_OF_PYTHON_PATH" ]]; then
        "$INSTANCE_OF_PYTHON_PATH" --version
        # "$INSTANCE_OF_PYTHON_PATH" -m pip install --user --upgrade pip 
    fi

    # echo "[END] upgrade_pip_modules_on_single_python_instance"
}

upgrade_all_pip_packages_on_all_python_versions() {
    # echo "[START] upgrade_all_pip_packages_on_all_python_versions"

    for PYTHON_INSTANCE_PATH in $(list_all_python_executable_paths)
    do
        # echo "upgrading stuff on $PYTHON_INSTANCE_PATH"
        upgrade_pip_modules_on_single_python_instance "$PYTHON_INSTANCE_PATH"
    done

    # PATH_LIST=$(list_all_python_executable_paths)
    # while IFS= read -r ITER_PATH ; do
    #     upgrade_pip_modules_on_single_python_instance "$ITER_PATH"
    # done <<< "$PATH_LIST"

    # echo "[END] upgrade_all_pip_packages_on_all_python_versions"
}

# echo "main started"

# list_all_python_executable_paths

upgrade_all_pip_packages_on_all_python_versions

echo "[python-upgrade-test] finished successfully."
