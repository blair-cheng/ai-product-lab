#lang dssl2
let eight_principles = ["Know your rights.",
                        "Acknowledge your sources.",
                        "Protect your work.",
                        "Avoid suspicion.",
                        "Do your own work.",
                        "Never falsify a record or permit another person to do so.",
                        "Never fabricate data, citations, or experimental results.",
                        "Always tell the truth when discussing your work with your instructor."]

# HW3: Dictionaries

import sbox_hash

# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    # Notation: `key` is the name of the parameter. `K` is its contract.
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following method allows dictionaries to be printed
    def __print__(self, print)

struct _pair:
    let key
    let value
    let next: OrC(_pair?, NoneC)
    
class AssociationList[K, V] (DICT):
    let _head 
    let _size

    def __init__(self):
        self._head = None
        self._size = 0
        
    def len(self)->nat?:
        return self._size
    
    def mem?(self,key:K) -> bool?:
        return self._find_item(key) is not False

        
    def get(self, key: K) -> V:
        let node = self._find_item(key)
        if _pair?(node):
            return node.value
        error("key not found")
        
    def put(self, key: K, value: V) -> NoneC:
        let new_pair = _pair(key, value, None)
        if self.mem?(key):
            let target = self._find_item(key)
            target.value = value
        else:
            self._size = self._size + 1
            if self._head is None:
                self._head = new_pair
            else:
                let pre = self._find_last()
                pre.next = new_pair

                
                    
    def del(self, key: K) -> NoneC:
        if not self.mem?(key) or self._head is None:
            return
        if key == self._head.key:
            self._head = self._head.next
            self._size = self._size - 1
        else:
            let pre = self._find_pre_item(key)
            if pre is not False and pre.next is not None:
                pre.next = pre.next.next
                self._size = self._size - 1


    # See above.
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)

    # Other methods you may need can go here.
    def _find_item(self, key:K) -> OrC(_pair?,False):
        let node = self._head
        while node is not None:
            if node.key == key:
                return node
            node = node.next
        return False
        
    def _find_pre_item(self, key:K) -> OrC(_pair?,False):
        let node = self._head
        while node is not None and node.next is not None:
            if node.next.key == key:
                return node
            node = node.next
        return False    
        
    def _find_last(self) -> OrC(_pair?,False):
        if self._head is None:
            return False
        else:
            let target = self._head
            while target.next is not None:
                target = target.next
            return target

test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert not a.mem?('hello')
    a.put('hello', 5)
    assert a.len() == 1
    assert a.mem?('hello')
    assert a.get('hello') == 5
    
test 'AssociationList del 1':
    let a = AssociationList()
    a.put('hello', 5)
    a.del('hello')
    assert a.len() == 0
    assert a.mem?('hello')==False
    assert_error a.get('hello') == 5
    
test 'AssociationList del to empty':
    let a = AssociationList()
    a.put('hello', 5)
    a.put('h3ello', 5)
    a.put('h1ello', 5)
    assert a.len() == 3
    a.del('h1ello')
    assert a.len() == 2
    a.del('hello')
    a.del('h3ello')
    a.del('h3ello')
    assert a.len() == 0    
    assert not a.mem?('hello')
    assert_error a.get('hello') == 5, "key not found"
    
test 'AssociationList same key put ':
    let a = AssociationList()
    a.put('hello', 5)
    a.put('hello', 5)
    assert a.len() == 1
    a.put('hello1', 5)
    assert a.len() == 2
    
test 'AssociationList empty put ':
    let a = AssociationList()
    a.put('','')
    assert a.len() == 1
    a.put('','')
    a.len() == 2
    
test 'AssociationList get last':
    let a = AssociationList()
    a.put('hello', 5)
    a.put('h3ello', 4)
    a.put('h1ello', 3)
    assert a.get('h1ello')==3
    assert a.get('h3ello')==4
    assert a.get('hello')==5

            
struct _item:
    let key
    let value
    let next: OrC(_item?, NoneC)    
    
class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data
    let _nbuckets

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        self._size = 0
        self._data = [None; max(1, nbuckets)]
        self._nbuckets = nbuckets
        
    def len(self) ->nat?:
        return self._size
        
    def mem?(self, key:K) ->bool?:
        let item = self._find_item(key)
        return _item?(item) 

    def put(self, key:K, value:V)-> NoneC:
        let node = self._find_item(key)
        if _item?(node):
            node.value = value
        else:
            let bucket_index  = self._bucket_index(key)
            let item = _item(key, value, self._data[bucket_index])
            self._data[bucket_index] = item
            self._size = self._size + 1
                    
                
    def get(self, key:K)->V:
        let item = self._find_item(key)
        if _item?(item):
            return item.value
        error('hashtable.get: key not found')
                    
    def del(self,key:K) -> NoneC:
        if not self.mem?(key):
            return
        let index = self._bucket_index(key)
        let head = self._data[index]
        if head.key ==key:
            self._data[index] = head.next
            self._size = self._size -1
        let node = head
        while node.next is not None:
            if node.next.key == key:
                node.next = node.next.next
                self._size = self._size - 1
                return
            node = node.next
                
    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)

    # Other methods you may need can go here.
    def _bucket_index(self, key:K)->nat?:
        return self._hash(key) % self._nbuckets
        
    def _find_item(self, key:K)->OrC(_item?,False):
        let start = self._bucket_index(key)
        let node = self._data[start]
        while node is not None:
            if key == node.key:
                return node
            else: 
                node = node.next
        return False        
        
# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')
    assert h.get('hello') == 5
    
test 'HashTable, get':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')== True
    assert h.get('hello') == 5    
    assert_error h.get('hello1')  , 'hashtable.get: key not found'
    assert_error h.get('hello1') == 5 ,'hashtable.get: key not found'
    
test 'HashTable, put':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    h.put('hello', 5)
    assert h.len() == 1
    assert h.get('hello') == 5
    h.put('hello', 6)
    assert h.len() == 1
    assert h.get('hello') == 6
    h.put('', 5)
    assert h.len() == 2
    h.put('', 6)
    assert h.len() == 2    

test 'HashTable, del':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    h.put('hell', 4)
    assert h.len() == 2
    h.del('hello')
    assert h.len() ==1
    assert h.get('hell') == 4
    h.del('hello')    
    assert h.len() ==1
    assert h.get('hell') == 4    
    h.del('hell')    
    assert h.len() ==0
    h.del('hell')       
    assert h.len() ==0
    


test 'first_char_hasher, put':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    h.put('hello', 5)
    h.put('hell', 5)
    assert h.len() == 2
    h.put('hel', 5)
    assert h.len() == 3
    h.put('he', 5)
    assert h.len() == 4
    h.put('h', 5)
    assert h.len() == 5
    h.put('', 5)
    assert h.len() == 6
    h.put('', 6)
    assert h.len() == 6    
    
   
test 'first_char_hasher, 1 bucket put':
    let h = HashTable(1,first_char_hasher)
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    h.put('hello', 5)
    h.put('hell', 5)
    assert h.len() == 2
    h.put('hel', 5)
    assert h.len() == 3
    h.put('he', 111)
    assert h.len() == 4
    h.put('h', 5)
    assert h.len() == 5
    h.put('', 5)
    assert h.len() == 6
    h.put('', 6)
    assert h.len() == 6    
    assert h.get('') == 6
    assert h.get('he') == 111
   
test 'first_char_hasher, 1 bucket put':
    let h = HashTable(1,first_char_hasher)
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    h.put('hello', 5)
    h.put('hell', 5)
    assert h.len() == 2
    h.put('hel', 5)
    assert h.len() == 3
    h.put('he', 5)
    assert h.len() == 4
    h.put('h', 5)
    assert h.len() == 5
    h.put('', 5)
    assert h.len() == 6
    h.put('', 6)
    assert h.len() == 6    
        
test 'first_char_hasher, same key put':
    let h = HashTable(1,first_char_hasher)
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    h.put('hello', 6)
    h.put('hell', 5)
    assert h.len() == 2
    assert h.get('hello') == 6

test 'first_char_hasher,del':
    let h = HashTable(10,first_char_hasher)
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    h.put('hell', 4)
    assert h.len() == 2
    h.del('hello')
    assert h.len() ==1
    assert h.get('hell') == 4

    
def compose_phrasebook(d: DICT!) -> DICT?:
    d.put('obrodošli',     'Welcome, Doh-broh-doh-shlee')
    d.put('Zbogom',        'Goodbye, Zh-boh-guhm')
    d.put('Živjeli!',      'Cheers!, Jee-vyelee')
    d.put('Razumiješ?',    'Do you understand?, Rah-zuu-miaysh')
    d.put('Ozdravi brzo',  'Get well soon, Ohz-drah-vee breh-zoh')
    return d

test "AssociationList phrasebook":
    let a = AssociationList()
    let c = compose_phrasebook(a)
    assert c.mem?('obrodošli')    
    c.get('obrodošli')
    c.put('obrodošli',     'Welcome, wala')   
    c.get('obrodošli')
    assert c.len()==5
    c.get('Zbogom')
    c.del('Zbogom')
    assert c.mem?('Zbogom')==False


test "HashTable phrasebook":
    let h = HashTable(10, make_sbox_hash())
    let a = compose_phrasebook(h)
    assert a.mem?('obrodošli')   
    a.get('obrodošli')
    a.put('obrodošli','Welcome, wala')   
    a.get('obrodošli')
    assert a.len()== 5   
    a.del('obrodošli')
    assert a.len()== 4
    assert_error a.get('obrodošli')

    
test "HashTable phrasebook collission":
    let h = HashTable(1, first_char_hasher)
    let a = compose_phrasebook(h)
    assert a.mem?('obrodošli')   
    a.get('obrodošli')
    a.put('ob',     'Welcome, wala')   
    a.get('obrodošli')
    assert a.len()== 6   
    a.del('obrodošli')
    assert a.len()== 5    
    assert_error a.get('obrodošli')   ==  'Welcome, Doh-broh-doh-shlee'  
    
    
test "HashTable phrasebook 1 bucket":
    let h = HashTable(1, first_char_hasher)
    let a = compose_phrasebook(h)
    assert a.mem?('obrodošli')   
    a.get('obrodošli')
    a.put('ob', 'Welcome, wala')   
    a.get('obrodošli')
    assert a.len()== 6   
    a.del('obrodošli')
    assert a.len()== 5    
    assert a.get('ob') ==  'Welcome, wala'
    compose_phrasebook(h)
    assert a.len()== 6    
    assert a.get('obrodošli') == 'Welcome, Doh-broh-doh-shlee'
    assert a.get('ob') ==  'Welcome, wala'

    
    
