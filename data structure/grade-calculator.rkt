#lang dssl2
let eight_principles = ["Know your rights.",
                        "Acknowledge your sources.",
                        "Protect your work.",
                        "Avoid suspicion.",
                        "Do your own work.",
                        "Never falsify a record or permit another person to do so.",
                        "Never fabricate data, citations, or experimental results.",
                        "Always tell the truth when discussing your work with your instructor."]
# HW1: Grade Calculator

###
### Data Definitions
###

let outcome? = OrC("got it", "almost there", "on the way", "not yet",
                   "missing honor code", "cannot assess")

struct homework:
    let outcome: outcome?
    let self_eval_score: nat?

struct project:
    let outcome: outcome?
    let docs_modifier: int?

let letter_grades = ["F", "D", "C-", "C", "C+", "B-", "B", "B+", "A-", "A"]
def letter_grade? (str):
    let found? = False
    for g in letter_grades:
        if g == str: found? = True
    return found?


###
### Modifiers
###

def worksheets_modifier (worksheet_percentages: VecKC[num?, num?]) -> int?:
  let a = worksheet_percentages[0]
  let b = worksheet_percentages[1]
  if a == 1.0 and b == 1.0:
    return  1
  elif a < 0.8 or b < 0.8:
    return  -1
  else:
      return  0

def exams_modifiers (exam1: nat?, exam2: nat?) -> int?:
  def score_mapper(score: nat?) -> int?:
    assert 0 <=score and score <= 20
    if score >=18:
      return  1
    elif score >= 13:
      return  0
    elif score >=10:
      return  -1
    elif score >=8:
      return  -2
    elif score >=6:
      return -3
    elif score >=4:
      return -4
    else: 
      return -5
  let score1 = score_mapper(exam1)
  let score2 = score_mapper(exam2)
  let total = score1 + score2

  if (score2- score1) >= 2:
    total = total +  1
  return total

def self_evals_modifier(hws: VecC[homework?]) -> int?:
    let count_5 = 0
    let count_low = 0
    let count_mid = 0

    if len(hws) != 5:
        error("invalid hw amounts: expected 5, get " + len(hws))

    for hw in hws:
        let score = hw.self_eval_score
        if score > 5:
            error("invalid self-eval score: " + str(score))
        if score == 5:
            count_5 = count_5 + 1
        elif score <= 2:
            count_low = count_low + 1
        else:
            count_mid = count_mid + 1

    if count_5 >= 4 and count_low <= 1:
        return 1
    elif count_low >= 3:
        return -1
    elif count_5 == 3 and count_low <= 2:
        return 0
    elif count_mid >= 3:
        return 0
    else:
        return 0

###
### Letter Grade Helpers
###

# Is outcome x enough to count as outcome y?
def is_at_least (x:outcome?, y:outcome?) -> bool?:
    if x == "got it": return True
    if x == "almost there" \
        and (y == "almost there" or y == "on the way" or y == "not yet"):
        return True
    if x == "on the way" and (y == "on the way" or y == "not yet"): return True
    return False

def apply_modifiers (base_grade: letter_grade?, total_modifiers: int?) -> letter_grade?:
    let n = len( letter_grades)
    if base_grade =="F":
        return "F"
    let index = -1
    for i in range(n):
        if base_grade == letter_grades[i]:
            index = i 
            break
    let final_index = index + total_modifiers 
    if final_index >= n:
        final_index = n-1
    elif final_index < 0:
        final_index = 0
    return letter_grades[final_index]




###
### Students
###

