# d7320

# Print functions
import blessings


def init() -> blessings.Terminal:
    """Initialize the terminal"""
    return blessings.Terminal()



def to_emoji(n: int, space=True) -> str:
    """Convert from number to emoji"""
    #             [red, cyan, orange, lime, white, yellow, blue, purple, pink, green, gray, salmon]
    emojis = ["⬛", "🟥", "🔵", "🟧", "🟩", "⬜", "🟨", "🟦", "🟣", "🟫", "🟢", "⚪", "🟠", "🚫", "🌾", "🎲"]
    # emojis = ['\U00002B1B', '\U0001F7E5', '\U0001F535', '\U0001F7E7', '\U0001F7E9', '\U00002B1C', '\U0001F7E8',
    # '\U0001F7E6', '\U0001F7E3', '\U0001F7EB', '\U0001F7E2', '\U000026AA', '\U0001F7E0']
    if space:
        emojis[0] = "  "
    return emojis[n]


def print_board(board: np.ndarray, placement: int) -> None:
    """Print the board to the special screen"""
    try:
        buffs = []
        for line in board:
            buff = ""
            for ball in line:
                buff += to_emoji(int(ball))
            buffs.append(buff)
    except:
        print(board)
        a = input("ummm")

    # Flush the board
    print(term.move(placement, 0))
    [print(i) for i in buffs]
    # print("➖" * 9)


def print_remaining(pieces: list) -> None:
    """Print the remaining pieces to play"""

    # Assume every piece is 4x4 at max
    buffs = []
    for r in range(4):
        buff = ""
        for p in pieces:
            if len(p[0]) > r:
                buff += "".join([to_emoji(int(i), space=True) for i in p[0][r]] + ["  "] * (4 - len(p[0][r])))
            else:
                buff += "".join(["  "] * 4)
            buff += " "
        buffs.append(buff)

    print(term.move(28, 0))
    print(term.move(28, 0))
    [print(term.clear_eol, i) for i in buffs]


def print_place(possible: bool) -> None:
    """Print the placement stats"""
    global total_placements
    global successful_placements
    global tic
    total_placements += 1
    successful_placements += possible
    print(term.move(2, 0))
    print(term.bold("{:,}".format(successful_placements)), "successful placements out of",
          term.bold("{:,}".format(total_placements)), "total placements with",
          term.bold("{:,}".format(dead_ends)), "dead ends")
    print("Running time of", term.bold("{:.2f} mins".format((time() - tic) / 60)))
