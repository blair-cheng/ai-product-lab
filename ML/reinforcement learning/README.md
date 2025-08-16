# CS349 HW 5: Reinforcement Learning and Fairness

There are 25 points possible for this assignment. 1 point is for the setup,
8 points for the code, and 16 points for the free-response questions. The setup
portion is due earlier than the other pieces -- all deadlines are on Canvas.
Please carefully read this entire README before starting the assignment.

## Changes from previous homeworks

- There is a new package in `requirements.txt`: `gymnasium`. Read [the
  documentation here](https://gymnasium.farama.org). You can install it into your
  existing `cs349` environment with `pip install gymnasium`.
- This assignment is due March 15. You may use at most two late days; because
  of the end of the quarter and our deadline for submitting grades, no additional
  extensions can be made except in truly exceptional circumstances.

## Academic integrity

Your work must be your own. You may not work with others. Do not submit other
people's work as your own, and do not allow others to submit your work as
theirs. 

You may *talk* with other students about the concepts covered by the homework,
but you may not share code or answers with others in any way.  If you do meet
with other students to discuss the assignments, **you may not work from notes
taken during collaborative sessions**. If you write anything while working
collaboratively, you must erase/destroy/archive that writing or any recording
thereof before coding or writing the solution that you turn in. You don't
literally have to burn papers or delete files, but you must pretend that those
papers or files do not exist for the purposes of writing your solution.
Collaborative sessions are for you to learn the material in whatever way is
best for you; coding or writing the solutions is an individual assessment of
your ability to convey your mastery of that knowledge.

If you discussed the homework with other students in any way (except via
Piazza), please disclose those collaborations in the [`CITATIONS`
file](CITATIONS). If any online resources may have influenced your approach to
solving these questions (e.g., you saw a helpful guide to the ID3 algorithm),
please link to them. If you used a large language model (e.g., ChatGPT) in any
way, please describe that use.

If you need help debugging your code, make a *private* post on Piazza or come
to office hours. You may not show your code (including pseudocode) to other
students under any circumstances.

We will use a combination of automated and manual methods for comparing your
code and free-response answers to that of other students. If we find
sufficiently suspicious similarities between your answers and those of another
student, you will both be reported for a suspected violation. If you're unsure
of the academic integrity policies, ask for help; we can help you avoid
breaking the rules, but we can't un-report a suspected violation.

You are required to completely understand any homework solution that you
submit, and, in case of any doubt, you must be prepared to orally explain your
solution. If you have submitted a solution that you cannot verbally explain,
then you have violated this policy.

By pushing your code to GitHub, you agree to these rules, and understand that
there may be severe consequences for violating them.

## Important instructions -- coding

Your coding work will be graded and aggregated using an autograder that will
download the code from each student's repository. If you don't follow the
instructions, you run the risk of getting *zero points*. The `test_setup` test
cases gives you points for following these instructions and will make it
possible to grade your work easily.

The essential instructions:
- Your Net ID must be in the `netid` file; replace `NETID_GOES_HERE` with your
  Net ID. It should look something like `xyz0123`.
- Your code must be *pushed* to GitHub for us to grade them!  We will only
  grade the latest version of your code that was pushed to GitHub before the
  deadline (accounting for late days; see below).
- Look at `tests/rubric.json` -- we **strongly** suggest you implement code to
  pass the tests in the order they appear in that file.

## Important instructions -- free-response

- You must upload your free-response answers to Canvas in PDF format.
- Your answer to each question must be in *its own PDF* with the filename
  `qYYY.pdf`, where `YYY` is the question number. So your answer to free
  response question 2 should be in a PDF file with the filename `q2.pdf`.
- Do not include your name or Net ID in the content of your free response PDFs
  -- we will grade these anonymously. We will deduct points if you submit a
  PDF containing your name or other identifying information.
  
## Late Work

In general, late work is not accepted. The autograder will only download work
from your repository that was pushed to GitHub before the deadline. However:

- Each student gets four late days to use across the entire quarter.
  If you want to use late days, edit the HW5 Late Days submission on Canvas.
- You can use at most two late days per deadline.
- Late days apply equally to coding and FRQ; if the assignment is due Monday
  and you use one late day, your deadline is now Tuesday for both portions.
- You cannot use late days for the setup portion of the assignment.
- If you have a personal emergency, please ask for help. You do not have to
  share any personal information with me, but I will ask you to get in touch
  with the dean who oversees your student services to coordinate
  accommodations.

## Environment setup

You need one additional package for this assignment. You can add that into your
existing `cs349` environment by activating it and then running `pip install
gymnasium`. 

## What to do for this assignment

The detailed instructions for the work you need to do are in `problems.md`.
You will also find it very helpful to read pages 32 and 131 of
[Reinforcement Learning](http://incompleteideas.net/book/RLbook2020.pdf).

For this assignment, you will:
- Learn how to interface with Gymnasium environments
- Implement two Reinforcement Learning algorithms
- Investigate the performance of your algorithms and the effects of various hyperparameters
- Explore questions about fairness in real-world and toy examples

You will also write up answers to the free response questions.

In every function where you need to write code, there is a `raise
NotImplementedError` in the code. The test cases will guide you through the work
you need to do and tell you how many points you've earned. The test cases can
be run from the root directory of this repository with:

``python -m pytest``

To run a single test, you can call e.g., `python -m pytest -s -k test_setup`.
The `-s` means that any print statements you include will in fact be printed;
the default behavior (`python -m pytest`) will suppress everything but the
pytest output.

We will use these test cases to grade your work! Even if you change the test
cases such that you pass the tests on your computer, we're still going to use
the original test cases to grade your assignment.

## Questions? Problems? Issues?

Simply post on Piazza, and we'll get back to you.
