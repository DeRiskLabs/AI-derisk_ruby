---
name: object-oriented-boundaries
title: Ruby Object-Oriented Boundaries
description: Use when designing or changing Ruby objects, choosing public methods, extracting collaborators, protecting encapsulated state, or deciding how objects should talk to each other through message protocols.
category: object-design
status: active
version: 2.0
applies_to:
  - Ruby
priority: REQUIRED
triggers:
  - ruby object design
  - object boundary
  - public interface
  - encapsulation
  - extract a class
  - god object
  - message passing
  - collaborator
anti_triggers:
  - mechanical refactors with no design decision
user_invocable: true
last_reviewed_at: "2026-06-26"
---


# Ruby Object-Oriented Boundaries

Read [[bounded-contexts]] when the decision is about architecture-scale ownership,
component boundaries, gems, engines, services, or where behavior belongs.

Use this skill for Ruby object design inside a known boundary.

Ruby object-oriented code is message passing, encapsulated state, and clear public
protocols. Most agent-generated Ruby gets this wrong by making large public
interfaces, exposing state, or reaching through other objects to do their work.


## Core Rules

1. Design the object's public messages before its private methods.
2. Keep state behind the object boundary.
3. Tell collaborators what you need; do not ask for their state and decide for them.
4. Depend on protocols: a collaborator is anything that answers the message you send.
5. Extract collaborators when an object has multiple lower-level responsibilities that still belong behind the same public boundary.
6. Keep the public interface small enough that callers can understand the object's role.
7. Test the object through its public interface.


## Public Interface

Every public method is a promise to callers. Make public methods intentional.
Private methods and internal collaborators are implementation details.

Good public messages describe what the caller wants from the object:

```ruby
invoice.mark_paid(payment)
registration.register(email:, name:)
```

Weak public messages expose structure or force the caller to manage internals:

```ruby
invoice.status = "paid"
registration.user_builder.profile_creator.role_assigner.call(...)
```

If callers need to know internal order, internal classes, or mutable state, the
object boundary is leaking.


## Collaborators

Do not extract objects just to make files smaller. Extract a collaborator when it
names a real lower-level responsibility, hides detail, or lets the parent object
keep a clear public role.

The parent object's public interface should usually stay stable when you decompose
its internals. If extraction forces outside callers to coordinate the new objects,
you probably split the boundary instead of decomposing inside it.


## Commands and Queries

- A command asks an object to do something or change state.
- A query asks a question and should not change state.
- Avoid query methods with hidden side effects.
- Do not ignore meaningful command outcomes when the public contract includes them.


## Testing

Test object behavior through public methods:

- incoming query: assert the return value
- incoming command: assert public state change or observable outcome
- outgoing command to a collaborator: assert the message when that collaboration is the behavior
- outgoing query to a collaborator: stub the answer when needed

Do not test private methods directly. Internal collaborators earn their own tests
only when they have their own meaningful public boundary.

See [[ruby-testing]] and [[always-execute-rspec]].

Use [[collaborator-extraction]] when an object should keep the same public role but
needs internal decomposition.


## Smells

- Public readers for state that callers mutate or use to make the object's decisions.
- Call chains that walk through internal structure.
- Public methods added only so tests can reach private behavior.
- Collaborators named outside the boundary that owns them.
- A class that keeps growing because no internal responsibility has been named.
- A tiny extracted object with no clear protocol or reason to exist.


## Stop and Ask

Ask the human before deciding when:

- extracting a collaborator would change the caller-facing interface
- callers appear to need data owned by another object
- the object depends heavily on framework classes or callbacks
- you cannot tell whether behavior belongs in this object or a larger boundary


## Completion Criteria

Done when the object's public messages, owned state, collaborators, command/query
shape, and public-interface tests are clear, with no caller depending on private
methods or internal sequencing.
