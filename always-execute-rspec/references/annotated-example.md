# common_agent_skills/derisk_ruby/always-execute-rspec/references/annotated-example.md


# Annotated Examples

Two complete specs showing the always_execute pattern and how the assertion target
follows from the kind of action under test.


## Service Object Spec

The object under test activates a territory: it changes state (incoming command),
returns the territory (incoming query), and notifies a listener (outgoing command).
Each boundary gets its own assertion; nothing else is tested.

```ruby
RSpec.describe Territories::Activate do
  describe '#call' do

    # subject + collaborators: all setup lives in subject/let/before.
    subject(:activator) do
      described_class.new(repository: repository, listener: listener)
    end

    let(:listener)   { instance_spy('Listener') }                 # spy: we assert messages later
    let(:repository) { instance_double(Territories::Repository) }
    let(:territory)  { instance_spy(Territory, activate!: true) }


    before do
      # Outgoing QUERY to the repository: stub it, never assert it.
      allow(repository).to receive(:find).with(territory.id).and_return(territory)
    end


    # The action under test. Runs once at the start of every example below,
    # after the before hooks. Its return value is available as `execute_result`.
    execute do
      activator.call(territory.id)
    end


    # Incoming QUERY: the return value is the contract — assert execute_result.
    it 'returns the territory' do
      expect(execute_result).to eq(territory)
    end

    # Incoming COMMAND: assert the resulting state change through the public interface.
    it 'activates the territory' do
      expect(territory).to have_received(:activate!)
    end

    # Outgoing COMMAND: assert the message was sent with the right arguments.
    it 'notifies the listener' do
      expect(listener).to have_received(:on_activated).with(territory: territory)
    end

    # NOT tested: private methods, messages to self, the repository query
    # (stubbed above), or the internals of Territory#activate!.
  end
end
```

Naming the result when it reads better:

```ruby
execute(:activated_territory) do
  activator.call(territory.id)
end

it 'returns the territory' do
  expect(activated_territory).to eq(territory)
end
```


## Raising Actions

When the contract is that the action raises, the action cannot go in `execute` — a
raising `execute` block fails the example before its assertions run. Use the
block-expectation form inside `it`, one raise assertion per `it`:

```ruby
context 'with missing required inputs' do
  it 'raises MissingRequiredInputs' do
    expect do
      test_class.new({})
    end.to raise_error(Layers::DSL::MissingRequiredInputs)
  end
end
```


## Request Spec

HTTP verbs are actions under test and go in `execute`. Assertions target `response`
and `parsed_response` — never `execute_result`.

```ruby
RSpec.describe 'Territories', type: :request do
  describe 'GET /api/territories' do
    let(:registry) { instance_double(Territories::Registry) }

    let(:territories) do
      [instance_double(Territory, id: 'T-001', name: 'North', active?: true)]
    end

    # If the suite does not already provide parsed_response, define it as a let.
    # It is lazy, so it evaluates after execute has run.
    let(:parsed_response) { JSON.parse(response.body) }


    before do
      allow(Territories::Registry).to receive(:new).and_return(registry)
      allow(registry).to receive(:all).and_return(territories)
    end


    # The HTTP verb is the action under test.
    execute do
      get '/api/territories'
    end


    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the territories collection' do
      expect(parsed_response.fetch('data')).to be_an(Array)
    end
  end
end
```


## Anti-Patterns

```ruby
# BAD: action inside it, repeated per example
it 'returns the territory' do
  result = activator.call(territory.id)
  expect(result).to eq(territory)
end

# BAD: instance variable instead of the let
it 'returns the territory' do
  expect(@execute_result).to eq(territory)
end

# BAD: stubbing inside it
it 'returns the territory' do
  allow(repository).to receive(:find).and_return(territory)
  expect(execute_result).to eq(territory)
end

# BAD: multiple expectations in one it
it 'activates and notifies' do
  expect(territory).to have_received(:activate!)
  expect(listener).to have_received(:on_activated)
end

# BAD: asserting an outgoing query
it 'asks the repository' do
  expect(repository).to have_received(:find)   # stub it instead; don't assert it
end
```
