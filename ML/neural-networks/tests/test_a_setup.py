import re


def test_setup():
    '''
    HW3 does not require the GitHub password setup,
      but your autograder feedback will still be pushed to GitHub.
    '''

    with open('netid', 'r') as inf:
        lines = inf.readlines()

    assert len(lines) == 1, "Just a single line with your NetID"

    netid = str(lines[0].strip())
    assert netid != "NETID_GOES_HERE", "Add your NetID"
    assert re.search(r"^[a-z]{3}[0-9]{3,4}$", netid.lower()) is not None, "Your NetID looks like xyz0123"
