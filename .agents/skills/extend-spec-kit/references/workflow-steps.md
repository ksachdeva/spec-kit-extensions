# Workflow Step Package Authoring

A workflow step package adds one reusable executable `type:` to workflows.
Choose it only when the built-in steps cannot express the behavior. Unlike a
workflow YAML file, a step package contains Python code. The loader imports and
executes that code with the user's privileges; there is no capability sandbox.

## Package Shape and Identity

```text
my-step/
|-- step.yml
|-- __init__.py
`-- helpers.py                 # optional; include every required module
```

One package provides exactly one step type. The package ID, `step.type_key`,
catalog ID, and Python class `type_key` must be identical. `step.yml` and
`__init__.py` must be regular files at the package root. Archives may have one
enclosing directory; avoid symlinks, path traversal, case-colliding file names,
and unnecessary package contents.

Example `step.yml`:

```yaml
schema_version: "1.0"
step:
   type_key: validate-record
   name: Validate Record
   version: "1.0.0"
   author: Example Author
   description: Validate a record and return a structured result.
requires:
   speckit_version: ">=1.0"
```

## Python Contract

Subclass `StepBase`, set the matching `type_key`, and implement `execute`.
Validate configuration both in `validate` and at execution time: some callers
may invoke execution without first running workflow-level validation.

```python
from specify_cli.workflows.base import (
      StepBase,
      StepContext,
      StepResult,
      StepStatus,
)


class ValidateRecord(StepBase):
      type_key = "validate-record"

      def validate(self, config: dict) -> list[str]:
            errors = super().validate(config)
            if not isinstance(config.get("value"), str):
                  errors.append("'value' must be a string.")
            return errors

      def execute(self, config: dict, context: StepContext) -> StepResult:
            value = config.get("value")
            if not isinstance(value, str):
                  return StepResult(
                        status=StepStatus.FAILED,
                        error="'value' must be a string.",
                  )
            return StepResult(output={"valid": bool(value.strip())})
```

`StepContext` contains resolved workflow inputs, prior step results, workflow
defaults, project/run paths, and resume/fan-out context. Return a `StepResult`
with a status, output mapping, and an error when failing. Outputs are persisted
and available to later expressions as `steps.<id>.output.<key>`.

The engine keeps one shared instance per step type. Fan-out can call that
instance concurrently. Keep implementations stateless and thread-safe: store
per-run data in `config` and `context`, not on `self`. Do not manage run-state
checkpoints inside the step; the workflow engine owns lifecycle and persistence.

## Dependencies and Side Effects

The CLI does not install or resolve third-party dependencies for custom steps.
Use host-provided packages where possible; otherwise document exact dependency
versions and installation instructions. Avoid import-time side effects. State
all filesystem, network, process, and credential behavior in the package README.
Make writes idempotent where possible because interruption can cause a step to
be attempted again before its completion checkpoint.

## Development and Tests

Install from a local package directory:

```bash
specify workflow step add validate-record --dev ./my-step
```

Create a small workflow using `type: validate-record` and exercise it through
the CLI. Test valid and invalid configurations, output shape, failure status
and message, missing dependencies, side effects, and behavior inside a
workflow's resume/fan-out paths when those apply. Remove the package after the
test. Do not treat a unit test that directly instantiates the class as proof
that package loading works.

## Public Distribution

Publish a versioned release archive and document installation, configuration,
dependencies, outputs, failures, permissions, and example workflow usage.
Community step submissions use a dedicated submission issue and require
tag-pinned package file URLs plus a SHA-256 digest for every catalog-downloaded
file. The default community catalog is discovery-only. Maintainers validate
metadata and package shape, not the Python implementation; catalog listing is
not trust or execution consent. Review code before installation.
