require 'json/ext'

class Graph
  Vertex = Struct.new(:name, :neighbors, :dist, :prev)

  def initialize(graph,jump_bridges=0)
    @vertices = Hash.new{ |h,k| h[k] = Vertex.new(k, [], Float::INFINITY) }
    @edges = {}
    
    # h = Rails.cache.read("graph-vertices-edges-#{jump_bridges}")
    # h_decoded = JSON.parse(h) if !h.nil?
    # if h_decoded.nil?
      graph.each do |(v1, v2, dist)|
        @vertices[v1].neighbors << v2
        @vertices[v2].neighbors << v1
        @edges[[v1, v2]] = @edges[[v2, v1]] = dist
      end
    # else
      # puts h_decoded[:vertices]
      # puts "---------"
      # @vertices = h_decoded[:vertices].map { |v1,v2,d| Vertex.new(v1, v2, d) }
      # @edges = h_decoded[:edges]
    # end
    #       puts @vertices
    # Rails.cache.write("graph-vertices-edges-#{jump_bridges}", {:vertices=> @vertices, :edges => @edges}.to_json)

    @dijkstra_source = nil
  end

  def dijkstra(source)
    return  if @dijkstra_source == source
    q = @vertices.values
    q.each do |v|
      v.dist = Float::INFINITY
      v.prev = nil
    end
    @vertices[source].dist = 0
    until q.empty?
      u = q.min_by {|vertex| vertex.dist}
      break if u.dist == Float::INFINITY
      q.delete(u)
      u.neighbors.each do |v|
        vv = @vertices[v]
        if q.include?(vv)
          alt = u.dist + @edges[[u.name, v]]
          if alt < vv.dist
            vv.dist = alt
            vv.prev = u.name
          end
        end
      end
    end
    @dijkstra_source = source
  end

  def shortest_path(source, target)
    dijkstra(source)
    path = []
    u = target
    while u
      path.unshift(u)
      u = @vertices[u].prev
    end
    return path, @vertices[target].dist
  end

  def to_s
    "#<%s vertices=%p edges=%p>" % [self.class.name, @vertices.values, @edges]
  end
end