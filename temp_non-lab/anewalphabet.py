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
                "y": "'/",
                "z": "2"}

def main():

    translation = []

    user_data = input()
    if len(user_data) < 10000:
        for i in range(len(user_data)):
            translation = ascii_change(lowercase(user_data, new_dict, i)).append()
    print_string(translation)
        


def ascii_change(text: str, trans: dict, text_placement: int) -> str:
    return trans.get(text[text_placement])
        

def lowercase(text: str) -> str:
    return text.lower()

def print_string(text: list):
    for c in text:
        print(c, end = "")

if __name__ == "__main__":
    main()