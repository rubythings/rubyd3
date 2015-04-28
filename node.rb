class Node
attr_accessor :force_coulomb
attr_accessor :force_harmonic
attr_accessor :velocity
attr_accessor :id
attr_accessor :cc_number, :coordinate_x, :coordinate_y, :neighbour_ids, :movable

  def initialize(node_id)
    @id = node_id # id (as an integer for example)
    @neighbour_ids = [] # list of the ids of the neighbours
    @degree = 0 # number of neighbours
    @coordinate_x = 0
    @coordinate_y = 0
    @force_coulomb = [0,0]
    @force_harmonic = [0,0]
    @cc_number = 0 # the number of the connected component (0 if not assigned yet)
    @cc_centers = []
    @velocity = [0, 0] # instead of replacing the nodes, change its velocity to produce inertia
    @movable = 1
  end

  def getNeighbours
    return @neighbour_ids
  end

  def getDegree
    return @degree
  end

  def getId
    return @id
  end

  def setNeighbour(node_id)
    @neighbour_ids << node_id
    @degree += 1
  end

  def deleteNeighbour(node_id)
    @neighbour_ids.delete_if{|x| x == node_id}
    @degree -= 1
  end
end