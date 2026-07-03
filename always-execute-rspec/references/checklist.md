# Always Execute Review Checklist

Run through this before committing a spec.


## Structure

- [ ] Every action under test is inside an `execute` block — never inside `it`.
- [ ] One action per `context`; each `execute` block contains exactly one action.
- [ ] Every `it` block contains exactly one expectation and nothing else.
- [ ] Setup lives in `let` / `let!` / `subject` / `before`; all stubbing lives in `before`.
- [ ] No instance variables; the result is read via `execute_result` or a named `execute(:name)` let.
- [ ] Example names describe behaviour ("returns the matching territory"), not "works".
- [ ] Single-quoted strings throughout, unless interpolation is required.


## Assertion Targets

- [ ] Incoming query → asserts the return value via `execute_result` / named let.
- [ ] Incoming command → asserts the public state change.
- [ ] Outgoing command → asserts `have_received` with the expected arguments on a spy.
- [ ] Outgoing queries are stubbed, never asserted.
- [ ] No assertions on private methods or messages to self.
- [ ] Request specs assert `response` / `parsed_response`, not `execute_result`.
- [ ] Raising actions use the block-expectation form (`expect do ... end.to raise_error`)
      inside `it` — never inside `execute`; one raise assertion per `it`.
- [ ] No raising context inherits an `execute` whose block raises — when an action has
      both succeeding and raising cases, `execute` lives in the non-raising contexts,
      not the shared describe.
- [ ] Delta assertions use `change` block matchers (the action inside the expectation);
      one delta per `it`.
- [ ] `execute` present whenever an example asserts the action's aftermath (state populated,
      errors added, messages sent); inline query calls only where the expectation wraps the
      call itself (one-liners, return-value checks).
- [ ] `#initialize` tested only where it is the contract (base classes / DSL modules),
      via `allocate` in subject + `execute { object.send(:initialize, **args) }` —
      see [[testing-base-classes]].


## Smells

- [ ] No `expect(@execute_result)` — use the let.
- [ ] No stubbing of the object under test.
- [ ] No `allow(...)` inside `it` blocks.
- [ ] No copying of older specs that place actions inside `it` blocks.
