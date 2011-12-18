require 'test_helper'

describe State do
  subject { State.new }

  before do
    State.reset_ids
  end

  it 'has many transitions' do
    subject << "foo"
    subject << "bar"
    subject.transitions.must_equal ["foo", "bar"]
  end

  it 'has an autoincremental id' do
    State.new.id.must_equal 1
    State.new.id.must_equal 2
    State.new.id.must_equal 3
  end

  describe '#final?' do
    it 'returns true if the State has no transitions' do
      subject.final?.must_equal true
    end
    it 'returns false otherwise' do
      subject << "foo"
      subject.final?.must_equal false
    end
  end

  describe "#to_tree" do
    it 'converts the state to a tree' do
      state = State.new
      state << Transition.new("b", State.new)
      state << Transition.new("c", State.new)
      subject << Transition.new("a", state)
      subject.to_tree.must_equal "\n(4)\n  \\-a-> (1)\n         \\-b-> {2}\n         \\-c-> {3}"
    end
  end
end

describe Compiler do
  subject { Compiler.new }

  before do
    State.reset_ids
  end

  it 'compiles terminals' do
    root = subject.compile("a")
    puts root.to_tree
    root.to_tree.must_equal "\n(1)\n  \\-a-> {2}"
  end

  it 'compiles +' do
    root = subject.compile("abc+")
    puts root.to_tree
    root.to_tree.must_equal "\n(1)\n  \\-a-> (2)\n         \\-b-> (3)\n                \\-c-> (4)\n                       \\-c-> SELF"
  end

  it 'compiles interleaved +' do
    root = subject.compile("ab+c")
    puts root.to_tree
    root.to_tree.must_equal "\n(1)\n  \\-a-> (2)\n         \\-b-> (3)\n                \\-b-> SELF\n                \\-c-> {4}"
  end

  it 'compiles big trees without complaining' do
    root = subject.compile("abb+8fhffd+b+")
    puts root.to_tree
    root.to_dot
  end
end
