---
name: characterization-testing
title: Characterization Testing
description: Add characterization tests around current observable Ruby behavior before changing legacy, risky, under-tested, surprising, or poorly understood code. Use before refactoring or modifying existing Ruby code when the first task is to preserve what callers currently experience.
category: testing
status: active
version: 0.1
applies_to:
  - Ruby
  - RSpec
priority: REQUIRED
triggers:
  - legacy code
  - untested existing code
  - refactor existing behavior
  - preserve current behavior
  - characterize behavior
  - risky change
anti_triggers:
  - brand new behavior with a clear desired contract
user_invocable: true
last_reviewed_at: 2026-06-26
---


# Characterization Testing

Use this skill before changing existing Ruby behavior that is not already protected by useful tests.


## Required Reading

```text
[[ruby-testing]]
[[always-execute-rspec]]
```


## Rules

1. Identify the public entry point you need to change.
2. Write tests for current observable behavior before editing production code.
3. Test through public interfaces; do not test private methods directly.
4. Stub only architectural boundaries: external services, gateways, repositories, queues, file systems, clocks, randomness.
5. Name examples as current behavior until the story intentionally changes that behavior.
6. Keep the tests narrow enough to protect the change you are about to make.


## What To Capture

Capture behavior callers may depend on:

- return values
- public state changes
- raised errors
- outgoing commands at boundaries
- edge cases discovered while reading or exercising the code

Do not preserve private implementation details unless they are externally observable.


## Workflow

1. Read from the public entry point to the behavior you plan to change.
2. Find existing tests that already protect that behavior.
3. Add missing characterization tests for behavior the change might break.
4. Run the tests and confirm they pass against the current code.
5. Make the intended change.
6. Update or replace characterization tests only when the story intentionally changes the public contract.


## Stop And Ask

Ask before locking in behavior that appears wrong, harmful, accidental, or inconsistent with the requested change.
The first characterization pass preserves behavior; it does not decide which bugs should become permanent contracts.

