# Agent Integration Authoring

An integration adapts Spec Kit command/skill delivery and optional workflow
dispatch to an AI coding agent. It is distinct from an extension that connects
Spec Kit to an external service.

## Select the Integration Route

- **Generic integration:** Use the existing generic mode when the agent can
   consume commands or skills from a configured directory. No adapter package
   is needed.
- **External adapter:** Use when distributing a new independently installable
   adapter. It is executable Python and is imported only after explicit user
   trust is granted.
- **Built-in integration:** Use only when adding a supported integration to
   Spec Kit itself. This requires modifying the core Python package, explicit
   registration, tests, docs, and maintainer review; it is not an extension
   package task.

## External Package Shape

```text
my-agent-adapter/
|-- integration.yml
|-- __init__.py
`-- helpers.py                 # optional package-local helpers
```

Descriptor:

```yaml
schema_version: "1.0"
integration:
   id: sample-agent
   name: Sample Agent
   version: "1.0.0"
   description: Adapter for Sample Agent.
   author: Example Author
   repository: https://example.invalid/sample-agent-adapter
   license: MIT
requires:
   speckit_version: ">=1.1.0"
   tools:
      - name: sample-agent
         required: true
```

The root `__init__.py` must expose exactly one concrete `IntegrationBase`
subclass, and its `key` must match `integration.id`. Reuse the host's format
base class when it matches the agent output (Markdown commands, TOML commands,
YAML recipes, or skills) rather than copying core templates.

The adapter declares agent name, output root, command/skill directory, format,
argument placeholder, file suffix, invocation separator, and CLI dispatch
behavior as appropriate. Paths must be canonical, project-local, and must not
overlap reserved `.git` or `.specify` areas or another integration's outputs.
Generated files must stay under the declared root and be tracked through the
host's integration manifest. The adapter does not own shared infrastructure.

## Development and Validation

Document installation prerequisites, executable names, supported output format,
command invocation, model/options handling, and workflow dispatch support.
Test:

- Descriptor/class identity mismatch, missing required tools, invalid version
   constraints, and malformed package/archive paths.
- Generated commands/skills, argument substitution, and workflow dispatch when
   supported.
- Trust denial before import, fresh-process loading, update, uninstall, and
   recovery after modified or missing files.
- Output path traversal, reserved roots, symlinks, and overlap with other
   integrations.

Do not rely only on direct in-memory class registration. Exercise the installed
package using a fresh CLI process and review its import-time behavior.

## Trust and Distribution

Catalog listing or discovery does not import adapter code. An install-enabled
catalog permits download, not execution without consent. Trust is local to the
user/project and bound to the reviewed package; a catalog entry is not a code
audit. Review all Python files and dependencies before granting trust.

Publish a pinned archive and catalog metadata that exactly matches the package
descriptor; an archive SHA-256 digest is recommended. Explain that users must
review and trust the executable adapter. Keep public external adapters separate
from built-in integration code. Built-in additions require a Spec Kit source
checkout and project-specific contribution process, which this standalone
portal does not assume.
