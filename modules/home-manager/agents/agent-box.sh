#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'HELP'
Usage: agent-box [OPTIONS] [--] [COMMAND [ARGS...]]

Runs LLM coding agents (agy, claude, opencode, aider, etc.) or interactive shells
in a lightweight, isolated Linux sandbox (Bubblewrap).

The sandbox grants access ONLY to:
  - The project/workspace directory (read-write)
  - Nix store and Nix daemon socket (to run nix commands / access packages)
  - Network (for LLM APIs and downloading dependencies)
  - Agent-specific configuration & auth files (~/.gemini, ~/.claude, ~/.config/opencode, etc.)
  - Safe environment variables (API keys, Git author info)

Your real home directory (~/.ssh, personal files, dotfiles) and host system are
completely hidden and protected from unauthorized access or accidental modification.

Options:
  -C, --dir, --workspace DIR  Run inside DIR instead of current working directory
  -e, --env VAR[=VAL]         Forward or set an environment variable inside sandbox
  --ro-dir DIR                Mount an additional directory read-only
  --rw-dir DIR                Mount an additional directory read-write
  --no-net                    Disable network access inside the sandbox
  --allow-home                Allow running with workspace in $HOME (disables safety guard)
  -h, --help                  Show this help message

Examples:
  agent-box agy
  agent-box claude
  agent-box opencode
  GH_TOKEN=$(gh auth token) agent-box claude
  aws-vault exec my-profile -- agent-box claude
  agent-box -e CUSTOM_TOKEN=xyz claude
  agent-box -C ~/src/my-project claude
  agent-box                   # Starts an isolated interactive shell
  nix develop -c agent-box agy
HELP
  exit 0
}

WORKSPACE="$PWD"
SHARE_NET=1
ALLOW_HOME=0
EXTRA_MOUNTS=()
CUSTOM_CMD=()
MANUAL_ENVS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      ;;
    -e|--env)
      if [[ -z "${2:-}" ]]; then
        echo "Error: $1 requires a variable name or VAR=VAL argument" >&2
        exit 1
      fi
      if [[ "$2" == *"="* ]]; then
        MANUAL_ENVS+=(--setenv "${2%%=*}" "${2#*=}")
      else
        if [[ -n "${!2:-}" ]]; then
          MANUAL_ENVS+=(--setenv "$2" "${!2}")
        fi
      fi
      shift 2
      ;;
    -C|--dir|--workspace)
      if [[ -z "${2:-}" ]]; then
        echo "Error: $1 requires a directory argument" >&2
        exit 1
      fi
      WORKSPACE="$2"
      shift 2
      ;;
    --ro-dir)
      if [[ -z "${2:-}" ]]; then
        echo "Error: $1 requires a directory argument" >&2
        exit 1
      fi
      EXTRA_MOUNTS+=(--ro-bind-try "$2" "$2")
      shift 2
      ;;
    --rw-dir)
      if [[ -z "${2:-}" ]]; then
        echo "Error: $1 requires a directory argument" >&2
        exit 1
      fi
      EXTRA_MOUNTS+=(--bind-try "$2" "$2")
      shift 2
      ;;
    --no-net)
      SHARE_NET=0
      shift
      ;;
    --allow-home)
      ALLOW_HOME=1
      shift
      ;;
    --)
      shift
      CUSTOM_CMD=("$@")
      break
      ;;
    *)
      CUSTOM_CMD=("$@")
      break
      ;;
  esac
done

WORKSPACE="$(realpath "$WORKSPACE")"

if [[ ! -d "$WORKSPACE" ]]; then
  echo "Error: Workspace directory '$WORKSPACE' does not exist." >&2
  exit 1
fi

REAL_HOME="$(realpath "$HOME")"
if [[ "$WORKSPACE" == "$REAL_HOME" && "$ALLOW_HOME" -eq 0 ]]; then
  echo "Error: Refusing to run agent-box with workspace pointing directly to \$HOME ($REAL_HOME)." >&2
  echo "This would expose your entire home directory (SSH keys, secrets, dotfiles) to the agent." >&2
  echo "Please 'cd' into a project directory or pass '-C /path/to/project'." >&2
  echo "(If you really know what you are doing, pass '--allow-home' to override.)" >&2
  exit 1
fi

