class Graph
  attr_accessor :calculation_finished, :last_added_id, :nodes, :edges, :connected_components_count, :scaling_factor, :center_distance, :timestep

  def initialize
    @c_height = 1000
    @center_distance = 10.0 # the distance from the middle of the screen to each border
    @scaling_factor = 1.0 # the zoom-factor (the smaller, the more surface is shown)
    @zooming = 0 # is the application zooming right now?
    @zoom_in_border = 1.0 # limit between graph and screen-border for zooming in
    @zooming_out = 0
    @circle_diameter = 2 # the diameter of the node-circles
    @timestep = 0
    @thermal_energie = 0.0 # set this to 0.3 or 0.0 to (de)activate thermal_energie
    @all_energies = [] # list of all energies sorted by time
    @highest_energy = 0 # the highest energie occuring
    @energie_change_limit = 0.0000001 # if energie doesn't change more than this, process is stoped
    @velocity_maximum = 0.05
    @friction = 0.0005 # is subtracted from the velocity at each timestep for stop oscillations
    @show_energies_in_background = 1
    @status_message = ''
    @grabed_node = ''
    @grabed_component = ''
    @dont_finish_calculating = 1
    @show_energie_in_background = 1
    @show_textinformation_in_background = 1
    # build an empty graph
    @nodes = [] # list of Node-objects
    @edges = [] # list of tupels (node1-id, node2-id) where node1-id is always smaller than node2-id
    @last_added_id = -1
    @connected_components_count = 0
    @overall_energie = 0
    @overall_energie_difference = 1000
    @calculation_finished = 0
    @highest_energy = 0
    @thermal_energy = 0
    @random = Random.new
  end

  def addNode(node)
    # adds a node to the graph
    return if node.id == @last_added_id # speed up adding of same ids consecutively
    @nodes.each do |x|
      return if x.getId() == node.id
    end
    @nodes << Node.new(node.id, node.name, node.transition)
    @last_added_id = node.id
  end

  def addEdge(node_id_1, node_id_2)
    # adds an edge between two nodes
    if node_id_1 != node_id_2 and node_id_1 >= 0 and node_id_2 >= 0 and not isEdge(node_id_1, node_id_2)
      if node_id_1 < node_id_2
        @edges << {node_id_1 => node_id_2}
      else
        @edges << {node_id_2 => node_id_1}
      end
      # search for the two node-objects with fitting ids
      node1 = getNode(node_id_1)
      node2 = getNode(node_id_2)
      node1.setNeighbour(node_id_2)
      node2.setNeighbour(node_id_1)
    end
  end

  def nodesList
    # returns the list of ids of nodes
    list_of_ids = []
    @nodes.each do |node|
      list_of_ids.append(node.id)
      return list_of_ids
    end
  end

  def edgesList
    # returns the list of edges ([(id, id), (id, id), ...]
    return @edges
  end

  def degreeList
    # returns a dictionary with the degree distribution of the graph
    degrees = {}
    @nodes.each do |x|
      if degrees.has_key(x.degree)
        degrees[x.degree] += 1
      else
        degrees[x.degree] = 1
      end
      return degrees
    end
  end

  def countNodes
    # prints the number of nodes
    return @nodes.size
  end

  def countEdges
    # prints the number of nodes
    return @edges.size
  end


  def isEdge(node_id_1, node_id_2)
    if node_id_1 > node_id_2

      # switch the two node-ids (edges are always saved with smaller id first)
      tmp = node_id_1
      node_id_1 = node_id_2
      node_id_2 = tmp
    end
    # checks if there is an edge between two nodes
    @edges.each do |x|
      if x == {node_id_1 => node_id_2}
        return true
      end
    end
    false
  end

  def getNode(node_id)
    # returns the node for a given id
    @nodes.each do |x|
      return x if x.getId() == node_id
    end
  end

  def getNodes
    @nodes
  end

  def setRandomNodePosition
    # sets random positions for all nodes
    @nodes.each do |node|
      node.coordinate_x = @random.rand(1.0) * @center_distance - (@center_distance/2)
      node.coordinate_y = @random.rand(1.0) * @center_distance - (@center_distance/2)
    end
  end

  def calculateStep
    new_overall_energie = 0
    # calculate the repulsive force for each node
    @nodes.each do |node|
      node.force_coulomb = [0, 0]
      @nodes.each do |node2|
        if (node.id != node2.id) and (node.cc_number == node2.cc_number)
          distance_x = node.coordinate_x - node2.coordinate_x
          distance_y = node.coordinate_y - node2.coordinate_y
          p distance_x
          p distance_y
          radius = Math.sqrt(distance_x*distance_x + distance_y*distance_y)
          if radius != 0
            vector = [distance_x/radius, distance_y/radius]
            node.force_coulomb[0] += 0.01 * vector[0] / radius
            node.force_coulomb[1] += 0.01 * vector[1] / radius
            # add this force to the overall energie
            new_overall_energie += 0.01 / radius
          else
            # if the nodes lie on each other, randomly replace them a bit
            node.force_coulomb[0] += @random.rand(1.0) - 0.5
            node.force_coulomb[1] += @random.rand(1.0) - 0.5
          end
        end
      end
    end

    # calculate the attractive force for each node
    @nodes.each do |node|
      node.force_harmonic = [0, 0]
      node.neighbour_ids.each do |neighbor_id|
        node2 = getNode(neighbor_id)
        distance_x = node.coordinate_x - node2.coordinate_x
        distance_y = node.coordinate_y - node2.coordinate_y
        radius = Math.sqrt(distance_x*distance_x + distance_y*distance_y)
        p radius
        if radius != 0
          vector = [distance_x/radius* -1, distance_y/radius * -1]
          force_harmonic_x = vector[0] *radius*radius/100
          force_harmonic_y = vector[1] *radius*radius/100
        else
          # if the nodes lie on each other, randomly replace them a bit
          force_harmonic_x = @random.rand(1.0) - 0.5
          force_harmonic_y = @random.rand(1.0) - 0.5
        end
        node.force_harmonic[0] += force_harmonic_x
        node.force_harmonic[1] += force_harmonic_y
        # add this force to the overall energie
        new_overall_energie += radius*radius/100
      end
    end
    # calculate the difference between the old and new overall energie
    @overall_energie_difference = @overall_energie - new_overall_energie
    @overall_energie = new_overall_energie
    @all_energies << @overall_energie
    if @overall_energie > @highest_energy
      @highest_energy = @overall_energie
    end

      p @overall_energie_difference
      p @energie_change_limit.to_f
      if (@overall_energie_difference < @energie_change_limit and @overall_energie_difference > -1*@energie_change_limit)

        @calculation_finished = 1


    end

    # set the new position influenced by the force
    if @timestep == 50 and @thermal_energie > 0
      @thermal_energie = 0.2
    end
    if @timestep == 110 and @thermal_energie > 0
      @thermal_energie = 0.1
    end
    if @timestep == 150 and @thermal_energie > 0
      @thermal_energie = 0.0
    end
    @nodes.each do |node|
      (force_coulomb_x, force_coulomb_y) = node.force_coulomb
      (force_harmonic_x, force_harmonic_y) = node.force_harmonic
      # node.coordinate_x += force_coulomb_x + force_harmonic_x
      # node.coordinate_y += force_coulomb_y + force_harmonic_y

      node.velocity[0] += (force_coulomb_x + force_harmonic_x)*0.1
      node.velocity[1] += (force_coulomb_y + force_harmonic_y)*0.1
      # ensure maximum velocity
      if (node.velocity[0] > @velocity_maximum)
        node.velocity[0] = @velocity_maximum
      end
      if (node.velocity[1] > @velocity_maximum)
        node.velocity[1] = @velocity_maximum
      end
      if (node.velocity[0] < -1*@velocity_maximum)
        node.velocity[0] = -1*@velocity_maximum
      end
      if (node.velocity[1] < -1*@velocity_maximum)
        node.velocity[1] = -1*@velocity_maximum
      end
      # get friction into play
      if node.velocity[0] > @friction
        node.velocity[0] -= @friction
      end
      if node.velocity[0] < -1*@friction
        node.velocity[0] += @friction
      end
      if node.velocity[1] > @friction
        node.velocity[1] -= @friction
      end
      if node.velocity[1] < -1*@friction
        node.velocity[1] += @friction
      end

      # FINALLY SET THE NEW POSITION
      if node.id != @grabed_node or node.cc_number == @grabed_component
        if node.movable == 1
          node.coordinate_x += node.velocity[0]
          node.coordinate_y += node.velocity[1]
        end
      end
      if @thermal_energie > 0
        if node.movable == 1
          node.coordinate_x += @random.rand(1.0)*@thermal_energie*2-@thermal_energie
          node.coordinate_y += @random.rand(1.0)*@thermal_energie*2-@thermal_energie
        end
      end

      # calculate centers for all connected components
      min_max = []
      center = []
      0.upto(@connected_components_count).each do
        min_max << [1000, 1000, -1000, -1000]
      end

      0.upto(@connected_components_count).each do |i|
        @nodes.each do |node|
          if node.cc_number == i+1
            if node.coordinate_x < min_max[i][0]
              min_max[i][0] = node.coordinate_x
            end
            if node.coordinate_y < min_max[i][1]
              min_max[i][1] = node.coordinate_y
            end
            if node.coordinate_x > min_max[i][2]
              min_max[i][2] = node.coordinate_x
            end
            if node.coordinate_y > min_max[i][3]
              min_max[i][3] = node.coordinate_y
            end
            center << ([min_max[i][0] + (min_max[i][2] - min_max[i][0])/2, min_max[i][1] + (min_max[i][3] - min_max[i][1])/2])
          end
        end
      end

      # if two components lie on each other, increase the distance between those
      0.upto(@connected_components_count).each do |a|
        0.upto(@connected_components_count).each do |b|
          # if a != b and center[a][0] > min_max[b][0] and center[a][0] < min_max[b][2] and center[a][1] > min_max[b][1] and center[a][1] < min_max[b][3]:
          if a != b
            distance = 1
            if ((min_max[a][0]+distance > min_max[b][0] and min_max[a][0]-distance < min_max[b][2]) or (min_max[a][2]+distance > min_max[b][0] and min_max[a][2]-distance < min_max[b][2])) and ((min_max[a][1]+distance > min_max[b][1] and min_max[a][1]-distance < min_max[b][3]) or (min_max[a][3]+distance > min_max[b][1] and min_max[a][3]-distance < min_max[b][3]))
              # calculate replacement with help of the distance vector
              # of the centers
              distance_x = center[a][0] - center[b][0]
              distance_y = center[a][1] - center[b][1]
              radius = Math.sqrt(distance_x*distance_x + distance_y*distance_y)
              replacement = [distance_x/radius* -1, distance_y/radius * -1]
              replacement[0] *= @random.rand(1.0) * -0.1
              replacement[1] *= @random.rand(1.0) * -0.1
              @nodes.each do |node|
                if node.cc_number == a+1
                  if node.id != @grabed_node
                    if node.movable == 1
                      node.coordinate_x += replacement[0]
                    end
                    node.coordinate_y += replacement[1]
                  end
                end
              end
            end
          end
        end
      end

      # calculate the center of the graph and position all nodes new, so that
      # the center becomes (0,0)
      x_max = -500
      x_min = 500
      y_max = -500
      y_min = 500
      @nodes.each do |node|
        if node.coordinate_x < x_min
          x_min = node.coordinate_x
        end
        if node.coordinate_x > x_max
          x_max = node.coordinate_x
        end
        if node.coordinate_y < y_min
          y_min = node.coordinate_y
        end
        if node.coordinate_y > y_max
          y_max = node.coordinate_y
        end
        center_x = x_min + (x_max - x_min)/2
        center_y = y_min + (y_max - y_min)/2
        @nodes.each do |node|
          if node.id != @grabed_node
            node.coordinate_x -= center_x
          node.coordinate_y -= center_y
            end

        end
        scale = 0
      end

      # prevent nodes from leaving the screen - ZOOM OUT
      if (x_min < (@center_distance/@scaling_factor/-2)) or (y_min < (@center_distance/@scaling_factor/-2)) or (x_max > (@center_distance/@scaling_factor/2))
        scale = 1
      end
      # longer if-statement because node-caption is included
      if (y_max > (@center_distance/@scaling_factor/2)-((@circle_diameter+20)*@scaling_factor*@center_distance/@c_height))
        scale = 1
      end
      # zoom back in if necessary - ZOOM IN
      if (x_min - @zoom_in_border > (@center_distance/@scaling_factor/-2)) and (y_min - @zoom_in_border > (@center_distance/@scaling_factor/-2)) and (x_max + @zoom_in_border < (@center_distance/@scaling_factor/2)) and (y_max + @zoom_in_border < (@center_distance/@scaling_factor/2)-((@circle_diameter+10)*@scaling_factor*@center_distance/@c_height))
        scale = -1
      end
      if scale == 1
        @scaling_factor = @scaling_factor * 0.99
        @zooming = 50
        @zooming_out = 1
      else
        # zoom in
        if scale == -1
          @scaling_factor = @scaling_factor * 1.01
          @zooming = 50
          @zooming_out = 0
        else
          # don't zoom (count down the fading for the zooming message)
          if @zooming > 0
            @zooming -= 1
          end
        end
      end
    end
  end

  def calculateConnectedComponents
    # calculate the connected components of the graph
    all_node_ids = []
    @nodes.each do |node|
      all_node_ids << node.id
    end
    visited_node_ids = []
    node_ids_to_process = []
    connected_component_number = 0
    while all_node_ids.size > 0
      # take an anchor node
      node_ids_to_process << all_node_ids.pop
      # process all nodes that are reachable from the anchor-node
      while node_ids_to_process.size > 0
        anchor_node_id = node_ids_to_process.pop
        # set the anchors cc_number and add all neighbors to the process
        # list that haven't been yet
        anchor_node = getNode(anchor_node_id)
        anchor_node.cc_number = connected_component_number
        anchor_node.neighbour_ids.each do |neighbor_node_id|
          unless visited_node_ids.include?(neighbor_node_id)
            node_ids_to_process << neighbor_node_id
            if all_node_ids.include? neighbor_node_id
              all_node_ids.delete_if { |x| x==neighbor_node_id }
            end
          end
          # this node is finished
          visited_node_ids << anchor_node_id
        end
      end
    end
    @connected_components_count = connected_component_number
  end

  def empty
    clear()
  end

  def clear
    # deletes all nodes and edges in the graph
    self.nodes = []
    self.edges = []
  end



end