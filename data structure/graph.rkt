#lang dssl2
let eight_principles = ["Know your rights.",
                        "Acknowledge your sources.",
                        "Protect your work.",
                        "Avoid suspicion.",
                        "Do your own work.",
                        "Never falsify a record or permit another person to do so.",
                        "Never fabricate data, citations, or experimental results.",
                        "Always tell the truth when discussing your work with your instructor."]
# HW4: Graph
import cons
import 'hw4-lib/dictionaries.rkt'

###
### REPRESENTATION
###
# A Vertex is a natural number.
let Vertex? = nat?

# A VertexList is either
#  - None, or
#  - cons(v, vs), where v is a Vertex and vs is a VertexList
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a real number. (It’s a number, but it’s neither infinite
# nor not-a-number.)
let Weight? = AndC(num?, NotC(OrC(inf, -inf, nan)))

# An OptWeight is either
# - a Weight, or
# - None
let OptWeight? = OrC(Weight?, NoneC)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is either
#  - None, or
#  - cons(w, ws), where w is a WEdge and ws is a WEdgeList
let WEdgeList? = Cons.ListC[WEdge?]


# A weighted, undirected graph ADT.
interface WUGRAPH:

    # Returns the number of vertices in the graph. (The vertices are
    # numbered 0, 1, ..., k - 1.)
    def n_vertices(self) -> nat?

    # Returns the number of edges in the graph.
    def n_edges(self) -> nat?

    # Sets the weight of the edge between u and v to be w. Passing a
    # real number for w updates or adds the edge to have that weight,
    # whereas providing providing None for w removes the edge if
    # present. (In other words, this operation is idempotent.)
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC

    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?

    # Gets a list of all vertices adjacent to v.
    def get_adjacent(self, v: Vertex?) -> VertexList?

    # Gets a list of all edges in the graph.
    # This list only includes one direction for each edge. For
    # example, if there is an edge of weight 10 between vertices
    # 1 and 3, then WEdge(1, 3, 10) will be in the list, but not
    # WEdge(3, 1, 10).
    def get_all_edges(self) -> WEdgeList?

class WUGraph (WUGRAPH):
    let _len:nat?
    let _edges:nat?
    let _matrix

    def __init__(self, n_vert: nat?):
        self._edges = 0
        self._len = n_vert
        self._init_matrix(n_vert)
     
    def n_vertices(self) -> nat?:
        return self._len
   
    def n_edges(self) -> nat?:
        return self._edges
               
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC:
        if not self._v_exist?(v) or not self._v_exist?(u):
            return error('vertex not exist')
        let i = min(u,v)
        let j = max(u,v)
        let old_w = self._matrix[i][j]
        let new_w = w
        if new_w == old_w:
            return
        elif old_w == None and new_w is not None:
            self._edges = self._edges + 1
        elif old_w is not None and new_w == None:
            self._edges = self._edges - 1
        self._matrix[i][j] = new_w
        self._matrix[j][i] = new_w
      
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?:
        if not self._v_exist?(v) or not self._v_exist?(u): 
            return None    
        let i = min(u,v)
        let j = max(u,v)
        let w = self._matrix[i][j]
        return w
                 
    def get_adjacent(self, v: Vertex?) -> VertexList?:
        if v < 0 or v >= self._len:
            return None
        let i = 0
        let result = None
        while i < self._len:
            let w = self.get_edge(v,i)
            if w is not None:
                result = cons(i,result)
            i = i + 1            
        return result
  
    def get_all_edges(self) -> WEdgeList?:
        if self._edges == 0: 
            return None
        let i = 0
        let result = None
        while i < self._len:
            let j = 0
            while j < self._len:
                let w = self._matrix[i][j]
                if w is not None and i <= j:
                    result = cons(WEdge(i, j, w), result)
                j = j + 1
            i = i + 1
        return result 
    
        
# Other methods you may need can go here.
    def _v_exist?(self, v: Vertex?) -> bool?:
        if v < 0 or v >= self._len:
            return False
        return True
    def _init_matrix(self, n_vert:nat?) -> NoneC:
        let i = 0
        self._matrix = [None;n_vert] 
        while i < n_vert:
            let row =  [None;n_vert]
            self._matrix[i] = row
            i = i + 1    

    def print_all_edges(self,e)->NoneC:
        while e is not None:
            let u = e.data.u
            let v = e.data.v
            let w = e.data.w
            print('%p,%p,%p ;',u,v,w)
            e = e.next            

test 'n_vertices basic':
    let g = WUGraph(0)
    assert g.n_vertices() == 0
    assert g.get_all_edges() == None
    assert g.n_edges() == 0
    assert_error g.set_edge(0,0,0) 
    assert_error g.set_edge(1,0,0) 
    assert g.get_edge(0,0) == None
    assert g.get_edge(1,0) == None
    assert g.get_adjacent(1) == None
    assert g.get_all_edges() == None

test 'n_vertices =1':    
    let g = WUGraph(1)
    assert g.n_vertices() == 1
    assert g.n_edges() == 0
    g.set_edge(0,0,0)
    assert_error g.set_edge(1,0,0) 
    assert g.get_edge(0,0) == 0
    assert g.get_edge(1,0) == None
    let a = g.get_adjacent(1)
    assert a == None
    assert a is None
    assert_error a.data == 2
    assert g.get_all_edges() is not None   
    
test 'get_adjacent not considers disconnected nodes to be adjacent to themselves':    
    let g = WUGraph(3)
    assert g.n_vertices() == 3
    assert g.n_edges() == 0
    let a = g.get_adjacent(1)
    assert a == None
    assert a is None
    assert_error a.data == 2
    g.set_edge(1,1,1)
    let b = g.get_adjacent(1)
    assert b is not None
    assert b.data == 1
    

         
            
test 'set, get,basic':
    let g = WUGraph(4)
    g.set_edge(1,3,1)     
    g.set_edge(2,1,55) 
    assert_error g.set_edge(4,1,1) 
    assert g.get_edge(1,3)==1
    assert g.get_edge(3,1)==1
    assert g.n_edges() ==2
    g.set_edge(1,3,None)
    assert g.get_edge(3,1)==None
    assert g.n_vertices() == 4
    assert g.n_edges() ==1


test 'set, get,2':
    let g = WUGraph(4)
    g.set_edge(1,3,1)     
    g.set_edge(2,1,55) 
    g.set_edge(2,1,5)
    assert g.get_edge(2,1)==5
    assert g.get_edge(1,2)==5  
    assert g.n_edges() ==2  
    g.set_edge(1,3,None)
    g.set_edge(2,1,None)
    assert g.n_edges() ==0
    g.set_edge(2,1,None)
    assert g.n_edges() ==0
    assert_error g.set_edge(5,1,None)
    
test 'set self edges ,2':
    let g = WUGraph(4)
    g.set_edge(1,1,1)     
    g.set_edge(2,2,55) 
    g.set_edge(2,1,5)
    assert g.get_edge(2,2)==55
    assert g.get_edge(1,2)==5  
    assert g.n_edges() ==3 

     
test 'get all edges print':
    let g = WUGraph(4)
    g.set_edge(1,3,1)     
    g.set_edge(2,1,1) 
    let edges = g.get_all_edges()
        
        
test 'self test':
    let g = WUGraph(4)
    g.set_edge(0,1,1) 
    assert g.get_edge(0,1)  == 1  
    
test 'get all edges':
    let g = WUGraph(4)
    assert g.n_vertices() ==4
    g.set_edge(0,3,1)     
    g.set_edge(2,1,1) 
    let edges = g.get_all_edges()
    assert edges is not None
    
test 'illegal':
    let g = WUGraph(8)
    assert g.n_vertices() == 8
    assert g.get_all_edges() == None
    assert g.n_edges() == 0
    assert_error g.set_edge(8,0,0) 
    assert g.get_edge(1,9) == None
    assert g.get_adjacent(5) == None
    assert g.get_all_edges() == None
###
### List helpers
###

# When testing, you should normalize the results of methods that produce
# results in an unspecified order. We provide these functions to help you
# do that; see details in the handout.

# normalize_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def normalize_vertices(lst: Cons.list?) -> Cons.list?:
    def vertex_lt?(u, v): return u < v
    return Cons.sort[Vertex?](vertex_lt?, lst)

# normalize_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically.
def normalize_edges(lst: Cons.list?) -> Cons.list?:
    def normalize_edge(e: WEdge?) -> WEdge?:
        if e.u > e.v: return WEdge(e.v, e.u, e.w)
        else: return e
    def edge_lt?(e1, e2):
        return e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    lst = Cons.map(normalize_edge, lst)
    return Cons.sort[WEdge?](edge_lt?, lst)

test 'get_adjacent basic' : 
    let g = WUGraph(4)
    g.set_edge(0,3,1)     
    g.set_edge(2,1,1) 
    g.set_edge(1,3,1)      
    let ga = g.get_adjacent(1)  
    let nv = normalize_vertices(ga)
    assert nv == cons(2,cons(3,None))  
    
test 'get_adjacent 2' : 
    let g = WUGraph(4)
    g.set_edge(0,1,1)     
    g.set_edge(2,1,1) 
    g.set_edge(1,3,1)  
    assert g.n_edges() == 3
    let ga = g.get_adjacent(1)  
    let nv = normalize_vertices(ga)
    assert nv == cons(0,cons(2,cons(3,None)))
    g.set_edge(1,3,None)
    assert g.n_edges() == 2  
    let nv2 = normalize_vertices(g.get_adjacent(1))  
    assert nv2 == cons(0,cons(2,None)) 
        
test 'get_all_edges':
    let g = WUGraph(4)
    g.set_edge(0,3,1)     
    g.set_edge(2,1,1) 
    g.set_edge(1,3,1)      
    let gae = g.get_all_edges()  
    let ne = normalize_edges(gae)
    assert ne == cons {data: WEdge {u: 0, v: 3, w: 1}, 
        next: cons {data: WEdge {u: 1, v: 2, w: 1}, 
        next: cons {data: WEdge {u: 1, v: 3, w: 1}, 
        next: None}}} 
    
    
test 'get_adjacent 2' : 
    let g = WUGraph(4)
    g.set_edge(0,1,1)     
    g.set_edge(2,1,1) 
    g.set_edge(1,3,1)  
    assert g.n_edges() == 3
    let ga = g.get_adjacent(4)  
    let nv = normalize_vertices(ga)
    assert nv == None
    g.set_edge(0,1,None)
    g.set_edge(1,3,None)
    let gae = g.get_all_edges()  
    let ne = normalize_edges(gae)
    assert ne == cons(WEdge(1,2,1),None)    
    g.set_edge(1,2,None)
    let gae1 = g.get_all_edges()  
    let ne1 = normalize_edges(gae1)
    assert ne1 == None     
 
###
### BUILDING GRAPHS
###

def example_graph() -> WUGraph?:
    let result = WUGraph(6) # 6-vertex graph from the assignment
    result.set_edge(0,1,12)
    result.set_edge(1,3,56)
    result.set_edge(1,2,31)
    result.set_edge(2,4,-2)
    result.set_edge(2,5,7)
    result.set_edge(3,4,9)
    result.set_edge(3,5,1)
    return result

struct CityMap:
    let graph
    let city_name_to_node_id
    let node_id_to_city_name
    
#   ^ YOUR CODE HERE
def hash_dict():
    return HashTable(10, first_char_hasher)     
    
def assoc_dict():
    return AssociationList()
    
def my_home_region():
    let ht = WUGraph(5)
    ht.set_edge(0,1,100)
    ht.set_edge(0,2,200)
    ht.set_edge(2,3,100)
    ht.set_edge(1,2,100)
    ht.set_edge(4,2,200)
    
    let h = hash_dict()    
    h.put('Sui',0)
    h.put('Wuhan',2)
    h.put('YiChang',1)
    h.put('ChangJiang',3)
    h.put('HuangHe',4)
    
    let a = assoc_dict()    
    a.put(0,'Sui')
    a.put(2,'Wuhan')
    a.put(1,'YiChang')
    a.put(3,'ChangJiang')
    a.put(4,'HuangHe')
    
    return CityMap(ht,h,a)

test 'example graph':
    let eg = example_graph() 
    let ne = normalize_edges(eg.get_all_edges())    
    assert ne == cons {data: WEdge {u: 0, v: 1, w: 12}, 
    next: cons {data: WEdge {u: 1, v: 2, w: 31}, 
    next: cons {data: WEdge {u: 1, v: 3, w: 56}, 
    next: cons {data: WEdge {u: 2, v: 4, w: -2}, 
    next: cons {data: WEdge {u: 2, v: 5, w: 7}, 
    next: cons {data: WEdge {u: 3, v: 4, w: 9}, 
    next: cons {data: WEdge {u: 3, v: 5, w: 1}, 
    next: None}}}}}}}
        
test 'my CityMap':
    let g = my_home_region()
    assert g.graph.get_adjacent(1) is not None
    assert g.city_name_to_node_id.get('Sui') == 0
    assert g.node_id_to_city_name.get(0) == 'Sui'
    g.graph.set_edge(1, 0, 50)
    assert g.graph.n_edges() == 5
    let ga = g.graph.get_adjacent(4)
    let nv = normalize_vertices(ga)
    assert nv == cons(2, None)
    let gae = g.graph.get_all_edges()
    let ne = normalize_edges(gae)
    assert ne == cons {data: WEdge {u: 0, v: 1, w: 50}, 
    next: cons {data: WEdge {u: 0, v: 2, w: 200},
     next: cons {data: WEdge {u: 1, v: 2, w: 100}, 
     next: cons {data: WEdge {u: 2, v: 3, w: 100}, 
     next: cons {data: WEdge {u: 2, v: 4, w: 200}, 
     next: None}}}}}

###
### DFS
###

# dfs : WUGRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.
def dfs(graph: WUGRAPH!, start: Vertex?, f: FunC[Vertex?, AnyC]) -> NoneC:
    let seen = [False;graph.n_vertices()]
    let stack = cons(start, None)
    while stack is not None:
        let v = stack.data
        stack = stack.next
        
        if seen[v] is False:
            f(v)
            seen[v] = True
            
            let neighbour = graph.get_adjacent(v)
            while neighbour is not None:
                let u = neighbour.data
                neighbour = neighbour.next
                if seen[u] is False:
                    stack = cons(u,stack)

#   ^ YOUR CODE HERE  

###
### DFS helpers
###

# dfs_to_list : WUGRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
# This function uses your `dfs` function to build a list in the
# order of the search.
def dfs_to_list(graph: WUGRAPH!, start: Vertex?) -> VertexList?:
    let list = None
    # Add to the front when we visit a node
    dfs(graph, start, lambda new: list = cons(new, list))
    # Reverse to the get elements in visiting order.
    return Cons.rev(list)

# one_of : AnyC? VecC[AnyC] -> bool?
# Returns true is `x` is one of the elements of `vec`.
def one_of(x, vec):
    for y in vec:
        if x == y: return True
    return False

## You should test your code thoroughly. Here is one test to get you started:
    
test 'my first DFS test':
    let g = WUGraph(4)
    g.set_edge(0,1,1)
    g.set_edge(0,2,10)
    g.set_edge(1,3,12)
    g.set_edge(2,3,-4)

    # Cons.from_vec is a convenience function from the `cons` library that
    # allows you to write a vector (using the nice vector syntax), and get
    # a linked list with the same elements.
    assert one_of(dfs_to_list(g, 0),
                  [Cons.from_vec([0,1,3,2]),
                   Cons.from_vec([0,2,3,1])])
                   
test 'my second DFS test':
    let g = WUGraph(6)
    g.set_edge(0,1,1)
    g.set_edge(0,2,10)
    g.set_edge(1,3,12)
    g.set_edge(2,3,-4)    
    g.set_edge(5,5,-4)
    g.set_edge(5,4,-4)
    # Cons.from_vec is a convenience function from the `cons` library that
    # allows you to write a vector (using the nice vector syntax), and get
    # a linked list with the same elements.
    assert one_of(dfs_to_list(g, 0),
                  [Cons.from_vec([0,1,3,2]),
                   Cons.from_vec([0,2,3,1])])
    assert one_of(dfs_to_list(g, 3),
                  [Cons.from_vec([3,1,0,2]),
                   Cons.from_vec([3,2,0,1])])                   
                   
    assert one_of(dfs_to_list(g, 5),
                  [Cons.from_vec([5,4]),
                   Cons.from_vec([4,5])])