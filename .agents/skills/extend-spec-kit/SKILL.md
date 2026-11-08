---
name: extend-spec-kit
description: 'Self-contained Spec Kit authoring portal. Use when creating, adapting, testing, or publishing extensions, presets, workflows, workflow step packages, bundles, project overrides, or agent integrations.'
argument-hint: 'Describe the capability or customization you want to build'
---

# Spec Kit Customization Portal

This skill is a self-contained authoring handbook for Spec Kit's distributable
customization formats. Its method pages contain the concepts, package shapes,
examples, development loops, release guidance, and safety boundaries needed to
work without a Spec Kit source checkout or hosted documentation. The references
are the portal; do not treat them as link-out summaries.

## Portal Map

| Authoring goal | Handbook |
| --- | --- |
| Add commands, hooks, scripts, templates, or domain-specific capabilities | [Extensions](./references/extensions.md) |
| Adapt existing commands, artifact templates, or terminology | [Presets](./references/presets.md) |
| Change a template for one project only | [Project-local overrides](./references/project-overrides.md) |
| Orchestrate existing commands, prompts, scripts, and human gates | [Workflows](./references/workflows.md) |
| Add a reusable executable workflow `type:` | [Workflow step packages](./references/workflow-steps.md) |
| Distribute a curated set of existing components | [Bundles](./references/bundles.md) |
| Adapt command/skill delivery or dispatch for an AI coding agent | [Agent integrations](./references/integrations.md) |

## Using the Portal

1. Establish the desired user outcome, supported Spec Kit version, target
   integration, dependencies, and whether the component is private, reusable,
   or intended for public distribution.
2. Select the matching handbook page. If a request combines behavior and
   distribution, use separate primitives with clear ownership; for example,
   implement behavior in an extension and package that extension with a bundle.
3. Use the examples and checklists in that page to create a complete component,
   including usage documentation and stated side effects. Keep implementation
   inside the component author's repository.
4. Validate with the Specify CLI if it is available. If validation depends on a
   CLI version or feature that is not available, state the limitation and do
   not invent a successful result.
5. Summarize the component, files, behavior, validation, known limits, and
   release or catalog work still needed.

## Boundaries

- An extension that connects to an external service is still an extension. An
  agent integration adapts Spec Kit to an AI coding agent; it is not a general
  service connector.
- A bundle only composes and distributes existing components. It adds no
  runtime behavior.
- New CLI/runtime behavior that none of these component formats can provide is
  a Spec Kit core contribution, not an extension-authoring task. This portal
  does not teach changes to Spec Kit's own Python implementation.
- Community discovery does not mean code has been audited or is safe. Treat
  executable scripts, workflow shell commands, step packages, and adapters as
  untrusted code until reviewed.

## Quality Bar

- Package IDs, command names, manifests, file paths, and compatibility ranges
  agree with one another.
- A local install or run exercises the intended success path and relevant
  invalid-input, failure, cleanup, and side-effect paths.
- Documentation explains purpose, prerequisites, setup, configuration, usage,
  outputs, failure behavior, limitations, and removal.
- Releases are immutable/version-pinned where the component's publication path
  supports it. Catalog metadata matches the released package.
