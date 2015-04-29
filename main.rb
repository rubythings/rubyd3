require './graph'
require './node'
class Main
  attr_accessor :c_width, :c_height
#screen properties



  def initialize
    @c_width = 1000
    @c_height = 1000
  end

  def result
    node1 = Node.new(1, 'draft', 'draft')
    node2 = Node.new(2, 'pending', 'setup')
    node3 = Node.new(3, 'signoff', 'retrict')
    node4 = Node.new(4, 'active', 'activate')
    node5 = Node.new(6, 'completed', 'finish')
    node6 = Node.new(5, 'cancelled', 'kill')


    p node1
    g = Graph.new
    g.addNode(node1)
    g.addNode(node2)
    g.addNode(node3)
    g.addNode(node4)
    g.addNode(node5)
    g.addNode(node6)
    g.addEdge(node1.id, node2.id)
    g.addEdge(node2.id, node3.id)
    g.addEdge(node2.id, node4.id)
    g.addEdge(node3.id, node5.id)
    g.addEdge(node3.id, node6.id)
    g.calculateConnectedComponents

    g.setRandomNodePosition

    g.calculateStep
    while not g.calculation_finished == 1
      g.calculateStep
      g.timestep += 1
    end
    g.nodes.each do |node|
      node.coordinate_x = (((node.coordinate_x*g.scaling_factor + (g.center_distance/2)) / g.center_distance * c_width).to_i)/10
      node.coordinate_y = (((node.coordinate_y*g.scaling_factor + (g.center_distance/2)) / g.center_distance * c_height).to_i)/10
    end
    css = []
    js = []
    g.nodes.each do |node|

      css << "##{node.name} {left: #{node.coordinate_x}em; top: #{node.coordinate_y}em;}"

    end


    g.edges.each do |hash|
      js <<
          "instance.connect({ source: '#{g.getNode(hash.keys.first).name}', target: '#{g.getNode(hash.values.first).name}', overlays:[[ 'Label', { label: '#{g.getNode(hash.values.first).transition}', location: 0.25, id:'myLabel' } ]]});"
    end
    p css.join(' ')
    p js.join(' ')
  end
end
