#lang dssl2
let eight_principles = ["Know your rights.",
                        "Acknowledge your sources.",
                        "Protect your work.",
                        "Avoid suspicion.",
                        "Do your own work.",
                        "Never falsify a record or permit another person to do so.",
                        "Never fabricate data, citations, or experimental results.",
                        "Always tell the truth when discussing your work with your instructor."]
# Final project: Trip Planner

import cons
import sbox_hash
import 'project-lib/dictionaries.rkt'
import 'project-lib/graph.rkt'
import 'project-lib/binheap.rkt'
import 'project-lib/stack-queue.rkt'

### Basic Types ###

#  - Latitudes and longitudes are numbers:
# @1.1 Items1: position
let Lat?  = num?
let Lon?  = num?

#@1.1 Items2: road (position, position)
#@1.1 Items3: point-of-interest (POI) (positon, str? catogory, str?name)
#         name: unique; category: shared ; name: feature many POIs
#  - Point-of-interest categories and names are strings:
let Cat?  = str?
let Name? = str?

### Raw Item Types ###

#  - Raw positions are 2-element vectors with a latitude and a longitude
let RawPos? = VecKC[Lat?, Lon?]

#  - Raw road segments are 4-element vectors with the latitude and
#    longitude of their first endpoint, then the latitude and longitude
#    of their second endpoint
let RawSeg? = VecKC[Lat?, Lon?, Lat?, Lon?]

#  - Raw points-of-interest are 4-element vectors with a latitude, a
#    longitude, a point-of-interest category, and a name
let RawPOI? = VecKC[Lat?, Lon?, Cat?, Name?]

### Contract Helpers ###

# ListC[T] is a list of `T`s (linear time):
let ListC = Cons.ListC
# List of unspecified element type (constant time):
let List? = Cons.list?


interface TRIP_PLANNER:

    # Returns the positions of all the points-of-interest that belong to
    # the given category.
    def locate_all(
            self,
            dst_cat:  Cat?           # point-of-interest category
        )   ->        ListC[RawPos?] # positions of the POIs, no duplicates

    # Returns the shortest route, if any, from the given source position
    # to the point-of-interest with the given name.
    def plan_route(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_name: Name?          # name of goal
        )   ->        ListC[RawPos?] # path to goal

    # Finds no more than `n` points-of-interest of the given category
    # nearest to the source position.
    def find_nearby(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_cat:  Cat?,          # point-of-interest category
            n:        nat?           # maximum number of results
        )   ->        ListC[RawPOI?] # list of nearby POIs

