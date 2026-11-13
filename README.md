# SpecKit Extensions

## Install EGM

From the root of your initialized Spec Kit project, install EGM from its
published GitHub release:

```bash
specify extension add egm --from \
	https://github.com/ksachdeva/spec-kit-extensions/releases/download/egm-v0.9.1/egm-0.9.1.zip
```

The EGM extension requires Spec Kit `0.9.0` or newer and provides the
`speckit.egm.*` commands.

### Install from the Catalogs

Alternatively, register these catalogs in your Spec Kit project and install by
component ID. Mark a catalog as install-allowed only if you trust and have
reviewed its contents.

```bash
specify extension catalog add \
	https://raw.githubusercontent.com/ksachdeva/spec-kit-extensions/main/extensions/catalog.json \
	--name spec-kit-extensions --install-allowed
specify preset catalog add \
	https://raw.githubusercontent.com/ksachdeva/spec-kit-extensions/main/presets/catalog.json \
	--name spec-kit-extensions --install-allowed

specify extension add egm
specify preset add egm-opencode-subagents
```

### OpenCode Sub-Agent Preset

The preset is optional and intended for projects using OpenCode. Install EGM
first, then install the preset from its published GitHub release:

```bash
specify preset add egm-opencode-subagents --from \
	https://github.com/ksachdeva/spec-kit-extensions/releases/download/egm-opencode-subagents-v0.5.1/egm-opencode-subagents-0.5.1.zip
```

It adds sub-agent delegation guidance to selected EGM commands and requires
EGM `0.9.0` or newer.

## TODO

- Develop presets for coding agents beyond OpenCode.

## EGM upstream porting

When porting skills, agents, or shared resources from the upstream Elephant &
Goldfish Model repository, follow the
[EGM upstream porting guide](docs/egm-upstream-porting.md).
