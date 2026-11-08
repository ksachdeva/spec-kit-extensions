# Preset Authoring

A preset adapts existing instructions or artifact templates without adding a
new executable capability. Use it for terminology, standards, regulatory
sections, methodology changes, and command overrides. Use an extension when
adding a new command, tool integration, script, or process capability.

## Package Shape

```text
my-preset/
|-- preset.yml
|-- README.md
|-- LICENSE
|-- CHANGELOG.md              # recommended
|-- templates/
|   `-- spec-template.md
`-- commands/                 # optional
    `-- speckit.specify.md
```

## Manifest and Composition

```yaml
schema_version: "1.0"

preset:
  id: my-preset
  name: My Preset
  version: "1.0.0"
  description: Adds traceability requirements to planning artifacts.
  author: Example Author
  license: MIT

requires:
  speckit_version: ">=1.0"
  extensions:
    - id: my-extension
      version: ">=1.2"
      required: true

provides:
  templates:
    - type: template
      name: spec-template
      file: templates/spec-template.md
      strategy: append
  commands:
    - type: command
      name: speckit.specify
      file: commands/speckit.specify.md
      strategy: wrap

tags: [governance, traceability]
```

The ID is a lowercase hyphenated slug. File paths are package-relative. A
contribution names the logical artifact with `name` and points to its content
with `file`; the file path need not repeat the logical name. Declare extension
dependencies in the manifest, not only in a catalog listing, so local installs
carry the requirement too. Missing or version-incompatible extensions produce
a warning and can leave an override less effective than intended.

Supported strategies for templates and commands:

| Strategy | Effect |
| --- | --- |
| `replace` | Replace lower-priority content; default. |
| `prepend` | Put this content before lower-priority content. |
| `append` | Put this content after lower-priority content. |
| `wrap` | Place lower-priority content at the `{CORE_TEMPLATE}` marker. |

Use `replace` unless composition is needed. Compositions apply in priority
order; lower numeric priority wins conflicts between presets. Templates are
resolved when requested. Command output is materialized during installation
and reconciliation, so test both paths. Preset script strategies, if used by
the target CLI, are limited to replacement/wrapping; do not assume scripts are
portable between all preset versions.

## Content Design

Keep overrides focused and preserve useful behavior from the lower layer when
possible. For a `wrap` command/template, include `{CORE_TEMPLATE}` exactly
where the underlying content should be inserted. Explain any content that is
removed or materially changed. For extension command overrides, include the
required extension in `requires.extensions`; otherwise the preset may install
without the behavior it expects.

## Local Development and Validation

In a disposable initialized project:

```bash
specify preset add --dev ./my-preset
specify preset resolve spec-template
specify preset info my-preset
specify preset list
```

Inspect resolved template content and command files for the active integration.
Test overlapping presets at different priorities, each composition strategy
used, dependency absent/disabled, and remove/reinstall behavior. Preset update
is remove-then-add and is not transactional; test with disposable project data.

## Release and Distribution

Include a preset-scoped README, license, compatibility range, and versioned
release archive. The README should say what changes, when to use/not use the
preset, and include a valid `specify preset add ...` example. Community
publication uses the Preset Submission issue flow; do not directly edit the
community catalog. Community listings are discovery metadata, not code review.

## Author Checklist

- Every contribution has a supported `type`, logical `name`, valid `file`, and
  intentional strategy.
- The README explains all changed templates/commands, dependencies, priorities,
  limitations, and expected outputs.
- Local resolution, command rendering, composition, and removal have been
  checked in a disposable project.