# @2.1 basic types: lat; lon; POI categories, names
class TripPlanner (TRIP_PLANNER):
    let POIs
    let input_roads
    let n_vertices:nat?
    let name_to_endpoint
    let endpoint_to_name
    let cat_to_endpoint
    let pos_to_vid
    let vid_to_pos
    let road_graph
    let road_pos
    
    def __init__(self,input_roads, POIs_data):
        self.input_roads = input_roads
        self.POIs =  POIs_data
        self.n_vertices = 2*len(self.input_roads)
        self.name_to_endpoint = HashTable(self.n_vertices, make_sbox_hash())
        self.endpoint_to_name = HashTable(self.n_vertices, make_sbox_hash())   
        self.cat_to_endpoint = HashTable(self.n_vertices, make_sbox_hash())  
        self.pos_to_vid = HashTable(self.n_vertices, make_sbox_hash())
        self.vid_to_pos = HashTable(self.n_vertices, make_sbox_hash()) 
        self._init_roads()
        self._init_POIs()   
                      
    def _init_roads(self):
        let roads = WUGraph(self.n_vertices)
        self.road_pos = None
        for edge in self.input_roads:
            let p1 = [edge[0],edge[1]]
            let p2 = [edge[2],edge[3]]
            if not self.pos_to_vid.mem?(p1) :
                self.pos_to_vid.put(p1,self.pos_to_vid.len())
                self.road_pos = cons(p1,self.road_pos)
                self.vid_to_pos.put(self.pos_to_vid.get(p1), p1) 
            let v1 = self.pos_to_vid.get(p1)
            self.endpoint_to_name.put(p1,v1)
            
            if not self.pos_to_vid.mem?(p2):
                self.road_pos = cons(p2,self.road_pos)
                self.pos_to_vid.put(p2,self.pos_to_vid.len())
                self.vid_to_pos.put(self.pos_to_vid.get(p2), p2)
            let v2 = self.pos_to_vid.get(p2)
            self.endpoint_to_name.put(p2,v2)            
            
            let length = ((edge[0]-edge[2])**2 + (edge[1]-edge[3])**2).sqrt()
            roads.set_edge(v1,v2,length)
        self.road_graph = roads
             
    def _init_POIs(self):
        for poi in self.POIs:
            let pos = [poi[0],poi[1]]
            let cat = poi[2]
            let name = poi[3]
            if self.cat_to_endpoint.mem?(cat):
                let pos_list =  self.cat_to_endpoint.get(cat)
                if not self._member_vec?(pos, pos_list):
                    self.cat_to_endpoint.put(cat, cons(pos, pos_list))
            else: 
                self.cat_to_endpoint.put(cat, cons(pos, None))
            if self.name_to_endpoint.mem?(name):
                let pos_list = self.name_to_endpoint.get(name)
                self.name_to_endpoint.put(name, cons(pos, pos_list))
            else:
                self.name_to_endpoint.put(name,cons(pos, None))
            self.endpoint_to_name.put(pos, name)

    def _member_vec?(self,vec, lst):
        let cur = lst
        while cur is not None:
            if cur.data == vec:         
                return True
            cur = cur.next
        return False
    
    # Returns the positions of all the points-of-interest that belong to
    # the given category.
    def locate_all(self, dst_cat:Cat?)-> ListC[RawPos?]: # positions of the POIs, no duplicates
        if not self.cat_to_endpoint.mem?(dst_cat):
            return None
        let endpoint =  self.cat_to_endpoint.get(dst_cat)
        return endpoint

    # Returns the shortest route, if any, from the given source position
    # to the point-of-interest with the given name.
    def plan_route( self,src_lat:Lat?,src_lon:Lon?,dst_name: Name?)->ListC[RawPos?]: # path to goal
        #start endpoint
        let start = [src_lat,src_lon]
        if not self.name_to_endpoint.mem?(dst_name):
            return None
        #destination endpoint
        let dsts =  self.name_to_endpoint.get(dst_name)
        let path = self._shortest_path(start,dsts)
        return path
        
    def _dijkstra(self,start):
        if not self.pos_to_vid.mem?(start): 
            return None
        let start_vid = self.pos_to_vid.get(start)
        let n = self.n_vertices
        let dist = [+inf; n]
        let pred = [None; n]
        let visited = [False;n]
        dist[start_vid] = 0
        let pq = BinHeap[VecKC[num?, nat?]](n,  λ a, b: a[0] < b[0])
        # todo <-
        pq.insert([0,start_vid])
        while pq.len()>0:
            let min =  pq.find_min()
            let cur_dist = min[0]
            let cur_vid = min[1]
            pq.remove_min()
            # done <-
            if visited[cur_vid]:
                continue
            visited[cur_vid] = True
            # relax 
            let nbr = self.road_graph.get_adjacent(cur_vid)
            while nbr is not None:
                let nbr_v = nbr.data 
                let w = self.road_graph.get_edge(cur_vid,nbr_v)
                if w == 0:
                    nbr = nbr.next
                    continue

                if cur_dist + w < dist[nbr_v]:
                    dist[nbr_v] = cur_dist + w
                    pred[nbr_v] = cur_vid  
                    # todo <-
                    pq.insert([dist[nbr_v],nbr_v])               
                nbr = nbr.next 
        return [dist, pred]

    def _shortest_path(self,start,dsts) ->ListC[RawPos?]:
        let result = self._dijkstra(start)
        if result is None:
            return None
        let dist = result[0]
        let pred = result[1]
    
        let length = +inf
        let short = None
        let cur_dst = dsts
        
        while cur_dst is not None:
            let dst = cur_dst.data
            if self.pos_to_vid.mem?(dst):
                let vid = self.pos_to_vid.get(dst) 
                if dist[vid] < length:
                    length = dist[vid]
                    short = dst
            cur_dst = cur_dst.next
        if short is None or length == +inf: 
            return None    
        
        let path = None    
        let vid  = self.pos_to_vid.get(short) 
        while vid is not None:
            path = cons(self.vid_to_pos.get(vid), path)
            vid  = pred[vid]
        return path
    
    # Finds no more than `n` points-of-interest of the given category
    # nearest to the source position.
    def find_nearby(self,src_lat:Lat?,src_lon:Lon?,dst_cat:Cat?, n:nat?) -> ListC[RawPOI?]: # list of nearby POIs 
        let start =  [src_lat,src_lon]  
        if not self.cat_to_endpoint.mem?(dst_cat):
            return None
        let pos_list = self.cat_to_endpoint.get(dst_cat)
        # destination list
        let res = self._dijkstra(start)
        if res is None:
            return None
        let dist = res[0]
        let bh = BinHeap[VecKC[num?, RawPos?]](self.n_vertices,  λ a, b: a[0] < b[0])
        while pos_list is not None:
            let dst = pos_list.data
            if self.pos_to_vid.mem?(dst) and dist[self.pos_to_vid.get(dst)] < +inf:
                bh.insert([dist[self.pos_to_vid.get(dst)],dst])
            pos_list = pos_list.next
        # distance list
        let i = 0
        let result = None
        while i <n and bh.len()>0:
            let pair =  bh.find_min()
            let dst = pair[1]
            bh.remove_min()
            for poi in self.POIs:
                if i == n: break
                if poi[0] == dst[0] and poi[1] == dst[1] and poi[2] == dst_cat: 
                    result = cons([dst[0], dst[1], dst_cat, poi[3]], result)
                    i = i + 1
        return result
