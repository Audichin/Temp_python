"""
Unit test module for anewalphabet
"""
from anewalphabet import ascii_change, lowercase, print_string, new_dict

def test_ascii_change_1() -> None:
    """test if the ascii_change function works correctly.
    """
    text = "abc"
    result = ascii_change("abc", new_dict, 0)
    expected = "@"
    assert result == expected

def test_ascii_change_2() -> None:
    """test if the ascii_change function works correctly.
    """
    text = "ian"
    result = ascii_change('ian', new_dict, 0)
    expected = "|"
    print(f'got = {result}, expected = {expected}')
    assert result == expected


def test_lowercase() -> None:
    """test if the lowercase function works correctly.
    """
    text = "Hello World!"
    result = lowercase(text)
    expected = "hello world!"
    assert result == expected

def test_new_dict() -> None:
    """test if the new_dict mapping is correct.
    """
    assert new_dict["a"] == "@"
    assert new_dict["z"] == "2"
    assert new_dict["t"] == "']['"
    assert new_dict["i"] == "|"