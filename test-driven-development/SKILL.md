---
name: test-driven-development
title: Test Driven Development
description: Apply TDD when implementing software changes - write a failing test first, make it pass, refactor - and wrap tests around any behaviour that emerged untested despite the loop, so nothing ships as regression bait.
category: testing
status: active
version: 2.1
priority: REQUIRED
user_invocable: true
last_reviewed_at: 2026-06-03
---


# common_agent_skills/derisk_ruby/test-driven-development/SKILL.md


# Test Driven Development


## Rules

1. Write a failing test first.
2. Do not modify production code before a failing test exists.
3. Implement the smallest change that makes the test pass.
4. Refactor while keeping tests green.
5. Repeat until the story is complete.


## TDD Still Leaves Gaps — Close Them

Even disciplined TDD produces behaviour no test pinned: a branch that emerged during
refactoring, a default that appeared while making a test pass, an extracted method or
object with a wider contract than the test that forced it into existence.

Before completing the task, audit what was built for behaviour no test exercises, and
**wrap tests around it** — untested behaviour is regression bait, however it arose.

- Write the late test as if it had come first: state the behaviour, not the
  implementation's shape (the testing skills' rules apply unchanged).
- Touching existing code that has no tests? Wrap characterization tests around its
  current behaviour before changing it.
- After-the-fact coverage closes gaps the loop left; it is never a license to skip
  rule 1 for behaviour you could have stated up front.


## Completion Checklist

Before marking work complete:

* Tests exist for **all** behaviour the change introduced — anticipated or discovered.
* Tests pass.
* Refactoring is complete.
* No unnecessary production code was added.

