# multiline output control

# use blessings instead of curses as it truely is a blessing

from blessings import Terminal
import time
from lonpos import *


def report_progress(filename, progress):
    """progress: 0-10"""
    print(term.clear())
    print("I am", term.bold("bold"), "text")
    print(term.red_on_green('Red on green? Ick!'))
    print(term.yellow('I can barely see it.'))
    print("Moving file  🚫: {0}".format(filename))
    print("Total progress: [{1:10}] {0}%".format(progress * 10, "#" * progress))


if __name__ == "__main__":
    term = Terminal()

    for i in range(10):
        report_progress("file_{0}.txt".format(i), i+1)
        time.sleep(0.2)
    print(term.move(5,0))
