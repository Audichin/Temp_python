"""
    Unit test module for cups
"""

from cups import sort_cups


def test_sort_cups_1() -> None:
    """test if the cups are sorted correclty.
    """
    cups = {100: 'red', 10: 'blue', 50: 'yellow'}
    sorted_cups = sort_cups(cups)
    expected = ['blue', 'yellow', 'red']
    assert sorted_cups == expected


# FIXME6 : add a unit test function
def test_sort_cups_2() -> None:
    """test if the cups are sorted correclty.
    """
    cups = {30: 'green', 20: 'white', 40: 'black'}
    sorted_cups = sort_cups(cups)
    expected = ['white', 'green', 'black']
    assert sorted_cups == expected

# FIXME7 : add a unit test function
def test_sort_cups_3() -> None:
    """test if the cups are sorted correclty.
    """
    cups = {5: 'pink', 15: 'orange', 10: 'purple'}
    sorted_cups = sort_cups(cups)
    expected = ['pink', 'purple', 'orange']
    assert sorted_cups == expected
# FIXME8 : add a unit test function
def test_sort_cups_4() -> None:
    """test if the cups are sorted correclty.
    """
    cups = {25: 'cyan', 5: 'magenta', 15: 'lime'}
    sorted_cups = sort_cups(cups)
    expected = ['magenta', 'lime', 'cyan']
    assert sorted_cups == expected
# FIXME9 : add a unit test function
def test_sort_cups_5() -> None:
    """test if the cups are sorted correclty.
    """
    cups = {12: 'teal', 8: 'navy', 20: 'maroon'}
    sorted_cups = sort_cups(cups)
    expected = ['navy', 'teal', 'maroon']
    assert sorted_cups == expected
# FIXME10 : add a unit test function
def test_sort_cups_6() -> None:
    """test if the cups are sorted correclty.
    """
    cups = {7: 'silver', 3: 'gold', 9: 'bronze'}
    sorted_cups = sort_cups(cups)
    expected = ['gold', 'silver', 'bronze']
    assert sorted_cups == expected