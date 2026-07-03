---
name: always-execute-rspec
title: Always Execute RSpec Pattern
description: Use the always_execute gem's execute block to separate setup, action, and assertion in RSpec specs, and choose the right assertion target for the action under test. Applies whenever writing or modifying Ruby specs.
category: testing
status: active
version: 3.5
applies_to:
  - Ruby
  - Rails
  - RSpec
  - always_execute
priority: REQUIRED
triggers:
  - writing specs
  - action under test placement
  - execute block
  - execute_result
anti_triggers:
  - non-Ruby test suites
user_invocable: true
last_reviewed_at: "2026-06-03"
---


# Always Execute RSpec Pattern

Use this skill when writing or modifying Ruby specs. It owns the execute-pattern **mechanics**
(setup → execute → assert, the assertion-target grid, request specs); the project-wide testing
**standards** (coverage principle, layered lets, matcher selection, boundaries, doubles, style)
live in [[ruby-testing]].

Supporting references in this skill (load when writing specs with this pattern):

```text
references/annotated-example.md  # full service-object and request specs, line by line
references/checklist.md          # pre-merge review checklist
```


## Purpose

The `always_execute` gem provides an `execute do ... end` block for RSpec. It separates:

```text
setup → execute → assert
```

so specs are easier to read, easier to review, and consistent across the codebase.


## Mechanics

`execute` registers the action under test. The block runs automatically once at the
start of every example in scope, after `before` hooks. Examples then contain
assertions only.

The block's return value is exposed through the `execute_result` let:

```ruby
execute do
  finder.call
end

it 'returns the matching territory' do
  expect(execute_result).to eq(territory)
end
```

Name the result when it reads better:

```ruby
execute(:found_territory) do
  finder.call
end

it 'returns the matching territory' do
  expect(found_territory).to eq(territory)
end
```

Always use the let. The gem also stores the value in an `@execute_result` instance
variable, but do not use instance variables in specs.


## Scope, Nesting, and Override

`execute` behaves like a `before` hook plus a `let`:

- An `execute` defined on a group applies to **every example in that group and all
  nested contexts** — nested contexts inherit it.
- A nested `execute` **replaces** the inherited one for its own examples, exactly like
  overriding a `let`. Blocks never stack: each example runs exactly one execute block,
  the innermost.
- The block re-runs for every example; results are never shared between examples.

Because an inherited `execute` runs at the start of each example, a raising case must
never inherit an `execute` whose block raises — the example errors before its
assertions run. When one action has both succeeding and raising cases, keep `execute`
out of the shared describe: give each non-raising context its own `execute`, and let
raising contexts use the block-expectation form with no inherited action:

```ruby
describe '.call' do
  context 'when the class implements #call' do
    execute do
      test_class.call('arg1')
    end

    it 'instantiates and calls the class' do
      expect(execute_result).to eq(args: ['arg1'])
    end
  end

  context 'when the class does not implement #call' do
    it 'raises NotImplementedError' do
      expect { test_class.call }.to raise_error(NotImplementedError)
    end
  end
end
```


## Non-Negotiable Rules

- When there is an action under test, it MUST be called inside `execute`. Never inside `it`.
- An `it` block contains assertions only — one expectation per `it`.
- Setup belongs in `let` / `let!` / `subject` / `before`. All stubbing belongs in `before`.
- One action per `context`. Multiple `it` blocks assert different outcomes of the same action.

Good:

```ruby
execute do
  activator.call
end

it 'marks the territory active' do
  expect(territory.reload).to be_active
end
```

Bad:

```ruby
it 'marks the territory active' do
  activator.call
  expect(territory.reload).to be_active
end
```


## Exceptions

**Raising actions.** When the contract is that the action raises, a raising `execute`
block would fail every example before its assertions run. Use the block-expectation
form inside `it` — one raise assertion per `it`:

```ruby
context 'with missing required inputs' do
  it 'raises MissingRequiredInputs' do
    expect do
      input_object.send(:initialize)
    end.to raise_error(Layers::DSL::MissingRequiredInputs)
  end
end
```

**Constructors.** Most classes never test `#initialize` directly — it is a private
implementation detail exercised through public behaviour. Where initialization is the
contract (base classes, DSL modules), it stays inside `execute`: allocate the instance
in `subject`, then invoke the constructor via `send` as the action under test. See
[[testing-base-classes]]:

```ruby
subject(:layer) { described_class.allocate }

let(:init_args) { {} }

execute do
  layer.send(:initialize, **init_args)
end
```

**Delta assertions.** When the behaviour under test is "the action changes X", use a
`change` block matcher — the action runs inside the expectation, one delta per `it`:

```ruby
it 'generates a new verification code' do
  expect { email_address.request_verification! }
    .to change(email_address, :verification_code)
end
```

**Self-contained query expectations.** One-liner contract assertions
(`it { is_expected.to be_valid }`, `respond_to`, shoulda matchers) and
single-expectation return-value checks on a pure query may call the query inline —
the expectation wraps the action and nothing else depends on it having run:

```ruby
it { is_expected.not_to be_valid }

it 'returns a new order with the customer name' do
  expect(form.order.customer_name).to eq('Ada Lovelace')
end
```

`execute` remains mandatory the moment an example asserts the action's **aftermath** —
state it populated, messages it sent, errors it added:

```ruby
execute do
  form.valid?
end

it 'adds an error message' do
  expect(form.errors[:line_items]).to be_present
end
```


## Choosing the Assertion Target

Most specs do not assert against `execute_result`. Choose the assertion target from
the message-testing grid (Sandi Metz, "The Magic Tricks of Testing") — assert at the
object's boundaries:

| The action under test is...                     | Assert                                                  |
| ----------------------------------------------- | ------------------------------------------------------- |
| an incoming query (returns a value)             | the return value, via `execute_result` or a named let   |
| an incoming command (changes state)             | the resulting public state change                       |
| an outgoing command (tells a collaborator)      | the message was sent: `have_received` on a spy          |
| an outgoing query (asks a collaborator)         | nothing — stub it in setup                              |
| a message to self / a private method            | nothing — never test these                              |

Examples:

```ruby
# incoming query — assert the return value
it 'returns the matching territory' do
  expect(execute_result).to eq(territory)
end

# incoming command — assert the state change
it 'marks the territory active' do
  expect(territory.reload).to be_active
end

# outgoing command — assert the message was sent
it 'notifies the listener of success' do
  expect(listener).to have_received(:on_success).with(territory: territory)
end
```


## Request Specs

HTTP verbs (`get`, `post`, `patch`, `put`, `delete`) are actions under test. They MUST
be called inside `execute`:

```ruby
execute do
  post '/api/territories', headers: headers, params: params
end
```

Request specs assert against `response` and `parsed_response`, not `execute_result`:

```ruby
let(:parsed_response) { JSON.parse(response.body) }

it 'returns ok' do
  expect(response).to have_http_status(:ok)
end

it 'returns the territories collection' do
  expect(parsed_response.fetch('data')).to be_an(Array)
end
```

If the suite does not already provide `parsed_response`, define it as a `let` as above.


## Precedence

This skill overrides older project examples that place actions inside `it` blocks or
assert via `@execute_result`. Do not copy older specs that violate this pattern.
