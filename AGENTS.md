# Speckit Extensions

This repository develops and demonstrates Spec Kit customizations. Use the
`extend-spec-kit` skill in `.agents/skills/extend-spec-kit/` as the authoring
handbook when creating or changing an extension, preset, or other customization.

## Repository Layout

- `.agents/skills/extend-spec-kit/`: authoring guidance and references for Spec
	Kit customization formats.
- `extensions/egm/`: the Elephant-Goldfish Model extension. See `extension.yml`
	and `commands/` for its current command set and prompt files.
- `presets/egm-opencode-subagents/`: an OpenCode-oriented preset that adds
	sub-agent delegation guidance to those EGM commands.
- `examples/demo-app/`: the sample Spec Kit project used to try the extension
	and preset together.
- `submodules/elephant-goldfish-model/`: the upstream Elephant-Goldfish Model
	project, included as a Git submodule reference. It is separate from the
	distributable customization in `extensions/egm/`.
- `docs/`: repository-level documentation.
- `poe.toml`: local development tasks. `pyproject.toml` and `uv.lock` define
	the Python development environment and tools.

## Local Development

Use the `poe` command for the sample app lifecycle rather than running
`specify` commands manually. In this devcontainer, `poe` is available through
an alias. From the repository root:

1. `poe opencode-demo-init` initializes `examples/demo-app/` with the
	 OpenCode integration.
2. `poe opencode-demo-add-egm` installs the local EGM extension and
	 OpenCode preset into the sample app in development mode.
3. `poe opencode-demo-run` starts OpenCode with the sample app as its
	 working directory.

The demo tasks are defined in `poe.toml`. The `fmt` task is available as
`poe fmt`. When validating a customization, follow the relevant checks
in the authoring skill and report any unavailable validation tools or limits.
