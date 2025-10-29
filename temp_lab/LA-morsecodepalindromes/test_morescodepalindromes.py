"""
    Module to test functions in morsecodepalindromes.py 
"""

import morsecodepalindromes


def test_convert_to_morse() -> None:
    """
        Tests convert_to_morse function.
    """
    actual_ans = morsecodepalindromes.convert_to_morse('AN')
    expected_ans = '.--.'
    assert actual_ans == expected_ans

# FIXED6 - write 3 more test funbctions with different cases to test convert_to_morse function
def test_convert_to_morse2() -> None:
    """
        Tests convert_to_morse function.
    """
    actual_ans = morsecodepalindromes.convert_to_morse('SOS')
    expected_ans = '...---...'
    assert actual_ans == expected_ans

def test_convert_to_morse3() -> None:
    """
        Tests convert_to_morse function.
    """
    actual_ans = morsecodepalindromes.convert_to_morse('GMRS')
    expected_ans = '--......-.-....'
    assert actual_ans == expected_ans

def test_convert_to_morse4() -> None:
    """
        Tests convert_to_morse function.
    """
    actual_ans = morsecodepalindromes.convert_to_morse('135')
    expected_ans = '.----...--.....'
    assert actual_ans == expected_ans

def test_ispalindrome1() -> None:
    """
        Tests is_palindrome function.
    """
    ans = morsecodepalindromes.is_palindrome('.--.')
    expected = 1
    assert ans == expected

# FIXED 7 - Write 3 more test functions with different cases to test is_palindrome function
def test_ispalindrome2() -> None:
    """
        Tests is_palindrome function.
    """
    ans = morsecodepalindromes.is_palindrome('...---...')
    expected = 1
    assert ans == expected
def test_ispalindrome3() -> None:
    """
        Tests is_palindrome function.
    """
    ans = morsecodepalindromes.is_palindrome('--......-.-....')
    expected = 0
    assert ans == expected
def test_ispalindrome4() -> None:
    """
        Tests is_palindrome function.
    """
    ans = morsecodepalindromes.is_palindrome('.----...--.....')
    expected = 0
    assert ans == expected