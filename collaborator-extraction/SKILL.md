---
name: collaborator-extraction
title: Ruby Collaborator Extraction
description: "Extract Ruby collaborators inside an existing object or boundary without leaking internals or changing the caller-facing public protocol. Use when a class is doing multiple lower-level responsibilities, has too many private helpers, or starts needing 'and' to describe what it does."
category: object-design
status: active
version: 1.0
applies_to:
  - Ruby
priority: REQUIRED
triggers:
  - extract collaborator
  - extract class
  - too many private methods
  - god object
  - object does too much
  - split a ruby class
anti_triggers:
  - architecture-scale boundary decision
  - component extraction
  - engine extraction
user_invocable: true
last_reviewed_at: "2026-06-28"
---

# Ruby Collaborator Extraction

Use this when a Ruby object should keep the same public role but its internals have
grown too crowded.

Read [[object-oriented-boundaries]] first. Read [[bounded-contexts]] when the question
is where behavior belongs at a larger scale.


## Extraction Rule

Extract inside the boundary when:

- the parent object's public interface should stay stable
- the new object names a real lower-level responsibility
- outside callers should not coordinate the new object
- the extracted object can have a small meaningful public protocol

Split the boundary instead when callers need a different public concept with its own
reason to change.


## Process

1. Name the parent object's public promise.
2. Identify the internal responsibility that makes the object say "and".
3. Create a collaborator for that responsibility only.
4. Inject or build the collaborator where the parent owns it.
5. Keep the parent as the public entry point unless the boundary is intentionally
   changing.
6. Test the parent through its public interface; test the collaborator only if its own
   public behavior is meaningful.


## Avoid

- Extracting a class just because a file is long.
- Making callers instantiate or coordinate former private helpers.
- Creating tiny noun classes with one vague `call` method and no clear role.
- Adding public readers so the collaborator can dig through parent state.
- Moving private methods into a module to hide poor object design.


## Good Shape

```ruby
class Invoice
  def mark_paid(payment_reference:)
    payment_marker.mark(payment_reference:)
  end

  private

  def payment_marker
    @payment_marker ||= PaymentMarker.new(self)
  end
end
```

The caller still sends one public message to `Invoice`.


## Completion Criteria

Done when the parent object's public protocol is stable, the collaborator has one
clear lower-level responsibility, and callers do not instantiate or coordinate the
collaborator.
