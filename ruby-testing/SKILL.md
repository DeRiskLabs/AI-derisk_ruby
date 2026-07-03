---
name: ruby-testing
title: Ruby Testing Standards
description: Project-wide Ruby and RSpec testing standards - layered lets, deep context trees, matcher selection, one-liner contract pinning, boundary stubbing, doubles, and the complete-fast-ours coverage principle. Applies whenever writing or modifying Ruby specs.
category: testing
status: active
version: 2.4
applies_to:
  - Ruby
  - Rails
  - RSpec
priority: REQUIRED
user_invocable: true
last_reviewed_at: "2026-06-03"
---


# Ruby Testing

Use this skill when writing or modifying Ruby specs. It owns the project-wide testing
**standards**; the execute-pattern **mechanics** — where the action, setup, and stubbing go,
one expectation per `it`, the assertion-target grid, request specs — are owned by
[[always-execute-rspec]]. Load both; this skill does not restate the mechanics.


## Required Reading

```text
[[always-execute-rspec]]
```


## Coverage Principle: Complete, Fast, Ours

Test **everything the object under test declares and does** — the spec documents what we
told the code to do. But do not re-test the framework, the standard library, or a gem's
own behaviour; and do not pay for expensive setup (database, real I/O) where the
behaviour under test does not need it. Necessary slow tests are fine; unnecessary ones
are waste.


## Non-Negotiable Rules

The execute-pattern mechanics are owned by [[always-execute-rspec]] (action inside `execute`,
setup/stubbing in `before`/`let`, one expectation per `it`, one action per context, results via
the `execute_result` let — never instance variables). This skill adds the project-wide
standards:

* Use RSpec, with `describe` / `context` blocks separating behaviours and cases.
* Use single-quoted strings unless interpolation is required.
* Test behaviour, not implementation.
* Test through public interfaces; do not test private methods directly.
* Do not stub the object under test.


## Layered Lets

Layer inputs through lets so each context overrides exactly one thing. The base layer
defines the valid whole; contexts re-point a single leaf:

```ruby
let(:params) { valid_params }
let(:valid_params) { { name: name, email: email } }
let(:name)  { 'Ada' }
let(:email) { 'ada@example.com' }

context 'with a blank name' do
  let(:name) { '' }

  it { is_expected.not_to be_valid }
end
```

This is the universal discipline: one overridden `let` per context, whether the input is
a params hash, a collaborator, or a header.


## Deep Context Trees

When the outcome depends on several variables, **nest one context per variable** — the
tree enumerates the combinations that matter and the nested descriptions read as a truth
table. Depth is not a smell; it mirrors the decision tree of the code under test.

Ignore generic "avoid deep nesting" advice: do NOT flatten distinct input combinations
into fewer examples, stack expectations to save levels, or skip combinations that change
the outcome. Every combination that produces a different observable result gets its own
context and its own examples.


## Assertion Rules

An `it` block contains one expectation. Choose the assertion target from the boundary grid in
[[always-execute-rspec]] — return value for incoming queries, state change for incoming
commands, `have_received` on a spy for outgoing commands; stub outgoing queries; never assert
messages to self.


## Matcher Selection

Pick the matcher that states the behaviour exactly:

- **Same object (identity)** → `be(thing)`, never `eq` — `eq` silently passes through a
  future `==` override.
- **Exact set, any order** → `contain_exactly(*records)` — proves inclusion AND exclusion
  in one assertion.
- **A delta** → `change { ... }` block matchers (and `not_to change` for "unchanged").
- **A message** → `have_received(:message).with(...)` on a spy — the payload is part of
  the contract; assert it.
- **A predicate** → `be_valid` / `be_verified` one-liners over `eq(true)`.


## Fluent / Chainable Interfaces

A method designed for chaining (returns `self` after mutating internal state) has a
two-part contract — pin both halves, each in its own example:

1. **Identity**: the return value is the object under test — `expect(result).to be(subject)`.
2. **Mutation**: the internal collaborator received the intended message
   (`have_received` on an injected spy), or the observable behaviour reflects the change.


## One-Liner Contract Pinning

One-liners are the house form for pinning declarations — module composition,
duck types, simple validations:

```ruby
it { is_expected.to respond_to(:errors) }
it { is_expected.to validate_presence_of(:email) }
it { is_expected.not_to be_valid }
```

They are self-contained query expectations (see [[always-execute-rspec]]) and need no
`execute` or docstring.


## Boundary Rules

All stubbing belongs in setup, usually `before` (see [[always-execute-rspec]]). Stub at
architectural boundaries:

* repositories
* gateways
* clients
* queues
* file systems
* clocks
* random generators
* external services

Avoid real I/O, network, queues, clocks, randomness, or external services in unit specs.


## Doubles

Prefer verifying doubles when practical.

Use doubles for external collaborators; use `instance_spy` when the spec asserts
outgoing messages with `have_received`.

Good:

```ruby
let(:repository) { instance_double(Repository) }
let(:listener)   { instance_spy('Listener') }
```

Use plain doubles when the collaborator does not have a stable class/interface.


## Shared Examples and Contexts

Shared examples are for **cross-suite contracts** — behaviours many specs must pin the
same way (authentication posture, error envelopes). They own their assertions and borrow
the host spec's lets, so document which lets they expect. Do not use shared examples to
hide a single spec's own logic, and do not overuse them.


## Private Methods

Do not test private methods directly.

If a private method feels like it needs direct testing, extract a new object with a public interface.


## Style

Use readable, behaviour-focused example names.

Good:

```ruby
it 'returns the matching territory' do
  expect(execute_result).to eq(territory)
end
```

Bad:

```ruby
it 'works' do
  expect(execute_result).to eq(territory)
end
```

Within an example group, separate the stanzas with blank lines — subject, then lets,
then `before`, then `execute`, then the examples — and give `execute` blocks a blank
line either side.


## Avoid

Do not:

* flatten or skip outcome-changing input combinations
* test private methods directly
* test the framework, the standard library, or gems instead of your own code
* use expensive setup (DB, I/O) where the behaviour does not need it
* create custom helper methods in unit specs
* hide important setup
* use shared examples to hide a spec's own logic
* overuse `before`
* assert implementation details when behaviour can be asserted

(For the execute-pattern don'ts — action, setup, or stubbing inside `it`, and multiple
expectations per `it` — see [[always-execute-rspec]].)
