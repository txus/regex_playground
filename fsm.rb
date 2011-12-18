require 'rubygems'
require 'minitest/spec'
require 'minitest/autorun'
require 'pp'
require 'graphviz'

class State
  @last_id = 0

  def self.generate_id
    @last_id += 1
  end

  def self.reset_ids
    @last_id = 0
  end

  attr_reader :id, :transitions

  def initialize
    @id = State.generate_id
    @transitions = []
  end

  def <<(transition)
    @transitions << transition
  end

  def final?
    @transitions.empty?
  end

  def to_tree(depth=0, offset=2)
    out = []
    indent = ' ' * (4 * depth + offset)
    if depth == 0
      out << "\n"
    end
    if final?
      out << "{#{@id}}"
    else
      out << "(#{@id})"
      @transitions.each do |transition|
        if transition.state == self
          # Recursive transition
          out << "\n"
          out << "#{indent}\\-#{transition.value}-> SELF"
        else
          out << "\n"
          out << "#{indent}\\-#{transition.value}-> "
          out << "#{transition.state.to_tree(depth+1, offset + 3)}"
        end
      end
    end
    out.join
  end

  def to_dot(g=nil, node=nil)
    root = !!g

    g ||= GraphViz.new("Root", :type => "digraph")

    node ||= g.add_nodes("#{@id}")

    return node if final?

    @transitions.each do |transition|
      if transition.state == self
        g.add_edges(node, node, :label => transition.value)
      else
        child_node = g.add_nodes("#{transition.state.id}")
        g.add_edges(node, child_node, :label => transition.value)

        transition.state.to_dot(g, child_node)
      end
    end

    if root
      g.output( :png => "hey.png" )
      system("open hey.png")
    else
      return node
    end
  end

  def to_node(g)
    p "g.add_nodes(#{@id})"
    g.add_nodes("#{@id}")
  end
end

class Transition < Struct.new(:value, :state); end

class Compiler
  def compile(string, parent=nil, value=nil)
    root = State.new
    peek = string[0]
    return root unless peek
    puts "Scanning '#{peek.chr}'"
    case peek.chr
      when %r{[^\+\*\[\]\(\)]} # Alphanumeric or numbers
        child = compile(string[1..-1], root, peek.chr)
        root << Transition.new(peek.chr, child)
      when /\+/
        raise "+ can only be applied after another symbol" unless parent && value
        p "+: parent is #{parent.id}"
        parent << Transition.new(value, parent)

        if string[1]
          child = compile(string[1..-1], root, string[1].chr)
          root << Transition.new(peek.chr, child)
        end
    end
    root
  end
end

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
    root.to_tree.must_equal "\n(1)\n  \\-a-> {2}"
  end

  it 'compiles +' do
    root = subject.compile("abc+")
    root.to_tree.must_equal "\n(1)\n  \\-a-> (2)\n         \\-b-> (3)\n                \\-c-> SELF\n                \\-c-> {4}"
  end

  it 'compiles interleaved +' do
    root = subject.compile("ab+c")
    puts root.to_tree
  end

  it 'compiles big trees without complaining' do
    root = subject.compile("abc+")
    root.to_dot
  end if nil

  it 'rocks' do
    g = GraphViz.new(:G)
    n = g.add_nodes("Hey")
    n2 = g.add_nodes("Ho")
    n3 = g.add_nodes("Baz")
    g.add_edges(n2, n3)
    g.add_edges(n, n2)
    g.add_edges(n2, n)
    g.output( :png => "hey.png" )
    system("open hey.png")
  end if nil
end