"""
Dictionary and Unittest Lab - A
Updated By: Ian Mooney
CSCI 110 Lab
Date: 10/28/25

Kattis problem - Morse Code Palindromes - https://open.kattis.com/problems/morsecodepalindromes  

Given english text, the program finds if the corresponding morse code is a palindrome.

Algorithm steps:
1. Create a dictionary to map alphabets and numbers to morse code 
2. Read the input english string
3. Convert the string into upper case english string
4. Convert english string into Morse Code string using the dictionary
5. Check if the Morse Code string is a palindrome
    i. Print 1 if it's a palindrome
    ii Otherwise, print 0
"""
import sys

# Create English to Morse Code dictionary mapping
ENG_TO_MORSE = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',

    # FIXED1: map the number digits to their corresponding morse code
    '0': '-----',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
}


def is_palindrome(morse_code: str) -> int:
    """Returns 1 if the morse_code string is palindrome; 0 Otherwise.

    Args:
        morse_code (str): morse code palindrome string

    Returns:
        int: 1 or 0
    """
    # FIXED2: if the morse_code string is empty, return 0
    # Otherwise use the algorithm:
    # 1. reverse the morse_code string and store into a variable
    # 2. if the morse_code equals to the reversed string, it is a palindrome and return 1
    # 3. return 0 otherwise
    new_code = []
    if morse_code == "":
        return 0
    elif morse_code != "":
        for char in morse_code:
            # new_code.append(morse_code[len(morse_code)-1])
            # morse_code = morse_code[:-1]
            new_code = morse_code[-1::-1]
            # print(f'new_code = {new_code}', file=sys.stderr)
            # print(f'morse_code = {morse_code}', file=sys.stderr)
    if morse_code == new_code:
        return 1
    else:
        return 0


def convert_to_morse(english: str) -> str:
    """The function converts the given english text into corresponding morese code

    Args:
        english (str): eglish text convereted into upper case

    Returns:
        str: Morse code
    """
    morse_code = ''
    # Algorithm steps:
    # For each character in english,
    #   find the morse code of the character using ENG_TO_MORSE dictionary
    #   concatenate morse code to morse_code variable if key exists
    #   ignore the key/character if it doesn't exist in the dictionary
    # FIXED3: implement the above algorithm
    for c in english:
        if c in ENG_TO_MORSE:
            morse_code += ENG_TO_MORSE.get(c)
    return morse_code


def solve() -> None:
    """Main entry function that solves the problem.
    """
    # read/input english text as a line
    english = input()
    # FIXED4: convert english text into uppercase
    upper_english = english.upper()
    print(upper_english, file=sys.stderr)
    morse_code = convert_to_morse(upper_english)
    # FIXED5: call is_palindrome passing proper argument and print the result
    print(is_palindrome(morse_code))


if __name__ == '__main__':
    solve()