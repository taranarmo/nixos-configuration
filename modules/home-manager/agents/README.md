# LLM Agent Sandbox (`agent-box` / `agent-sandbox`)

A lightweight, unprivileged sandbox wrapper powered by [Bubblewrap (`bwrap`)](https://github.com/containers/bubblewrap) designed to run coding agents (`agy`, `claude`, `opencode`, `aider`, etc.) in complete isolation from the host filesystem.

---

## Architecture & Security Model

The sandbox enforces the principle of least privilege while keeping development completely seamless:

1. **Filesystem Isolation**:
   * **Cloaked Home Directory**: Mounts an ephemeral `tmpfs` over `$HOME`. Sensitive files (`~/.ssh`, `~/.aws`, `~/.gnupg`, shell history, browser profiles, and personal documents) **do not exist** inside the sandbox.
   * **Project Directory Access**: Binds the target project directory (`$PWD` or `-C /path/to/project`) read-write.
   * **Safety Guard**: Prevents launching `agent-box` directly in `$HOME` without `-C` or `--allow-home`, avoiding accidental leaks.
   * **Ephemeral `/tmp`**: Scratch files are isolated in an in-memory `tmpfs`.

2. **Full Nix Integration**:
   * **Read-only Store**: Mounts `/nix` read-only along with essential NixOS configuration paths (`/etc/nix`, `/etc/static`, `/etc/profiles`).
   * **Nix Daemon Access**: Shares the host Unix domain socket at `/nix/var/nix/daemon-socket/socket`.
   * **Dynamic Builds**: The agent can run `nix shell`, `nix develop`, and `nix build` dynamically without requiring root privileges or host system modification permissions.

3. **Agent State Persistence**:
   * Selectively preserves agent-specific configuration, cache, and conversation logs by bind-mounting known state directories (if present):
     * **Antigravity (`agy`)**: `~/.gemini`, `~/.config/antigravity`, `~/.cache/gemini`
     * **Claude Code (`claude`)**: `~/.claude`, `~/.claude.json`, `~/.config/claude`, `~/.cache/claude`
     * **OpenCode (`opencode`)**: `~/.config/opencode`, `~/.local/share/opencode`, `~/.local/state/opencode`, `~/.cache/opencode`
     * **Aider (`aider`)**: `~/.aider.conf.yml`, `~/.aider.input.history`
     * **Git Identity**: `~/.gitconfig` and `~/.config/git` (read-only)

---

## Token-Based Authentication

Rather than mounting host credential directories (such as `~/.aws/` or `~/.config/`), `agent-box` relies on **ephemeral session tokens** passed through environment variables.

### Automatic Token Forwarding
The sandbox automatically forwards any environment variables matching:
* `AWS_*` (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION`, etc.)
* `GH_*`, `GITHUB_*` (`GH_TOKEN`, `GITHUB_TOKEN`, etc.)
* `GIT_AUTHOR_*`, `GIT_COMMITTER_*`
* Any variable ending or containing `_API_KEY`, `_TOKEN`, `_SECRET`, `_KEY_ID`, or `_SESSION_TOKEN`.

### Usage Examples with Cloud & Dev Tools

#### 1. GitHub CLI (`gh`)
Pass your active session token:
```bash
GH_TOKEN=$(gh auth token) agent-box claude
```
`gh` inside the sandbox automatically authenticates with this token for API queries, reviewing PRs, and cloning private repositories over HTTPS.

#### 2. AWS CLI (with `aws-vault`)
Generate temporary STS session credentials:
```bash
aws-vault exec <profile> -- agent-box claude
```
Inside the sandbox, `aws` and `terraform` commands authenticate via temporary STS tokens without ever exposing long-lived IAM keys or your `~/.aws` directory.

#### 3. Google Cloud (`gcloud`)
```bash
GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token) agent-box claude
```

#### 4. Custom or Arbitrary Variables (`-e` / `--env`)
```bash
agent-box -e VAULT_TOKEN="$(vault print token)" -e VAULT_ADDR="$VAULT_ADDR" claude
agent-box -e CUSTOM_API_KEY=secret_val opencode
```

---

## General CLI Usage

```bash
# Run an agent in current project directory
agent-box agy
agent-box claude
agent-box opencode

# Run in a specific project directory
agent-box -C ~/code/my-project claude

# Run an isolated interactive shell
agent-box

# Run inside a project-specific Nix devShell
nix develop --command agent-box agy

# Run offline (unshare network namespace)
agent-box --no-net agy
```

### Command Options

| Option | Description |
| :--- | :--- |
| `-C, --dir, --workspace <DIR>` | Run inside `<DIR>` instead of `$PWD`. |
| `-e, --env <VAR[=VAL]>` | Forward or set an environment variable inside the sandbox. |
| `--ro-dir <DIR>` | Mount an additional host directory read-only. |
| `--rw-dir <DIR>` | Mount an additional host directory read-write. |
| `--no-net` | Disable network access (unshares network namespace). |
| `--allow-home` | Bypass the safety guard preventing execution directly in `$HOME`. |
| `-h, --help` | Display usage instructions. |