if [[ ${#CUSTOM_CMD[@]} -eq 0 ]]; then
  CMD=("${SHELL:-/run/current-system/sw/bin/bash}")
else
  CMD=("${CUSTOM_CMD[@]}")
fi

NET_ARGS=()
if [[ "$SHARE_NET" -eq 1 ]]; then
  NET_ARGS=(--share-net)
fi

ENV_ARGS=(
  --clearenv
  --setenv HOME "$HOME"
  --setenv USER "${USER:-agent}"
  --setenv LOGNAME "${LOGNAME:-agent}"
  --setenv PATH "$PATH"
  --setenv TERM "${TERM:-xterm-256color}"
  --setenv COLORTERM "${COLORTERM:-truecolor}"
  --setenv LANG "${LANG:-en_US.UTF-8}"
  --setenv NIX_SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt"
  --setenv SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt"
)

if [[ -n "${SHELL:-}" ]]; then
  ENV_ARGS+=(--setenv SHELL "$SHELL")
fi

if [[ -n "${LC_ALL:-}" ]]; then
  ENV_ARGS+=(--setenv LC_ALL "$LC_ALL")
fi

# Pass API keys, tokens, and cloud credentials
while IFS= read -r var; do
  if [[ -n "${!var:-}" ]]; then
    ENV_ARGS+=(--setenv "$var" "${!var}")
  fi
done < <(env | cut -d= -f1 | grep -E '(_API_KEY|_TOKEN|_SECRET|_KEY_ID|_SESSION_TOKEN|^AWS_|^GH_|^GITHUB_|^OPENCODE_|^GEMINI_|^ANTHROPIC_|^OPENAI_|^GOOGLE_|^GIT_AUTHOR_|^GIT_COMMITTER_)' || true)

# Add manually passed environment variables (-e/--env)
if [[ ${#MANUAL_ENVS[@]} -gt 0 ]]; then
  ENV_ARGS+=("${MANUAL_ENVS[@]}")
fi

EXTRA_BWRAP_ARGS=()
if [[ -n "${AGENT_BOX_EXTRA_ARGS:-}" ]]; then
  read -r -a EXTRA_BWRAP_ARGS <<< "$AGENT_BOX_EXTRA_ARGS"
fi

exec bwrap \
  --ro-bind /nix /nix \
  --ro-bind-try /etc/resolv.conf /etc/resolv.conf \
  --ro-bind-try /etc/ssl /etc/ssl \
  --ro-bind-try /etc/static /etc/static \
  --ro-bind-try /etc/nix /etc/nix \
  --ro-bind-try /etc/hosts /etc/hosts \
  --ro-bind-try /etc/passwd /etc/passwd \
  --ro-bind-try /etc/group /etc/group \
  --ro-bind-try /etc/profiles /etc/profiles \
  --ro-bind-try /run/current-system/sw /run/current-system/sw \
  --proc /proc \
  --dev /dev \
  --tmpfs /tmp \
  --tmpfs "$HOME" \
  --ro-bind-try "$HOME/.gitconfig" "$HOME/.gitconfig" \
  --ro-bind-try "$HOME/.config/git" "$HOME/.config/git" \
  --ro-bind-try "$HOME/.config/nix" "$HOME/.config/nix" \
  --ro-bind-try "$HOME/.nix-defexpr" "$HOME/.nix-defexpr" \
  --bind-try "$HOME/.claude" "$HOME/.claude" \
  --bind-try "$HOME/.claude.json" "$HOME/.claude.json" \
  --bind-try "$HOME/.config/claude" "$HOME/.config/claude" \
  --bind-try "$HOME/.cache/claude" "$HOME/.cache/claude" \
  --bind-try "$HOME/.gemini" "$HOME/.gemini" \
  --bind-try "$HOME/.config/antigravity" "$HOME/.config/antigravity" \
  --bind-try "$HOME/.cache/gemini" "$HOME/.cache/gemini" \
  --bind-try "$HOME/.config/opencode" "$HOME/.config/opencode" \
  --bind-try "$HOME/.local/share/opencode" "$HOME/.local/share/opencode" \
  --bind-try "$HOME/.local/state/opencode" "$HOME/.local/state/opencode" \
  --bind-try "$HOME/.cache/opencode" "$HOME/.cache/opencode" \
  --bind-try "$HOME/.aider.conf.yml" "$HOME/.aider.conf.yml" \
  --bind-try "$HOME/.aider.input.history" "$HOME/.aider.input.history" \
  "${EXTRA_MOUNTS[@]}" \
  --bind "$WORKSPACE" "$WORKSPACE" \
  --chdir "$WORKSPACE" \
  "${ENV_ARGS[@]}" \
  "${EXTRA_BWRAP_ARGS[@]}" \
  --unshare-all \
  "${NET_ARGS[@]}" \
  --die-with-parent \
  -- "${CMD[@]}"
