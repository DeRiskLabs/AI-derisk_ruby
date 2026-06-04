# common_agent_skills/derisk_ruby/testing-base-classes/references/checklist.md


# Review Checklist — Base Class / Mixin Module Specs


## Setup

- [ ] Includers built as anonymous classes (`Class.new { include … }` / `Class.new(described_class)`),
      never as fixture classes added to the repo.
- [ ] The suite's own spec helper required, as appropriate.


## Contract coverage

- [ ] Composition asserted via `included_modules` for each promised module.
- [ ] Class-level DSL methods asserted with `respond_to`.
- [ ] Declarations endow instances (reader/writer present; declaration tracked).
- [ ] Initialization defaults asserted (injected collaborators, derived state).
- [ ] Abstract methods raise `NotImplementedError` for a bare subclass.
- [ ] Argument validation raises the correct error (missing required / unexpected argument).


## Constructor specs

- [ ] `#initialize` tested only on base classes / DSL modules where initialization is the
      contract — never on ordinary domain classes.
- [ ] Subject is `described_class.allocate` (or `test_class.allocate`); the action is
      `execute { object.send(:initialize, **init_args) }`.
- [ ] Arguments layered through lets (`init_args` / `test_args`) so contexts override one
      input at a time.
- [ ] Raising cases use the block-expectation form inside `it`, still via `allocate` + `send`.


## Behaviour

- [ ] Base-provided behaviour exercised through a concrete subclass and `execute`, asserting
      with `have_received` — not by stubbing internals.
- [ ] `send(:private)` used only when no public entry point exists.


## Hygiene

- [ ] One expectation per `it`.
- [ ] Assertions reference the real module/constant names (no stale renames).
- [ ] No re-testing of the standard library or framework through the base class.
