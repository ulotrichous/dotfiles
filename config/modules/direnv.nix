{
  programs.direnv.enable = true;

  programs.direnv.direnvrcExtra = ''
    layout_hatch() {
        if [[ ! -f "pyproject.toml" ]]; then
            if [[ ! -f "setup.py" ]]; then
                local tmpdir
                log_status "No pyproject.toml or setup.py found. Executing \`hatch new\` to create a new project."
                PROJECT_NAME="$(basename $PWD)"
                tmpdir="$(mktemp -d)"
                hatch new "$PROJECT_NAME" $tmpdir > /dev/null
                cp -a --no-clobber $tmpdir/* . && rm -rf $tmpdir
            else
                # I haven't yet seen a case where migrating from an existing `setup.py` works, but I'm sure there are some.
                log_status "No pyproject.toml found. Executing \`hatch new --init\` to migrate from setuptools."
                hatch new --init || log_error "Failed to migrate from setuptools. Please fix and run \`hatch new --init\` manually." && return 1
            fi
        fi

        HATCH_ENV=''${HATCH_ENV_ACTIVE:-default}
        # We need this to error out if the env doesn't exist in the pyproject.toml file.
        VIRTUAL_ENV=$(hatch env find $HATCH_ENV)

        if [[ ! -d $VIRTUAL_ENV ]]; then
            log_status "No virtual environment exists. Executing \`hatch env create\` to create one."
            hatch env create $HATCH_ENV
        fi

        # Trigger dependency sync.
        # Hatch doesn't (yet) have a dedicated command to update the dependencies
        # of an environment.
        # They are updated when a shell for the environment is created or a command
        # is run in the environment.
        hatch env run --env $HATCH_ENV -- python --version

        PATH_add "$VIRTUAL_ENV/bin"
        export HATCH_ENV_ACTIVE=$HATCH_ENV  # or VENV_ACTIVE=1
        export VIRTUAL_ENV
    }
  '';
}
