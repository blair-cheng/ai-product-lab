#lang dssl2
let eight_principles = ["Know your rights.",
                        "Acknowledge your sources.",
                        "Protect your work.",
                        "Avoid suspicion.",
                        "Do your own work.",
                        "Never falsify a record or permit another person to do so.",
                        "Never fabricate data, citations, or experimental results.",
                        "Always tell the truth when discussing your work with your instructor."]

# HW2: Stacks and Queues

import ring_buffer

interface STACK[T]:
    def push(self, element: T) -> NoneC
    def pop(self) -> T
    def empty?(self) -> bool?

# Defined in the `ring_buffer` library; copied here for reference.
# Do not uncomment! or you'll get errors.
# interface QUEUE[T]:
#     def enqueue(self, element: T) -> NoneC
#     def dequeue(self) -> T
#     def empty?(self) -> bool?

# Linked-list node struct (implementation detail):
struct _cons:
    let data
    let next: OrC(_cons?, NoneC)

###
### ListStack
###

class ListStack[T] (STACK):
    let head
    
    # Any fields you may need can go here.

    # Constructs an empty ListStack.
    def __init__ (self):
        self.head = None
    # Other methods you may need can go here.
                
    def push(self, element: T) -> NoneC:
        self.head = _cons(element, self.head)
        
    def pop(self) -> T:
        if self.head is None:
            error('empty stack')
        let result = self.head.data
        self.head = self.head.next
        return result
        
    def empty?(self) -> bool?:
        return self.head == None       
         
               
test "woefully insufficient":
    let s = ListStack()
    s.push(2)
    assert s.pop() == 2

test 'empty stack':
    let s = ListStack()
    assert_error s.pop(),'empty stack'   
    
test 'pop to be empty stack':
    let s = ListStack()
    s.push(2)
    assert s.pop() == 2
    assert_error s.pop(),'empty stack'    

test 'long stack':
    let s = ListStack()
    s.push(2)
    s.push(2)
    s.push(2)
    s.push(2)
    s.push(2)
    s.push(3)
    assert s.pop() == 3
    assert s.pop() == 2
    
    
###
### ListQueue
###

class ListQueue[T] (QUEUE):
    let head
    let tail
    # Any fields you may need can go here.

    # Constructs an empty ListQueue.
    def __init__ (self):
        self.head = None
        self.tail = None

    # Other methods you may need can go here.
        
    def enqueue(self, element: T) -> NoneC:
        let new_node = _cons(element, None)
        if self.head == None: 
            self.head = new_node
            self.tail = new_node
        else:
            self.tail.next = new_node
            self.tail = new_node
        
    def dequeue(self) -> T:
        if self.head is None:
            error('empty queue')
        let result = self.head.data
        self.head = self.head.next
        return result
        
    def empty?(self) -> bool?:
        return self.head == None      

test "woefully insufficient, part 2":
    let q = ListQueue()
    q.enqueue(2)
    assert q.dequeue() == 2
    assert_error q.dequeue(), 'empty queue'
    
test "empty queue":
    let q = ListQueue()
    q.enqueue(2)
    q.enqueue('gg')
    assert q.dequeue() == 2
    assert q.dequeue() == 'gg'
    assert_error q.dequeue(), 'empty queue'

###
### Playlists
###

struct song:
    let title: str?
    let artist: str?
    let album: str?

# Enqueue five songs of your choice to the given queue, then return the first
# song that should play.
def fill_playlist (q: QUEUE!):
    if not q.empty?(): error('non-empty queue')
    let s1 = song("Cascade", "Siouxsie and the Banshees", "A Kiss in the Dreamhouse")
    let s2 = song("Map of the Problematique", "Muse", "Black Holes and Revelations")
    let s3 = song("Shadowminds", "The Halo Effect", "Days of the Lost")
    let s4 = song("Mademoiselle Mabry", "Miles Davis", "Filles de Kilimanjaro")
    let s5 = song("We Flood Empty Lakes", "Yndi Halda", "Enjoy Eternal Bliss")
    q.enqueue(s1)
    q.enqueue(s2)
    q.enqueue(s3)
    q.enqueue(s4)
    q.enqueue(s5)
    return q.dequeue()
    
test "ListQueue playlist":
    let q = ListQueue()
    let first = fill_playlist(q)
    assert first.title == "Cascade"
    assert first.artist == "Siouxsie and the Banshees"
    assert first.album == "A Kiss in the Dreamhouse"

test "ListQueue playlist more dequeue":
    let q = ListQueue()
    let first = fill_playlist(q)
    assert first.title == "Cascade"
    assert first.artist == "Siouxsie and the Banshees"
    assert first.album == "A Kiss in the Dreamhouse"
    let second = q.dequeue()
    assert second.title == "Map of the Problematique"  

test "ListQueue playlist input: Non empty queue":
    let q = ListQueue()
    q.enqueue(song('s','s','s'))
    assert_error fill_playlist(q),'non-empty queue'

test "empty? ":
    let q = ListQueue()
    assert q.empty?() == True 

test "empty? False":
    let q = ListQueue()
    let first = fill_playlist(q)
    assert q.empty?() == False       

test "empty? True":
    let q = ListQueue()
    let first = fill_playlist(q)
    q.dequeue()
    q.dequeue()
    q.dequeue()
    q.dequeue()
    assert q.empty?() == True
        
test "ListQueue playlist enqueue":
    let q = ListQueue()
    let first = fill_playlist(q)
    q.enqueue(song('new','new','new'))
    
test "ListQueue playlist enqueue then dequeue":
    let q = ListQueue()
    let first = fill_playlist(q)
    q.enqueue(song('new','new','new'))
    q.dequeue()
    q.dequeue()
    q.dequeue()
    q.dequeue()
    assert q.dequeue().title == 'new'
    
                
test "dequeue to empty queue":
    let q = ListQueue()
    let first = fill_playlist(q)
    assert first.title == "Cascade"
    q.dequeue()
    q.dequeue()
    q.dequeue()
    q.dequeue()
    assert_error q.dequeue()        
    
# To construct a RingBuffer: RingBuffer(capacity)
test "RingBuffer playlist":
    let q = RingBuffer(8)
    let first = fill_playlist(q)
    assert first.title == "Cascade"
    let second = q.dequeue()
    assert second.title == "Map of the Problematique"

test "RingBuffer playlist capability":
    let q = RingBuffer(2)
    assert_error fill_playlist(q)
    
test "RingBuffer + queue":
    let q = RingBuffer(8)
    let first = fill_playlist(q)
    let second = q.dequeue()
    assert second.title == "Map of the Problematique"

    
test "RingBuffer + queue: function ":
    let q = RingBuffer(8)
    let first = fill_playlist(q)
    q.dequeue()
    q.dequeue()
    q.dequeue()
    q.dequeue()
    assert_error q.dequeue()