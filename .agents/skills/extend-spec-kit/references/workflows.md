# Workflow Authoring

A workflow is a YAML sequence that orchestrates existing Spec Kit commands,
agent prompts, shell commands, human gates, and control-flow steps. Choose it
when a repeatable multi-stage process is needed. A workflow coordinates
existing behavior; it does not register a new executable step type.

## Package Shape

```text
my-workflow/
|-- workflow.yml
|-- README.md
|-- LICENSE
`-- scripts/                 # optional companion assets
```

Minimal workflow:

```yaml
schema_version: "1.0"
workflow:
   id: example-review
   name: Example Review
   version: "1.0.0"
   author: Example Author
   description: Specify, review, and plan a small change.

requires:
   speckit_version: ">=1.0"

inputs:
   request:
      type: string
      required: true
      prompt: What should be built?

steps:
   - id: specify
      command: speckit.specify
      input:
         args: "{{ inputs.request }}"
   - id: approve-spec
      type: gate
      message: Review the specification before planning.
      options: [approve, reject]
      on_reject: abort
   - id: plan
      command: speckit.plan
```

The definition has a stable workflow ID and version, optional compatibility
requirements, declared inputs, and uniquely named steps. Each step has an `id`.
If `type` is omitted, the step is a command step. Expressions use
`{{ inputs.name }}` and `{{ steps.step-id.output.field }}` to refer to declared
inputs and earlier step outputs.

## Step Types and Control Flow

Common built-in types include:

| Type | Use |
| --- | --- |
| `command` | Invoke an installed Spec Kit command through the selected agent integration. |
| `prompt` | Send an inline prompt to an agent integration. |
| `shell` | Run a local shell command. |
| `gate` | Pause for human approval or a choice. |
| `if`, `switch` | Branch based on workflow values. |
| `while`, `do-while` | Repeat nested steps with explicit conditions. |
| `fan-out`, `fan-in` | Run a step template over items and aggregate results. |
| `workflow` | Call another installed workflow in a private scope. |
| `init` | Initialize a Spec Kit project. |

Use a built-in step before considering a custom step package. A custom type is
needed only when the engine lacks the required reusable behavior; see
[Workflow Step Packages](./workflow-steps.md).

## Safety and Execution Semantics

Workflows are not a sandbox. A `shell` step runs with the user's permissions.
Expression interpolation inserts values into strings; it does not shell-quote
or sanitize them. Never interpolate unconstrained user input, prior agent output,
or other untrusted text into `run`. Prefer typed/enum allowlists, static
commands, and human gates before sensitive operations. Document network access,
credentials, file writes, and destructive behavior.

Command and prompt output is streamed by default. Capturing output stores it in
workflow run state; treat captured agent text as untrusted. Set reasonable
capture limits and avoid storing secrets. Runs checkpoint progress and can
pause/resume, but a side effect that happened before its completion checkpoint
may happen again after interruption. Design shell actions to be idempotent or
safe to repeat where possible.

## Local Development and Validation

Run the YAML directly first:

```bash
specify workflow run ./my-workflow/workflow.yml \
   --input request="Add an account settings page"
```

Then install and test it as a package in a disposable initialized project:

```bash
specify workflow add --dev ./my-workflow
specify workflow info example-review
specify workflow run example-review --input request="Add an account settings page"
specify workflow status
```

Test successful completion, invalid/missing inputs, rejected gates, failed
commands, branching, pause/resume, captured output, and any shell side effects.
Verify companion files resolve from the installed workflow directory.

## Distribution

Ship `workflow.yml` and every required companion file in a versioned package.
Document each input, step sequence, required commands/extensions/catalogs,
integration assumptions, permissions, and how to resume or remove the workflow.
Test from a clean project with all dependencies available. Use a catalog you
control for repeatable discovery; community catalog intake rules vary by
component, so do not edit a shared catalog without its maintainer's explicit
process.
