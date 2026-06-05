---
name: testing-base-classes
title: Testing Base Classes and Mixin Modules
description: Spec pattern for abstract base classes and mixin DSL modules using anonymous includers and contract assertions; defines when and how to test constructors (allocate + execute). Use when testing a base class or a module meant to be included.
category: testing
status: active
version: 2.0
applies_to:
  - Ruby
  - RSpec
priority: REQUIRED
triggers:
  - base class spec
  - abstract class spec
  - mixin module spec
  - DSL module spec
  - included_modules assertion
  - constructor spec
anti_triggers:
  - concrete domain class spec
  - model spec
  - request spec
user_invocable: true
last_reviewed_at: 2026-06-04
---


# Testing Base Classes and Mixin Modules

Use this skill to test abstract base classes and the mixin modules that compose them.
These have no real domain behaviour of their own; you test the **contract** they give
includers and subclasses.


## Required Reading

```text
common_agent_skills/derisk_ruby/ruby-testing/SKILL.md
common_agent_skills/derisk_ruby/always-execute-rspec/SKILL.md
```

Supporting references in this skill:

```text
references/annotated-example.md   # a full DSL-module spec, annotated
references/checklist.md           # review checklist
```


## Exercise via Anonymous Includers

Never add fixture classes to the codebase to test a base/module. Define them inline so the
spec is self-contained:

```ruby
subject(:test_class) do
  Class.new do
    include Auditable
    audit :name, :email
  end
end
```

For a base class, subclass `described_class` inline and give it a minimal implementation
of the abstract method.


## What to Assert (the contract)

1. **Composition** — the base includes the modules it promises:
   ```ruby
   it { expect(described_class.included_modules).to include(Auditable) }
   ```
2. **Class-level DSL** — the module adds the declaration methods:
   ```ruby
   it { is_expected.to respond_to(:audit) }
   ```
3. **Generated behaviour** — declarations endow instances:
   ```ruby
   it 'endows instances with a reader' do
     expect(test_class.new(name: 'Ada')).to respond_to(:name)
   end
   ```
4. **Defaults / initialization** — collaborator defaults, derived state — via the
   constructor pattern below.
5. **Abstract methods raise** — the contract subclasses must fulfil:
   ```ruby
   it 'requires subclasses to implement #perform' do
     expect { Class.new(described_class).new.perform }.to raise_error(NotImplementedError)
   end
   ```
6. **Validation of inputs** — missing required / unexpected arguments raise the right
   error — via the constructor pattern below.


## Constructor Specs

Most classes do not test `#initialize` directly — construction is a private implementation
detail exercised through public behaviour. Test the constructor only where initialization
**is** the contract: base classes and DSL modules (defaults, injected collaborators,
argument validation).

Where relevant, keep the action inside `execute`: allocate the instance in `subject`, then
invoke `#initialize` via `send` as the action under test. Layer the arguments through lets
so contexts override one input at a time:

```ruby
describe '#initialize' do
  subject(:command) { described_class.allocate }

  let(:init_args) { {} }

  execute do
    command.send(:initialize, **init_args)
  end

  context 'with no arguments' do
    it 'defaults the clock' do
      expect(command.clock).to be(Time)
    end
  end

  context 'with a custom clock' do
    let(:clock) { double('Clock') }
    let(:init_args) { { clock: clock } }

    it 'uses the custom clock' do
      expect(command.clock).to be(clock)
    end
  end
end
```

Raising cases use the block-expectation form inside `it` (see always-execute-rspec
Exceptions), still through `allocate` + `send` so no fixture class is constructed twice:

```ruby
context 'with a missing required argument' do
  it 'raises ArgumentError' do
    expect do
      command.send(:initialize)
    end.to raise_error(ArgumentError)
  end
end
```


## Behaviour Through a Concrete Subclass

For behaviour the base provides but only invokes internally, define a small concrete
subclass with a real public entry point and assert at the boundary — `have_received` on an
injected spy, or observable state — never by stubbing the object under test or poking
privates when a public path exists:

```ruby
subject(:command) { test_class.new(notifier: notifier) }

let(:notifier) { spy('Notifier') }

let(:test_class) do
  Class.new(described_class) do
    def perform
      succeed(ok: true)
    end
  end
end

execute do
  command.perform
end

it 'notifies the notifier of success' do
  expect(notifier).to have_received(:on_success).with(ok: true)
end
```


## Hygiene

- Assert the real module/constant names — a stale rename in a spec is a false contract.
- One expectation per `it`; the action under test inside `execute` (sanctioned
  exceptions aside).
- Do not re-test the standard library or a framework through the base class; pin only
  what the base itself declares and does.
