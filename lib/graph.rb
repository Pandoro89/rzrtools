require 'json/ext'
require 'rgl/dijkstra'
require 'rgl/adjacency'


class Graph
  #Vertex = Struct.new(:name, :neighbors, :dist, :prev)

  def initialize(graph,jump_bridges=0)
    #@vertices = Hash.new{ |h,k| h[k] = Vertex.new(k, [], Float::INFINITY) }
    #@edges = {}
    t1 = Time.now

    @vertices = Hash.new
    
    # h = Rails.cache.read("graph-vertices-edges-#{jump_bridges}")
    # h_decoded = JSON.parse(h) if !h.nil?
    # if h_decoded.nil?
      graph.each do |(v1, v2, dist)|
        puts "v1: #{v1}, v2: #{v2}"
        @vertices[v1] ||= []
        @vertices[v1] << v2
        @vertices[v2] ||= []
        @vertices[v2] << v1 if !v2.nil?
        # @edges[[v1, v2]] = @edges[[v2, v1]] = dist
      end
    # else
      # puts h_decoded[:vertices]
      # puts "---------"
      # @vertices = h_decoded[:vertices].map { |v1,v2,d| Vertex.new(v1, v2, d) }
      # @edges = h_decoded[:edges]
    # end
    #       puts @vertices
    # Rails.cache.write("graph-vertices-edges-#{jump_bridges}", {:vertices=> @vertices, :edges => @edges}.to_json)
    #puts @vertices.to_json

    # arbitrary elapsed time
    t2 = Time.now

    msecs = time_diff_milli t1, t2

    puts "Time Spent: #{msecs}"

    @dijkstra_source = nil

    ######
    # @agraph = RGL::AdjacencyGraph[]
    @edge_weights_map = {}
    @agraph = RGL::AdjacencyGraph.new()


    puts @agraph
    graph.each do |(v1, v2, dist)|
      @agraph.add_edge(v1,v2)
      # @apgrah.basic_add_edge(v1,v2)
      @edge_weights_map[[v1, v2]] = dist
    end

    @dijkstra = RGL::DijkstraAlgorithm.new(@agraph, @edge_weights_map, RGL::DijkstraVisitor.new(@agraph))
  end

  def time_diff_milli(start, finish)
   (finish - start) * 1000.0
end

  # def dijkstra(source)
  #   return  if @dijkstra_source == source
  #   q = @vertices.values
  #   q.each do |v|
  #     v.dist = Float::INFINITY
  #     v.prev = nil
  #   end
  #   @vertices[source].dist = 0
  #   until q.empty?
  #     u = q.min_by {|vertex| vertex.dist}
  #     break if u.dist == Float::INFINITY
  #     q.delete(u)
  #     u.neighbors.each do |v|
  #       vv = @vertices[v]
  #       if q.include?(vv)
  #         alt = u.dist + @edges[[u.name, v]]
  #         if alt < vv.dist
  #           vv.dist = alt
  #           vv.prev = u.name
  #         end
  #       end
  #     end
  #   end
  #   @dijkstra_source = source
  # end

  def shortest_path(source, target)

    t1 = Time.now
    # dijkstra(source)
    # path = []
    # u = target
    # while u
    #   path.unshift(u)
    #   u = @vertices[u].prev
    # end
    path = @dijkstra.shortest_path(source,target)

    t2 = Time.now

    msecs = time_diff_milli t1, t2

    puts "Time Spent2 : #{msecs}"

    return path #, @vertices[target].dist
  end

  def to_s
    "#<%s vertices=%p edges=%p>" % [self.class.name, @vertices.values, @edges]
  end
end