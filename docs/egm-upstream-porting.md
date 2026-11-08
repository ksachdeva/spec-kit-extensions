# Porting EGM content from upstream

The source of truth for EGM behavior is the Git submodule at
`submodules/elephant-goldfish-model/`. The Spec Kit extension and its presets
are adapted copies, not independent redesigns. Upstream changes will continue
to arrive, so port each change deliberately and keep the necessary differences
small and visible.

## Ownership boundaries

| Concern | Source / owner | Porting rule |
| --- | --- | --- |
| EGM workflow and reviewer behavior | Upstream `skills/`, `agents/`, and `resources/` | Preserve behavior and wording unless a Spec Kit constraint requires adaptation. |
| Agent-neutral Spec Kit commands | `extensions/egm/commands/` | Adapt invocation syntax, inputs, and installed asset paths; do not add agent-specific instructions. |
| Persona and runtime assets | `extensions/egm/agents/`, `resources/`, and `references/` | Keep in sync with upstream, except for documented installed-package paths or other required adaptations. |
| Agent-specific delegation | `presets/egm-opencode-subagents/` | Keep harness instructions and persona-to-file mappings here, not in the extension commands. |

The current workflow mapping is:

| Upstream | Spec Kit package |
| --- | --- |
| `skills/egm-brainstorm/SKILL.md` | `extensions/egm/commands/speckit.egm.brainstorm.md` |
| `skills/egm-draft/SKILL.md` | `extensions/egm/commands/speckit.egm.draft.md` |
| `skills/egm-bootstrap/SKILL.md` | `extensions/egm/commands/speckit.egm.bootstrap.md` |
| `skills/egm-drift-report/SKILL.md` | `extensions/egm/commands/speckit.egm.drift-report.md` |
| `skills/egm-resolve/SKILL.md` | `extensions/egm/commands/speckit.egm.resolve.md` |
| `skills/egm-review-loop/SKILL.md` | `extensions/egm/commands/speckit.egm.review-loop.md` |
| `skills/egm-review/SKILL.md` | `extensions/egm/commands/speckit.egm.review.md` |
| `skills/egm-bootstrap/references/templates.md` | `extensions/egm/resources/egm-bootstrap/templates.md` |
| `skills/egm-bootstrap/references/worker-return.schema.json` | `extensions/egm/resources/egm-bootstrap/worker-return.schema.json` |
| `agents/<persona>.md` | `extensions/egm/agents/<persona>.md` |
| `resources/<asset>` | `extensions/egm/resources/<asset>` |
| `skills/egm-draft/references/design_doc.md` | `extensions/egm/references/design_doc.md` |

## Repeatable porting workflow

1. **Record the upstream change.** Identify the previous and current submodule
   revisions and inspect the changes to the relevant skills, personas, and
   resources. Read upstream `TEST.md` and `test_scenarios.yaml` too: they often
   capture behavior that is easy to miss in the main workflow prose. Treat
   applicable scenarios as acceptance criteria, and decide whether they can be
   run or adapted for this integration. Do not infer a change from only the
   skill file: upstream behavior may depend on an agent or a referenced
   standard/template.

   Useful commands when both revisions are available locally:

   ```sh
   git -C submodules/elephant-goldfish-model log -1 --format='%H %s'
   git -C submodules/elephant-goldfish-model diff <old-revision>..<new-revision> -- \
     skills/egm-brainstorm skills/egm-draft agents resources
   ```

2. **Trace the dependency surface.** Search the changed upstream content for
   referenced agents, resources, templates, commands, tools, and handoffs. Map
   each required file to its extension counterpart before editing.
3. **Classify each difference.** For every changed file, decide whether to:
   - copy the upstream change as-is;
   - adapt it for Spec Kit; or
   - leave it out because it belongs to an upstream integration or to a
     capability not ported here.

   Keep the reason for every intentional difference explicit. Do not silently
   retain an old behavior just because the extension copy already has it.
4. **Port the workflow before polishing.** Bring the command behavior and all
   supporting personas/assets to parity first. Then apply the Spec Kit adapter
   changes below and review the final result against upstream again.
5. **Check cross-file names and references.** A reviewer can have a persona
   name such as `egm-design` and a file such as `design_critic.md`. Keep the
   command reviewer list, persona frontmatter, actual filename, synthesizer
   roster, and integration preset mapping consistent. Add newly introduced
   personas everywhere they are required; do not assume copying the file is
   enough.
6. **Install and inspect the composed result.** Ensure the demo project is
   initialized (run `poe opencode-demo-init` if needed), then run
   `poe opencode-demo-add-egm`. Inspect the generated command files and
   installed assets under `examples/demo-app/`. Confirm that command-reference
   tokens render, the preset is prepended, and every referenced resource and
   persona exists at the installed path.
7. **Review the diff and report limits.** Run `git diff --check`, inspect the
   complete diff (including new files), and verify no upstream submodule files
   were changed unintentionally. Note any upstream capability that remains
   unported so commands do not imply it is available.

## Spec Kit adaptation rules

- Keep extension commands agent-neutral. Use `$ARGUMENTS` for caller input and
  `__SPECKIT_COMMAND_<NAME>__` for references to commands provided by this
  extension. Do not hard-code `/speckit...`, `/egm...`, or another agent's
  invocation syntax in reusable command content.
- Keep host-specific setup, tool names, and delegation recipes in the matching
  agent-integration preset. The preset should add only what that host needs;
  it should not fork the EGM workflow.
- Resolve packaged assets from the installed extension directory, for example
  `.specify/extensions/egm/agents/` and
  `.specify/extensions/egm/resources/`. A relative upstream path such as
  `resources/...` may work in the upstream checkout but fail from the user's
  project root after installation.
- Treat command tokens as references only to commands that the extension
  actually provides. If upstream hands off to an unported skill (for example,
  EGM review), describe it as a future/optional workflow instead of inventing a
  command or promising it is installed.
- Preserve upstream safeguards and content structure, including author
  resolution, explicit decision gates, artifact-first behavior, and the latest
  brief/template sections. These details are easy to lose when a port focuses
  only on the main happy path.

## Drift checks for each port

- Compare every changed upstream file with its extension counterpart. Apart
  from deliberate Spec Kit adaptations, the content should reflect the current
  upstream behavior.
- Verify that command reviewer IDs match persona `name` values and that all
  referenced persona filenames exist.
- Verify that the synthesizer's reviewer roster and any preset mapping contain
  the same required personas. The OpenCode preset must use the upstream persona
  name, not a guessed variant of the filename.
- Search commands and personas for stale command names, removed reviewers,
  host-specific invocations, old asset paths, and references to files that are
  not packaged.
- Confirm that the generated OpenCode commands contain the prepended preset,
  no unresolved Spec Kit command tokens, and working paths to installed assets.

For now, keep synchronization explicit and reviewable rather than adding a
generator that copies upstream files wholesale: the command layer requires
real integration adaptations. If the repeated mappings become a source of
errors, automate checks for parity and roster/path consistency before
automating content transformation.