class Student:
    let name: str?
    let homeworks: VecKC[homework?, homework?, homework?, homework?, homework?]
    let project: project?
    let worksheet_percentages: VecKC[num?, num?]
    let exam_scores: VecKC[nat?, nat?]

    def __init__ (self, name, homeworks, project, worksheet_percentages, exam_scores):
        self.name = name 
        self.homeworks =homeworks
        self.project = project
        self.worksheet_percentages = worksheet_percentages
        self.exam_scores = exam_scores


    def get_homework_outcomes(self) -> VecC[outcome?]:
        let a = self.homeworks[0].outcome
        let b = self.homeworks[1].outcome
        let c = self.homeworks[2].outcome
        let d = self.homeworks[3].outcome
        let e = self.homeworks[4].outcome
        return [a, b, c, d, e] 


    def get_project_outcome(self) -> outcome?:
        let outcome = self.project.outcome
        return outcome

    def set_homework(self, n:nat?, hw: homework?) ->NoneC:
        self.homeworks[n] = hw

    def resubmit_homework(self, n:nat?, new_outcome: outcome?) -> NoneC:
        if n <= 0 or n > 5:
            error("Resubmit Homework" + (n+1) +" is out of index")
        n = n - 1

        self.set_homework(n, homework(new_outcome, self.homeworks[n].self_eval_score))
      
    def resubmit_project (self, new_outcome: outcome?) -> NoneC:
        assert self.project is not None
        self.project = project(new_outcome, self.project.docs_modifier)


    def base_grade (self) -> letter_grade?:
        let n_got_its       = 0
        let n_almost_theres = 0
        let n_on_the_ways   = 0
        for o in self.get_homework_outcomes():
            if is_at_least(o, "got it"):
                n_got_its       = n_got_its       + 1
            if is_at_least(o, "almost there"):
                n_almost_theres = n_almost_theres + 1
            if is_at_least(o, "on the way"):
                n_on_the_ways   = n_on_the_ways   + 1
        let project_outcome = self.get_project_outcome()
        if n_got_its == 5  and project_outcome == "got it": return "A-"
        # the 4 "almost there"s or better include the 3 "got it"s
        if n_got_its >= 3  and n_almost_theres >= 4 and n_on_the_ways >= 5 \
           and is_at_least(project_outcome, "almost there"):
            return "B"
        if n_got_its >= 2  and n_almost_theres >= 3 and n_on_the_ways >= 4 \
           and is_at_least(project_outcome, "on the way"):
            return "C+"
        if n_got_its >= 1  and n_almost_theres >= 2 and n_on_the_ways >= 3 \
           and is_at_least(project_outcome, "on the way"):
            return "D"
        return "F"

    def project_above_expectations_modifier (self) -> int?:
        let base_grade = self.base_grade()
        if base_grade == 'A-': return 0 # expectations are already "got it"
        if base_grade == 'B':
            if is_at_least(self.project.outcome, 'got it'):       return 1
            else: return 0
        else:
            # two steps ahead of expectations
            if is_at_least(self.project.outcome, 'got it'):       return 2
            # one step ahead of expectations
            if is_at_least(self.project.outcome, 'almost there'): return 1
            else: return 0

    def total_modifiers (self) -> int?:
        let worksheet_mod = worksheets_modifier(self.worksheet_percentages)
        let exams_mod = exams_modifiers(self.exam_scores[0], self.exam_scores[1])
        let project_mod = self.project.docs_modifier
        let project_above_mod = self.project_above_expectations_modifier()
        let evals_mod = self_evals_modifier(self.homeworks)
        return  worksheet_mod +exams_mod +  project_above_mod +  project_mod + evals_mod

    def letter_grade (self) -> letter_grade?:
        let b = self.base_grade()
        let m = self.total_modifiers()
        return apply_modifiers(b, m)
### 
### Struct List 
###
struct cons:
  let data
  let next

### 
### Class
###
class SSL:
  let head
  def __init__(self):
    self.head = None

  def _find_nth_node(self,n):
    let curr = self.head
    while not curr == None:
      if n == 0:
        return curr
      n    = n - 1
      curr = curr.next
    error('list too short')
  def get_nth(self, n):
    return self._find_nth_node(n).data
  def set_nth(self, n, val):
    self._find_nth_node(n).data = val

  def len(self) ->nat?:
    let curr = self.head
    let length = 0
    while not curr == None:
      curr = curr.next
      length = length + 1
    return length
###
### Feeble attempt at a test suite
### See advice in the handout
###

test 'Student#letter_grade, worst case scenario':
    let s = Student('Everyone, at the start of the class',
                    [homework("not yet", 0),
                     homework("not yet", 0),
                     homework("not yet", 0),
                     homework("not yet", 0),
                     homework("not yet", 0)],
                    project("not yet", -1),
                    [0.0, 0.0],
                    [0, 0])
    assert s.base_grade() == 'F'
    assert s.total_modifiers() == -13
    assert s.letter_grade() == 'F'

test 'Student#letter_grade, best case scenario':
    let s = Student("You, if you're willing to work hard",
                    [homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5)],
                    project("got it", 1),
                    [1.0, 1.0],
                    [20, 20])
    assert s.base_grade() == 'A-'
    assert s.total_modifiers() == 5
    assert s.letter_grade() == 'A'
    
    
### Basic Modifiers: worksheets_modifier, exams_modifier

test 'worksheets_modifier: edge cases':
  assert worksheets_modifier([0.8, 1]) == 0
  assert worksheets_modifier([0.8, 0.8]) == 0
  assert worksheets_modifier([0.81, 1.0]) == 0
  assert worksheets_modifier([1.0, 0.79]) == -1
  assert worksheets_modifier([1.0, 1.0]) == 1

test 'exams_modifier: edge cases':
  assert exams_modifiers(20, 20) == 2
  assert exams_modifiers(18, 18) == 2
  assert exams_modifiers(18, 17) == 1
  assert exams_modifiers(18, 10) == 0
  assert exams_modifiers(10, 18) == 1
  assert exams_modifiers(18, 1) == -4
  assert exams_modifiers(1, 18) == -3
  assert exams_modifiers(9, 10) == -3
  assert exams_modifiers(9, 0) == -7
  assert exams_modifiers(0, 9) == -6


### Advanced Modifiers: self_evals_modifier, total_modifiers

test 'self_evals_modifier: valid and invalid score mix':
  assert self_evals_modifier([
    homework("got it", 5),
    homework("got it", 0),
    homework("got it", 5),
    homework("got it", 1),
    homework("got it", 5)
  ]) == 0


  assert self_evals_modifier([
    homework("got it", 3),
    homework("got it", 2),
    homework("got it", 2),
    homework("got it", 1),
    homework("got it", 5)
  ]) == -1
  
  assert self_evals_modifier([
    homework("got it", 5),
    homework("got it", 5),
    homework("got it", 5),
    homework("got it", 1),
    homework("got it", 5)
  ]) == 1

