import re


def test_setup():
    lines = []
    with open('netid', 'r') as inf:
        for line in inf.readlines():
            line = line.strip().lower()
            if len(line) > 0 and line != "netid_goes_here":
                lines.append(line)

    assert len(lines) == 1, "Please add your Net ID."

    netid = str(lines[0].strip())
    search = re.search(r"^[a-z]{3}[0-9]{3,4}$", netid)
    assert search is not None, "Your NetID looks like xyz0123."
