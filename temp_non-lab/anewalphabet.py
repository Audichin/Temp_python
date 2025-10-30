"""
Dictionary and Unittest Lab - A
Updated By: Ian Mooney
CSCI 110 Lab
Date: 10/28/25

Kattis problem - Morse Code Palindromes - https://open.kattis.com/problems/anewalphabet 

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

new_dict = {"a": "@",
            "b": "8",
            "c": "(",
            "d": "|)",
            "e": "3",
            "f": "#",
            "g": "6",
            "h": "[-]",
            "i": "|",
            "j": "_|",
            "k": "|<",
            "l": "1",
            "m": "[]\/[]",
            "n": "[]\[]",
            "o": "0",
            "p": "|D",
            "q": "(,)",
            "r": "|Z",
            "s": "$",
            "t": "']['",
            "u": "|_|",
            "v": "\/",
            "w": "\/\/",
            "x": "}{",
            "y": "`/",
            "z": "2",
            ",": ",",
            ".": ".",
            "?": "?",
            "!": "!",
            "'": "'"}

def main():

    translation = []

    user_data = input()
    if len(user_data) < 10000:
        for i in range(0, len(user_data)):
            translation.append(ascii_change(lowercase(user_data), new_dict, i))
    print_string(translation)
        


def ascii_change(text: str, trans: dict, text_placement: int) -> str:
    # print(f'Changing {text[text_placement]} to {trans.get(text[text_placement])}')
    return trans.get(text[text_placement])
        

def lowercase(text: str) -> str:
    return text.lower()

def print_string(text: list):
    for c in text:
        if c == None:
            print(" ", end = "")
        else:
            print(c, end = "")

if __name__ == "__main__":
    main()