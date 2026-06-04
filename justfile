test:
    bash test/run.sh

demo:
    vhs demo.tape

link:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -d "$HOME/bin" ]; then
        target="$HOME/bin/wt"
    else
        target="/usr/local/bin/wt"
    fi
    ln -sf "{{justfile_directory()}}/wt" "$target"
    echo "linked $target -> {{justfile_directory()}}/wt"
