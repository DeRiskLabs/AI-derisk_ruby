---
name: object-oriented-boundaries
title: Object-Oriented Boundaries
description: What object-oriented programming actually is - message passing, encapsulated state, and clear protocols for crossing boundaries - and what a bounded context is at every scale, from a single object to a whole application. Load when designing objects, modules, or larger contexts, deciding what is public, or reasoning about where logic belongs.
category: architecture
status: active
version: 1.1
applies_to:
  - Ruby
priority: REQUIRED
triggers:
  - bounded context
  - public interface
  - encapsulation
  - where does this logic belong
  - extract a class
  - god object
  - message passing
anti_triggers:
  - mechanical refactors with no design decision
user_invocable: true
last_reviewed_at: 2026-06-06
---


# Object-Oriented Boundaries

Object-oriented programming is **message passing, encapsulated state, and clear
protocols for crossing boundaries**. Everything else is technique. Most training-data
Ruby gets this wrong — bloated classes with huge, poorly defined public interfaces,
callers groping through other objects' state — so this skill states the discipline
explicitly. Internalize it; apply it at every scale.


## The Definition (scale-free)

A **bounded context** is any collection of code with a clear protocol for crossing
its boundary, whose state and implementation details are unreachable except through
its public interface.

That definition does not mention size. The discipline is identical at every scale:

```text
a well-formed object          # a class with a small, clear interface
a namespaced module           # one file defines the interface;
                              #   the rest are internal collaborators
a gem                         # the module definition file carries the
                              #   entry-point methods
the whole application         # a bounded context to its external users
```

Contexts compose of contexts. A gem's public module fronts internal classes; each of
those classes is itself a bounded context fronting its own privates. Boundaries are
fractal.


## Invisibility — the test of a real boundary

A caller sends `Accounts.new_account(...)`. It cannot tell — and has **no business
knowing** — whether `Accounts` is:

- one object,
- a module orchestrating dozens of internal classes, or
- an HTTP request to a whole other application.

If a caller can tell the difference, state or implementation is leaking through the
boundary. This invisibility is what makes change safe: anything behind the interface
can be rewritten without any caller noticing.


## One Thing, at Every Level

The single-responsibility principle is usually taught for classes; it holds at every
level of abstraction. A bounded context does **one thing at its level**:

- a method's one thing is small;
- a class's one thing is a cohesive responsibility;
- a large context's one thing can be an entire business concept — *everything to do
  with user registration* is one thing, even when it is many files and behaviours.

If a context can only be described with "and", it is two contexts.


## Decomposition Is an Implementation Detail

When a context grows heavy, decompose it inside its boundary. Registration may become
an interface manager, an authorization manager, and a role granter internally — and
to every outside caller it remains exactly `registration`, unchanged.

The rule: **splitting a context into sub-contexts never changes its public
interface.** If a split forces callers to change, it was not a decomposition — it was
a boundary break.


## Messages, Not Structures

- Tell, don't ask: send a message stating what you want; do not interrogate state and
  decide on the object's behalf.
- Separate commands from queries: a command changes state and reports its outcome (its
  return value is not the contract); a query answers a question and changes nothing.
  Nothing in between — a query with side effects is a command in disguise.
- Depend on protocols, not constants: a collaborator is anything that answers the
  messages you send (duck typing). This is what makes boundaries swappable — in tests
  and in production.
- Keep public interfaces small and intentional. Every public method is a promise you
  must keep forever; privates are free.


## Testing at the Edges

Test a context **only through its boundary**. Sandi Metz's "Magic Tricks of Testing"
is the canonical statement of this discipline and its grid governs every assertion:
incoming query → assert the return value; incoming command → assert the resulting
state; outgoing command → assert the message was sent; outgoing query → stub it;
internals and privates → never directly.

Internal collaborators earn their own specs only by being bounded contexts
themselves — tested through *their* boundaries. See [[ruby-testing]] and
[[always-execute-rspec]] (which carries the assertion-target grid).


## Smells

- A caller reaching past an interface (`Accounts::Internal::Verifier` named outside
  `Accounts`).
- Internals leaking through return values (handing back a mutable internal structure
  instead of an answer).
- A public interface so large nobody can say what the context is for.
- "And" in the one-line description of any context, at any scale.
- Heavy dependence on abstractions you do not own, woven through code you do.


## Why This Matters

This is the discipline that separates working code from good engineering — and it is
the key to human/AI development at speed. A context with a hard boundary and a small
interface is one a developer (human or agent) can hold in full, reason about
accurately, and change without fear. Everything that makes your application yours —
the business logic, the wiring, what makes your business your business — belongs in
bounded contexts you understand, you control, and you can work quickly in.