#   ^ YOUR CODE HERE

# a TripPlanner instanse
def my_first_example():
    return TripPlanner([[0,0, 0,1], [0,0, 1,0]],
                       [[0,0, "bar", "Sketchbook"],
                        [0,1, "food", "Cross Rhodes"]])

test 'My first locate_all test':
    assert my_first_example().locate_all("food") == \
        cons([0,1], None)
        
# locate_all
test 'local-all 01: Nothing' :
    let tp = TripPlanner(
      [[0, 0, 1, 0]],
      [])
    let result = tp.locate_all('bank')
    assert result == None
    
test 'local-all 02: wrong category':
    let tp = TripPlanner(
      [[0, 0, 1, 0]],
      [[1, 0, 'bank', 'Union']])
    let result = tp.locate_all('food')
    assert result == None

test 'local-all 03: 2 cat same location':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0],
       [3, 0, 4, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [5, 0, 'barber', 'Judy'],
       [5, 0, 'barber', 'Lily']])
    let result = tp.locate_all('barber')
    assert result == cons([5, 0], cons([3, 0],None))    
#####    
##### plan_route
#####  
test 'My first plan_route test':
   assert my_first_example().plan_route(0, 0, "C R") ==None
   
test 'plan_route 01: shortest path 01: start is destination':
    let tp = TripPlanner(
      [[1, 0, 0, 0],
      [0, 0, 2, 0]],
      [[1, 0, 'bank', 'Union']])
    let result = tp.plan_route(1, 0, 'Union')
    assert result == cons([1, 0],None)
        
test 'plan_route 02: shortest path 02: 2-step route':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [2.5, 0, 'barber', 'Tony']])
    let result = tp.plan_route(0, 0, 'Tony')
    assert result == cons([0, 0], cons([1.5, 0], cons([2.5, 0],None)))
    
test 'plan_route 03: My first plan_route test':
   assert my_first_example().plan_route(0, 0, "Cross Rhodes") == \
       cons([0,0], cons([0,1], None))
        
