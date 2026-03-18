# clawdOS environment
export PATH="$HOME/.local/bin:$HOME/.claude/local/bin:/usr/local/bin:$PATH"

# Load clawdOS configuration
if [ -f /etc/clawdos/env ]; then
    set -a
    . /etc/clawdos/env
    set +a
fi

# System identification
export CLAWDOS_VERSION="0.1.0"
