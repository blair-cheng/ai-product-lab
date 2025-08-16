from expand import expand
from collections import deque
import heapq


# TO DO: Implement Breadth-first Search.
def breadth_first_search(time_map, start, end):
    """
    Breadth-first Search

    Args:
        time_map (dict): A map containing 【travel times】 between connected nodes (places or intersections), where every
        node is a dictionary key, and every value is an inner dictionary whose keys are the children of that node and
        values are travel times. Travel times are "null" for nodes that are not connected.
        start (str): The name of the node from where to start traversal
        end (str): The name of the node from where to start traversal

    Returns: 
        visited (list): A list of visited nodes in the order in which they were visited
        path (list): The final path found by the search algorithm
    """
    # Input validation
    if start not in time_map or end not in time_map:
        raise ValueError("Stard or end node not in time_map")
    
    # Initialize visitied list
    visited = []
    # Initialize frontier
    frontier = deque([(start,[start])])

    # Iterate when frontier is not empty
    while frontier:
        # FIFO
        current, path = frontier.popleft()

        if current in visited:
            continue
        visited.append(current)

        if current == end:
            return visited, path
        
        neighbors = expand(current,time_map)
        
        for neighbor in neighbors:
            # Put unvisited addresss in frontier
            if neighbor not in visited:
                frontier.append((neighbor, path+ [neighbor]))

    return visited, []



# TO DO: Implement Depth-first Search.
def depth_first_search(time_map, start, end):
    """
    Depth-first Search

    Args:
        time_map (dict): A map containing travel times between connected nodes (places or intersections), where every
        node is a dictionary key, and every value is an inner dictionary whose keys are the children of that node and
        values are travel times. Travel times are "null" for nodes that are not connected.
        start (str): The name of the node from where to start traversal
        end (str): The name of the node from where to start traversal

    Returns:
        visited (list): A list of visited nodes in the order in which they were visited
        path (list): The final path found by the search algorithm
    """
    # Input validation
    if start not in time_map or end not in time_map:
        raise ValueError("Stard or end node not in time_map")
    # Initialize visited and frontier
    visited = []
    frontier = deque([(start, [start])])

    while frontier:
        # LIFO
        current, path = frontier.pop()
        if current in visited:
            continue
        visited.append(current)

        if current == end:
            return visited, path
        
        neighbors = expand(current,time_map)
        
        for neighbor in neighbors:
            if neighbor not in visited:
                frontier.append((neighbor, path +[neighbor]))

    return visited, []


# TO DO: Implement Greedy Best-first Search.
def best_first_search(dis_map, time_map, start, end):
    """
    Greedy Best-first Search

    Args:
        time_map (dict): A map containing travel times between connected nodes (places or intersections), where every
        node is a dictionary key, and every value is an inner dictionary whose keys are the children of that node and
        values are travel times. Travel times are "null" for nodes that are not connected.
        dis_map (dict): A map containing straight-line (Euclidean) distances between every pair of nodes (places or
        intersections, connected or not), where every node is a dictionary key, and every value is an inner dictionary whose keys are the
        children of that node and values are straight-line distances.
        start (str): The name of the node from where to start traversal
        end (str): The name of the node from where to start traversal

    Returns:
        visited (list): A list of visited nodes in the order in which they were visited
        path (list): The final path found by the search algorithm
    """
    # Input validation
    if start not in time_map or end not in time_map:
        raise ValueError("Stard or end node not in time_map")
    if start not in dis_map or end not in dis_map:
        raise ValueError("Stard or end node not in dis_map")

    # Initialize frontier
    frontier = []
    # Push the start into frontier: heuristic score = dis_map[start][end], current node = start, path = [start]
    heapq.heappush(frontier, (dis_map[start][end], start, [start]))
    # Initialize visited list
    visited = []

    while frontier:
        # pop the node with smallest heuristic score
        h_score, current, path = heapq.heappop(frontier)

        # skip visited node
        if current in visited:
            continue
        visited.append(current)

        # achieve end
        if current == end:
            return visited, path
        
        # expand neighbors of current node in time_map
        neighbors = expand(current, time_map)
        # Iterate neighbors and push into frontier        
        for neighbor in neighbors:
            if neighbor in visited:
                continue
            if neighbor not in dis_map or end not in dis_map[neighbor] or dis_map[neighbor][end] is None:
                continue
            heapq.heappush(frontier,(dis_map[neighbor][end], neighbor, path + [neighbor]))

    # if end not find, return visited and empty path
    return visited, []
    

# TO DO: Implement A* Search.
def a_star_search(dis_map, time_map,start, end):
    """
    A* Search

    Args:
        time_map (dict): A map containing travel times between connected nodes (places or intersections), where every
        node is a dictionary key, and every value is an inner dictionary whose keys are the children of that node and
        values are travel times. Travel times are "null" for nodes that are not connected.
        dis_map (dict): A map containing straight-line (Euclidean) distances between every pair of nodes (places or
        intersections, connected or not), where every node is a dictionary key, and every value is an inner dictionary whose keys are the
        children of that node and values are straight-line distances.
        start (str): The name of the node from where to start traversal
        end (str): The name of the node from where to start traversal

    Returns:
        visited (list): A list of visited nodes in the order in which they were visited
        path (list): The final path found by the search algorithm
    """
    # Input validation
    if start not in time_map or end not in time_map:
        raise ValueError("Stard or end node not in time_map")
    if start not in dis_map or end not in dis_map:
        raise ValueError("Stard or end node not in dis_map")


    # Initialize frontier
    frontier = []
    # Push the start into frontier: f_score, current node = start, path = [start], g_score = 0
    heapq.heappush(frontier, (dis_map[start][end], start, [start] ,0))
    # Initialize visited list
    visited = []
    # Initialize dictionary to store g_score of each visited node and neighbors
    cost_so_far = {start:0}

    while frontier:
        # pop the node with smallest heuristic score
        f_score, current, path,current_g_score = heapq.heappop(frontier)
        
        # skip visited node
        if current in visited:
            continue
        visited.append(current)

        # achieve end
        if current == end:
            return visited, path
        
        # expand neighbors of current node in time_map
        neighbors = expand(current, time_map)

        # Iterate neighbors and push into frontier        
        for neighbor in neighbors:
            if neighbor not in dis_map or end not in dis_map[neighbor] or dis_map[neighbor][end] is None:
                continue
                #calculate f score of each neighbor
            g_score = current_g_score + time_map[current][neighbor]
            f_score = g_score + dis_map[neighbor][end]

                # update neighbor to frontier when it has a lower g_score than stored
            if neighbor not in cost_so_far or g_score < cost_so_far[neighbor]:
                cost_so_far[neighbor] = g_score
                heapq.heappush(frontier, (f_score, neighbor, path + [neighbor], g_score))

    # if end not find, return visited and empty path
    return visited, []
