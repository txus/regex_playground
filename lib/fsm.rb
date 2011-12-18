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
      g.output( :png => "fsm.png" )
      system("open fsm.png")
    else
      return node
    end
  end
end

class Transition < Struct.new(:value, :state); end

class Compiler
  def compile(string, parent=nil, value=nil, root=nil)
    root ||= State.new
    peek = string[0]
    return root unless peek
    case peek.chr
      when %r{[^\+\*\[\]\(\)]} # Alphanumeric or numbers
        child = State.new # 3
        root << Transition.new(peek.chr, child)

        compile(string[1..-1], root, peek.chr, child)
      when /\+/
        raise "+ can only be applied after another symbol" unless parent && value
        root << Transition.new(value, root)

        if string[1]
          compile(string[1..-1], root, nil, root)
        end
    end
    root
  end
end
