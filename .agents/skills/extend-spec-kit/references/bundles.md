# Bundle Authoring

A bundle installs a curated set of existing extensions, presets, workflows,
and workflow step packages as one role/team setup. It is a composition and
distribution layer: it does not contain arbitrary new runtime behavior.
Implement behavior in the appropriate component, then use a bundle to make the
set reproducible.

## Package Shape

```text
my-bundle/
|-- bundle.yml
|-- README.md
|-- LICENSE
`-- CHANGELOG.md               # recommended
```

Minimal `bundle.yml`:

```yaml
schema_version: "1.0"
bundle:
   id: developer-setup
   name: Developer Setup
   version: "1.0.0"
   role: developer
   description: A reviewed setup for implementation work.

requires:
   speckit_version: ">=1.0"
   tools: []
   mcp: []

provides:
   extensions:
      - id: my-extension
         version: "1.2.0"
   presets:
      - id: my-preset
         version: "1.0.0"
         priority: 10
         strategy: replace
   workflows:
      - id: review-flow
         version: "1.0.0"
   steps:
      - id: validate-record
         version: "1.0.0"

tags: [developer, quality]
```

IDs are unique within each component kind. Pin versions for reproducibility.
Preset references may set install priority and strategy. An optional `source`
names the expected winning component catalog; it is not a download URL and does
not override catalog precedence or install permissions. A bundle may declare
requirements satisfied by independently installed components; requirements do
not imply that the bundle owns or removes those components.

## Component Resolution

Each component is installed through its own manager and resolved from its own
bundled copy, installed state, or active catalog. A bundle catalog only
distributes the bundle manifest; it does not make component catalogs available
or install-allowed. If any component comes from a non-default catalog, document
that catalog URL and test the complete setup from a clean project.

At present, do not assume step package source files can be embedded and resolved
from a bundle. Step IDs resolve through active step catalogs. Verify all source
and offline assumptions before promising offline installation.

## Build and Validate

From the bundle directory:

```bash
specify bundle validate
specify bundle build
specify bundle info ./dist/developer-setup.zip
```

Then install the artifact in a clean project and inspect the expanded component
plan. Check missing versions, disabled/incompatible integrations, catalog
policies, shared component conflicts, and any prerequisites. Test removal to
ensure it removes only components contributed by this bundle and preserves
independently installed or shared components.

## Publishing

Publish a versioned artifact created by the CLI and a bundle-scoped README. The
README should state the intended role, exact component set, required catalog
URLs, integration assumptions, permissions, limitations, and clean install
example. Community publication uses the Bundle Submission issue flow; do not
edit the community catalog directly. Maintainers validate listing metadata
and dependency declarations, not the behavior of the bundle's components.

## Trust and Ownership

Review every component and every catalog it depends on. A bundle preview is a
plan, not a security audit. Bundles track which components they contributed;
avoid presenting a bundle as taking ownership of components installed by users
or other bundles. Keep component pins and source expectations stable across
releases, and document breaking changes.
