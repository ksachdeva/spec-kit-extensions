# Extension Authoring

An extension adds new user-facing capabilities to Spec Kit. It is the right
choice for agent-neutral commands, workflow hooks/events, scripts, configuration
scaffolding, and templates that accompany new commands. An extension is a
declarative content package: it does not import Python plugins or replace CLI
handlers.

## Package Shape

```text
my-extension/
|-- extension.yml
|-- README.md
|-- LICENSE
|-- CHANGELOG.md                 # recommended
|-- commands/
|   `-- speckit.my-extension.check.md
|-- templates/                   # optional
|-- scripts/                     # optional
`-- config-template.yml          # optional
```

All manifest file paths are relative to the extension root. Keep package paths
simple, portable, and inside the package. Do not include generated installation
state, credentials, or development environments in a release archive.

## Manifest

Every package needs `extension.yml` with schema version `1.0`, a unique slug,
metadata, a Spec Kit compatibility requirement, and at least one command, hook,
event, template, or script. A configuration template alone does not provide
behavior.

```yaml
schema_version: "1.0"

extension:
   id: my-extension
   name: My Extension
   version: "1.0.0"
   description: Inspect a project convention and report violations.
   author: Example Author
   license: MIT

requires:
   speckit_version: ">=1.0"

provides:
   commands:
      - name: speckit.my-extension.check
         file: commands/speckit.my-extension.check.md
         description: Check project conventions.
         aliases:
            - speckit.my-extension.audit
   config:
      - name: my-extension-config.yml
         template: config-template.yml
         required: false

hooks:
   after_tasks:
      command: speckit.my-extension.check
      optional: true
      prompt: Run the convention check?

tags: [quality, workflow]
```

The ID is lowercase letters, digits, and hyphens. The canonical command form is
`speckit.<extension-id>.<command>`; aliases must use the same extension
namespace. The manifest version is parsed as PEP 440; using `MAJOR.MINOR.PATCH`
is recommended for releases, but do not assume strict SemVer-only parsing.
`requires.speckit_version` is checked against the installed CLI. Optional
manifest fields include the following:

| Field | Purpose |
| --- | --- |
| `extension.author`, `repository`, `license`, `homepage` | Attribution and source metadata. |
| `extension.category`, `effect`, `support` | Discovery/display information; metadata does not grant permissions. |
| `requires.tools` | External executables and optional required/version constraints. The CLI checks declared tools but does not install them. |
| `requires.commands`, `requires.scripts` | Core command/script dependencies. |
| `provides.commands` | Namespaced Markdown commands, source file, description, aliases. |
| `provides.templates` | Named Markdown templates. Extension templates always replace lower layers. |
| `provides.scripts` | Named script files; `runtimes` may list `bash`, `powershell`, or `python` for information. |
| `provides.config` | Configuration templates scaffolded into the installed extension directory. |
| `defaults`, `config_schema` | Default configuration values and optional schema metadata. |
| `hooks`, `events` | Top-level declarations for workflow hooks and supported agent-runtime events. |

At least one command, hook, event, template, or script is required. `config`
alone is not a capability. All file paths must be relative to the package root;
absolute paths and traversal are rejected. Do not put a `strategy` on extension
templates or scripts: composition (`prepend`, `append`, `wrap`) is a preset
feature.

## Authoring Commands and Assets

Command source files are Markdown and agent-neutral. The active integration
renders them to its native command or skill format. Keep each command focused;
state its expected inputs, prerequisites, actions, outputs, failure behavior,
and whether it changes files. Use `$ARGUMENTS` for caller input and the command
reference token supported by the extension renderer when invoking another
command.

Command frontmatter may declare a description, tools, and script variants. For
example:

```markdown
---
description: Check the project convention.
scripts:
   sh: ../../scripts/check.sh
   ps: ../../scripts/check.ps1
---

# Check

Inspect the requested files and report findings without changing them.

User input: $ARGUMENTS
```

Supported authoring placeholders include:

- `$ARGUMENTS`: the user's invocation arguments.
- `{SCRIPT}`: the registered path for a declared helper script.
- `__SPECKIT_COMMAND_<NAME>__`: an agent-neutral reference to another command.

Do not hard-code `/speckit...` or `$speckit-...` invocations inside reusable
commands; agents use different separators and skill prefixes. The command token
uppercases the name after `speckit.` and encodes dotted command segments with
underscores. Hyphens inside a segment remain hyphens:

