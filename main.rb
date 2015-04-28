require './graph'
require './node'
class Main
#screen properties
  @c_width = 1000
  @c_height = 600
  @border = 20

  def initialize
    g = Graph.new

  end

  def result
    node1 = Node.new(1)
    node2 = Node.new(2)
    node3 = Node.new(3)
    g = Graph.new
    g.addNode(node1.id)
    g.addNode(node2.id)
    g.addNode(node3.id)
    g.addEdge(node1.id, node2.id)
    g.addEdge(node2.id, node3.id)
    g.edges
    g.isEdge(node1.id, node2.id)
    g.calculateConnectedComponents
    g.calculateStep
    g.calculateConnectedComponents
    g.setRandomNodePosition
    while not g.calculation_finished
      g.calculateStep
      g.timestep += 1
    end
g.nodes.each do |node|
 p [node.coordinate_x, node.coordinate_y].join(',')
end
  end

  end