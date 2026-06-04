# common_agent_skills/derisk_ruby/testing-base-classes/references/annotated-example.md


# Annotated Example — Base Class / Mixin Module Spec

Two annotated specs: a mixin DSL module (`Auditable`) and an abstract base class
(`BaseCommand`).

The module under test:

```ruby
module Auditable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def audit(*fields)
      audited_fields.concat(fields)
    end

    def audited_fields
      @audited_fields ||= []
    end
  end

  def audited_attributes
    self.class.audited_fields.to_h { |field| [field, public_send(field)] }
  end
end
```


## DSL module — assert it endows includers

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Auditable do
  describe 'Class Methods' do

    # An anonymous class is the cheapest, self-contained way to include and exercise a module.
    subject(:test_class) { Class.new.include(described_class) }

    it { is_expected.to respond_to(:audit) }
    it { is_expected.to respond_to(:audited_fields) }

    describe '.audit' do
      subject(:test_class) do
        Class.new do
          include Auditable
          audit :name, :email

          attr_accessor :name, :email
        end
      end

      it 'tracks the audited fields' do
        expect(test_class.audited_fields).to eq([:name, :email])
      end
    end
  end

  describe 'Instance Methods' do
    describe '#audited_attributes' do
      subject(:audited_object) { test_class.new }

      let(:test_class) do
        Class.new do
          include Auditable
          audit :name

          attr_accessor :name
        end
      end

      before do
        audited_object.name = 'Ada'
      end

      it 'returns the audited fields with their values' do
        expect(audited_object.audited_attributes).to eq({ name: 'Ada' })
      end
    end
  end
end
```


## Base class — constructor contract and abstract methods

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BaseCommand do

  # Composition contract: each one-liner pins one promised module.
  it { expect(described_class.included_modules).to include(Auditable) }


  describe '#initialize' do
    # Initialization IS the contract here, so the constructor is tested directly.
    # Allocate in subject, then #initialize itself is the action — inside execute.
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

    # Raising case: block expectation inside it (see always-execute-rspec Exceptions),
    # still through allocate + send so no fixture class is constructed twice.
    context 'with an unknown argument' do
      it 'raises ArgumentError' do
        expect do
          command.send(:initialize, bogus: true)
        end.to raise_error(ArgumentError)
      end
    end
  end


  # The base provides reporting but no public entry point that calls it, so a small
  # concrete subclass exercises the behaviour through a real #perform.
  describe 'reporting' do
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
  end


  describe 'subclass contract' do
    it 'requires subclasses to implement #perform' do
      expect { Class.new(described_class).new.perform }.to raise_error(NotImplementedError)
    end
  end
end
```


## Why these choices

- **Anonymous classes, not repo fixtures.** A base/module has no behaviour of its own; the
  spec must construct an includer. Inline `Class.new` keeps that throwaway local.
- **`included_modules` one-liners** document the composition contract precisely.
- **`allocate` + `execute { send(:initialize) }`** keeps the constructor — the action under
  test — inside `execute`, with layered `init_args` lets so each context overrides one
  input. Only base classes and DSL modules earn constructor specs; elsewhere `#initialize`
  is a private implementation detail tested through public behaviour.
- **Concrete subclass + `execute`** for behaviour the base provides but only invokes
  internally — assert through the public entry point, not by poking privates, when a public
  path exists.
- **Assert the real module name.** If the file is `auditable.rb` defining `Auditable`,
  assert `Auditable` — not a stale rename.