| Command | Token |
| --- | --- |
| `speckit.plan` | `__SPECKIT_COMMAND_PLAN__` |
| `speckit.bug.fix` | `__SPECKIT_COMMAND_BUG_FIX__` |
| `speckit.agent-context.update` | `__SPECKIT_COMMAND_AGENT-CONTEXT_UPDATE__` |

The active integration renders that token into its native invocation. Use it
for references in both commands and skills; verify the rendered output with
each integration you claim to support.

Declared command scripts and extension assets use package-relative paths. The
registrar rewrites these references to the installed project location when it
creates native command files, so they continue to work after the source checkout
is gone. Inspect the generated command frontmatter after installation; do not
assume a development path will be valid for a published archive. A manifest
script's optional `runtimes` list is descriptive metadata, not runtime
selection or invocation logic.

Scripts run with project-user permissions, not in a sandbox. Validate all
inputs, avoid embedding secrets, document network/file effects, and test every
runtime you claim to support. PowerShell scripts generated by or shipped with
Spec Kit must target Windows PowerShell 5.1. Extension templates and scripts
are replacement layers; composition strategies belong to presets.

Use hooks for commands attached to supported Spec Kit lifecycle points. Hooks
may be optional (prompt before execution) and can be ordered by priority. Use
events only when the selected integration supports the declared event contract.
Do not assume every coding agent renders hooks/events identically.

Hook keys are top-level siblings of `provides`. Common lifecycle pairs include
`before_specify`/`after_specify`, `before_plan`/`after_plan`,
`before_tasks`/`after_tasks`, `before_implement`/`after_implement`,
`before_analyze`/`after_analyze`, `before_checklist`/`after_checklist`,
`before_clarify`/`after_clarify`, `before_constitution`/`after_constitution`,
and `before_taskstoissues`/`after_taskstoissues`. Installed extensions can
define additional workflow events, such as bug-assessment hooks.

A hook value can be one mapping or a list. A hook mapping uses `command` and
may include `priority` (positive integer, default 10; lower runs first),
`optional`, `prompt`, and `description`. `condition` syntax is limited and is
not a security boundary; core command templates may skip non-empty conditions
instead of evaluating them. Hook declarations generate agent instructions; they
do not directly execute the command as a subprocess. Runtime `events` are a
separate integration-owned mechanism and may run scripts with process-user
permissions.

## Configuration

Declare config templates under `provides.config`; each entry names the
installed file and its source template. For example:

```yaml
provides:
   config:
      - name: my-extension-config.yml
         template: config-template.yml
         description: Connection and behavior settings.
         required: false

defaults:
   report:
      format: markdown
      include_details: true
```

Configuration is data, not executable code. At runtime, values merge from
lowest to highest precedence:

1. `defaults` in `extension.yml`.
2. `.specify/extensions/<id>/<id>-config.yml` (or the declared config filename).
3. `.specify/extensions/<id>/local-config.yml` for local overrides.
4. `SPECKIT_<NORMALIZED_EXTENSION_ID>_*` environment variables.

Environment-variable suffixes are interpreted as nested keys separated by
underscores. Use environment variables for secrets; never commit credentials.
Config scaffolding does not overwrite existing files. The normal `extension
add`, `extension enable`, and bundle-install paths scaffold declarations, while
initialization and update paths do not necessarily do so. Removal/update preserve
eligible top-level `*-config.yml` and `*-config.local.yml` files; document what
users should back up before removal.

## Excluding Development Files

An optional `.extensionignore` file at the package root filters files copied
during installation. It uses one Git-ignore-compatible pattern per line; blank
lines and `#` comments are ignored. The ignore file itself is always excluded.
Patterns normalize backslashes to `/` for cross-platform use.

| Pattern | Meaning |
| --- | --- |
| `*.pyc` | Match that filename pattern at any depth. |
| `tests/` | Exclude directories named `tests` and their contents. |
| `docs/*.draft.md` | Match a direct child of root `docs/`, not nested children. |
| `docs/**/*.draft.md` | Match at any depth under `docs/`. |
| `!README.md` | Re-include a matching file excluded by an earlier pattern. |

`*` and `?` do not cross `/`; `**` can span directories. Patterns containing
`/` are anchored to the extension root, except for a trailing directory slash.
Because copy operations do not descend into an excluded directory, negation
cannot restore a file under a directory that was excluded as a whole; exclude
specific generated files instead. Use `.extensionignore` for tests, CI files,
build output, and private development material, not for required runtime assets.