test 'plan_route 05:  MST is not SSSP (route)':
    let tp = TripPlanner(
      [[-1.1, -1.1, 0, 0],
       [0, 0, 3, 0],
       [3, 0, 3, 3],
       [3, 3, 3, 4],
       [0, 0, 3, 4]],
      [[0, 0, 'food', 'Sandwiches'],
       [3, 0, 'bank', 'Union'],
       [3, 3, 'barber', 'Judy'],
       [3, 4, 'barber', 'Tony']])
    let result = tp.plan_route(-1.1, -1.1, 'Tony')
    assert result == cons {data: [-1.1, -1.1], 
        next: cons {data: [0, 0], next: cons {data: [3, 4], next: None}}}

test 'plan_route 06: Destination is the 2nd of 3 POIs at that location':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0],
       [3, 0, 4, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [5, 0, 'bar', 'Pasta'],
       [5, 0, 'barber', 'Judy'],
       [5, 0, 'food', 'Jollibee']])
    let result = tp.plan_route(0, 0, 'Judy')
    assert result == cons {data: [0, 0], next: cons {data: [1.5, 0], 
    next: cons {data: [2.5, 0], next: cons {data: [3, 0], 
    next: cons {data: [4, 0], next: cons {data: [5, 0], next: None}}}}}}

        
test 'plan_route 08: relevant POIs; 1 reachable':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [4, 0, 'food', 'Jollibee'],
       [5, 0, 'barber', 'Judy']])
    let result = tp.plan_route(0, 0, 'Judy')
    assert result == None
    let result1 = tp.find_nearby(0, 0, 'barber', 2)
    assert result1 == cons {data: [3, 0, 'barber', 'Tony'], next: None}
    
test 'plan_route 09: plan_route start not in graph':
    let tp = TripPlanner(
        [[0,0,1,0]],                      
        [[1,0,'food','Cafe']])
    let r = tp.plan_route(9,9,'Cafe')     
    assert r == None

test 'plan_route 10: plan_route name not found':
    let tp = TripPlanner(
        [[0,0,1,0]],
        [[1,0,'food','Cafe']])
    let r = tp.plan_route(0,0,'NoSuch')  
    assert r == None
    
#####    
##### find_nearby
#####      
test 'My first find_nearby test':
    assert my_first_example().find_nearby(0, 0, "food", 1) == \
        cons([0,1, "food", "Cross Rhodes"], None)

test 'nearby 02: n bigger than POIs':
    let tp = TripPlanner(
        [[0,0, 2,0], [2,0, 4,0]],
        [[2,0,'food','A'], [4,0,'food','B']])
    let r = tp.find_nearby(0,0,'food', 5)
    assert r == cons {data: [4, 0, 'food', 'B'], 
        next: cons {data: [2, 0, 'food', 'A'], next: None}}

test 'nearby 03: pick closest 2':
    let tp = TripPlanner(
        [[0,0,1,0],[1,0,3,0],[3,0,6,0]],
        [[1,0,'bar','X'], [3,0,'bar','Y'], [6,0,'bar','Z']])
    let r = tp.find_nearby(0,0,'bar', 2)
    assert r == cons {data: [3, 0, 'bar', 'Y'], 
        next: cons {data: [1, 0, 'bar', 'X'], next: None}}

test 'nearby 04: same location, diff names':
    let tp = TripPlanner(
        [[0,0, 5,0]],
        [[5,0,'shop','S1'], [5,0,'shop','S2']])
    let r = tp.find_nearby(0,0,'shop', 5)
    assert r == cons {data: [5, 0, 'shop', 'S2'], 
        next: cons {data: [5, 0, 'shop', 'S1'], next: None}}
    
test 'nearby 05:relevant POIs; 1 reachable':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [4, 0, 'food', 'Jollibee'],
       [5, 0, 'barber', 'Judy']])
    let result = tp.find_nearby(0, 0, 'barber', 2)
    assert result == cons {data: [3, 0, 'barber', 'Tony'], next: None}
      
test 'nearby 06: Relevant POI is not reachable':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [4, 0, 'food', 'Jollibee'],
       [5, 0, 'barber', 'Judy']])
    let result = tp.find_nearby(0, 0, 'food', 1)
    assert result == None  
    
test 'nearby 07: n = 0':
    let tp = TripPlanner(
        [[0,0,1,0]],                     
        [[1,0,'food','Cafe']])           
    let r = tp.find_nearby(0,0,'food',0)
    assert r == None  