test 'Student#total_modifiers: all zero':
  let s = Student("zero",
                    [homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5)],
                  project("got it", -1),
                  [0.8, 0.8],
                  [13, 13])
  assert s.total_modifiers() == 0
  assert s.base_grade() == 'A-'
  assert s.letter_grade() == 'A-'

test 'Student#total_modifiers: extreme negative':
  let s = Student("negative",
                  [homework("on the way", 5),
                   homework("on the way", 5),
                   homework("not yet", 5),
                   homework("not yet", 5),
                   homework("not yet", 5)],
                  project("not yet", 0),
                  [1.0, 1.0],
                  [19, 20])
  assert s.total_modifiers() == 4
  assert s.base_grade() == 'F'
  assert s.letter_grade() == 'F'

test 'Student#total_modifiers: mixed case':
  let s = Student("mixed",
                  [homework("almost there", 5),
                   homework("on the way", 5),
                   homework("not yet", 5),
                   homework("not yet", 5),
                   homework("got it", 5)],
                  project("got it", 1),
                  [1.0, 1.0],
                  [19, 20])
  assert s.total_modifiers() == 7
  assert s.base_grade() == 'D'
  assert s.letter_grade() == 'A-'


### Basic Grades: Student class methods

test 'Student#get_homework_outcomes and get_project_outcome':
  let s = Student("t",
                  [homework("got it", 1),
                   homework("almost there", 2),
                   homework("on the way", 3),
                   homework("not yet", 4),
                   homework("cannot assess", 5)],
                  project("got it", 0),
                  [1.0, 1.0], [20, 20])
  assert s.get_homework_outcomes() == ["got it", "almost there", "on the way", "not yet", "cannot assess"]
  assert s.get_project_outcome() == "got it"



test 'Student#resubmit_homework updates outcome':
  let s = Student("t",
                  [homework("not yet", 3),
                  homework("got it", 3),
                  homework("got it", 3),
                  homework("got it", 3),
                  homework("got it", 3)],                  
                  project("got it", 0),
                  [1.0, 1.0], [20, 20])

  s.resubmit_homework(1, "almost there")
  assert s.get_homework_outcomes() == ["almost there","got it","got it","got it","got it"]
  s.resubmit_homework(2, "almost there")
  assert s.get_homework_outcomes() == ["almost there","almost there","got it","got it","got it"]
  s.resubmit_homework(3, "almost there")
  assert s.get_homework_outcomes() == ["almost there","almost there","almost there","got it","got it"]
  s.resubmit_homework(4, "almost there")
  assert s.get_homework_outcomes() == ["almost there","almost there","almost there","almost there","got it"]
  s.resubmit_homework(5, "almost there")
  assert s.get_homework_outcomes() == ["almost there","almost there","almost there","almost there","almost there"]


test 'Student#resubmit_project updates outcome':
  let s = Student("t",
                    [homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5)],
                  project("on the way", 0),
                  [1.0, 1.0], [20, 20])
  s.resubmit_project("got it")
  assert s.get_project_outcome() == "got it"


### Advanced Grades: apply_modifiers

test 'apply_modifiers: typical shifts':
  assert apply_modifiers("C", 1) == "C+"
  assert apply_modifiers("B", -1) == "B-"
  assert apply_modifiers("C", 2) == "B-"
  assert apply_modifiers("B", -2) == "C+"

test 'apply_modifiers: clamping cases':
  assert apply_modifiers("A", 3) == "A"
  assert apply_modifiers("F", -3) == "F"
  assert apply_modifiers("F", 6) == "F"

test 'apply_modifiers: zero shift':
  assert apply_modifiers("B+", 0) == "B+"

test 'score-strategy: all cases':
  let best = Student("strategy-best",
    [homework("got it", 3),
     homework("got it", 3),
     homework("got it", 5),
     homework("got it", 5),
     homework("got it", 5)],
    project("got it", 1),
    [1, 1],
    [8, 11])
  assert best.base_grade() == 'A-'
  assert best.total_modifiers() == -1
  assert best.letter_grade() == 'B+'

  let normal = Student("strategy-normal",
    [homework("on the way", 3),
     homework("almost there", 4),
     homework("almost there", 4),
     homework("got it", 5),
     homework("got it", 5)],
    project("got it", 1),
    [0.9, 0.9],
    [13, 15])
  assert normal.base_grade() == 'C+'
  assert normal.total_modifiers() == 3
  assert normal.letter_grade() == 'B+'

  let worst = Student("strategy-worst",
    [homework("on the way", 2),
     homework("almost there", 3),
     homework("almost there", 4),
     homework("got it", 4),
     homework("got it", 4)],
    project("almost there", 1),
    [0.8, 0.85],
    [13, 13])
  assert worst.base_grade() == 'C+'
  assert worst.total_modifiers() == 2
  assert worst.letter_grade() == 'B'
  