## Local Development and Validation

Use a disposable Spec Kit project initialized with the integration you want to
support. Install the package in development mode:

```bash
specify extension add --dev ./my-extension
specify extension list
specify extension info my-extension
```

Then verify the rendered invocation with the actual coding agent, test hooks
and configuration, switch integrations if portability is claimed, and remove
the extension. Check that removal preserves user configuration as documented.
Also test invalid manifests, missing referenced files, incompatible version
constraints, duplicate command names, and missing external tools where relevant.

For automated checks, validate the package tree and manifest before installation,
then run an acceptance test through the installed command or hook. Avoid tests
that depend only on Spec Kit's internal Python classes; extension packages do
not have a separately versioned Python plugin API.

## Release and Distribution

For public distribution, include a user-facing README, license, and versioned
release archive. Test local development, direct archive, and install-enabled
catalog installs.
For example, after publishing a pinned release archive:

```bash
specify extension add my-extension --from \
   https://example.invalid/my-extension/archive/refs/tags/v1.0.0.zip
```

The requested extension ID must match the archive manifest. Direct archive
installation requires an explicit user trust decision; HTTPS is required
except for loopback development servers. For install-by-ID and repeatable team
use, publish a catalog you control with each extension's current version and
`download_url` (and preferably its SHA-256 digest), then register it in the
project:

```bash
specify extension catalog add https://example.invalid/extensions/catalog.json \
   --name team-extensions --install-allowed
specify extension add my-extension
```

The catalog URL must use HTTPS. `--install-allowed` explicitly trusts that
catalog as an installation source; use it only for a catalog you control and
have reviewed. Without that flag, the catalog is discovery-only. Catalog
entries need a downloadable release archive to support installation. Historical
release records also require a SHA-256 digest.

Use a pinned release tag and update the extension version for every content
release; installed copies use versions to discover updates. Update the
catalog's download URL and digest with each release, and verify the digest
against the published archive. Community catalog
submissions use the Extension Submission issue flow; maintainers validate
listing metadata and package shape, not extension behavior. Do not edit the
community catalog directly. For teams, publish a catalog you control and vet;
the community catalog is discovery-only by default. A listing is not an audit
or endorsement. Review a release archive before installing it: direct archive
installation is executable project content, and catalog metadata is not
security approval.

## Troubleshooting

| Symptom | Checks |
| --- | --- |
| Invalid ID or incompatible version | Use a lowercase hyphenated ID and a PEP 440-compatible version/constraint. |
| Command is not installed | Confirm the manifest command name uses the extension namespace, the file exists, and the extension is enabled. |
| Command is not visible to the agent | Check the active integration and its native command/skill output directory; re-register or refresh after editing. |
| Referenced command works on one agent only | Replace literal agent syntax with `__SPECKIT_COMMAND_...__` and inspect the rendered invocation. |
| Helper script cannot be found | Confirm the command frontmatter path points to an existing package file and inspect the rendered script path after install. |
| Config values appear missing | Check the declared config target, the installed extension directory, the precedence layers above, and the exact `SPECKIT_...` variable name. |
| Install archive contains unexpected files | Review `.extensionignore`, then rebuild and retest the exact release archive. |

## Design Practices

- Keep one extension focused on a coherent capability. Split unrelated commands
   when users would install or upgrade them independently.
- Use descriptive hyphenated IDs and verb-noun command names.
- Minimize dependencies and explain required tools and supported versions.
- Prefer safe defaults, explicit confirmation before destructive actions, and
   clear error messages.
- Document which files/services are read or written and which credentials or
   network access are needed.
- Use SemVer-style release discipline (major for incompatible changes, minor
   for compatible features, patch for fixes) while keeping versions parseable by
   the target CLI's PEP 440 parser.
- Keep `README.md` focused on this extension: purpose, install command,
   configuration, examples, troubleshooting, and supported Spec Kit versions.

## Author Checklist

- The manifest ID, command namespace, version, and package paths agree.
- Every command, script, template, hook, event, and config file exists and is
   explained in the README.
- Compatibility, external tools, permissions, side effects, and failure modes
   are explicit.
- Local and archive installation, normal use, invalid input, and removal were
   tested in a disposable project.
- The release archive is pinned to a version and contains only intended files.
