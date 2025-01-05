from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter
import os
import re

characters = set()


def simplify_font(source_font_path, output_font_path, text):
    """
    精简字体文件，只保留指定的字符
    :param source_font_path: 源字体文件路径
    :param output_font_path: 输出字体文件路径
    :param text: 需要保留的字符串
    """
    # 加载字体文件
    font = TTFont(source_font_path)
    
    # 创建Subsetter对象
    subsetter = Subsetter()
    
    # 设置需要保留的字符
    subsetter.populate(text=text)
    
    # 子集化字体
    subsetter.subset(font)
    
    # 保存新字体
    font.save(output_font_path)

# 从指定文件夹下遍历所有.txt .gd .tscn文件用UTF-8格式读取，包括子文件夹，然后收集所有字符，不重复，包括字母和数字
def collect_characters(folder:str):
    global characters  # 声明使用全局变量
    
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".txt") or file.endswith(".gd") or file.endswith(".tscn"):
                with open(os.path.join(root, file), "r", encoding="utf-8") as f:
                    content = f.read()
                    for char in content:
                        characters.add(char)

    # 检查一下是否包含了大小写字母和阿拉伯数字
    for i in range(26):
        characters.add(chr(65 + i))
        characters.add(chr(97 + i))
    for i in range(10):
        characters.add(chr(48 + i))

    # 对字符进行排序 数字 字母 汉字
    char_list = list(characters)
    char_list.sort(key=lambda x: (ord(x) < 128, x))
    
    return "".join(char_list)


if __name__ == "__main__":
    # 使用示例
    source_font_name = "SourceHanSerifSC-Regular"
    source_font = f"""C:/Users/muche/Downloads/{source_font_name}.otf"""  # 替换为你的源字体文件路径
    output_font = f"{source_font_name}-simplified.otf"
    aim_folder = f"E:\GitHub\MuQianQiu\GodotVersion"
    chars_to_keep = collect_characters(aim_folder)
    print(chars_to_keep)
    
    simplify_font(source_font, output_font, chars_to_keep)