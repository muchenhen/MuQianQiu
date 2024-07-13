import pandas as pd
import csv
import os

# 相对路径，文件在当前py文件上一级目录下的CSV文件夹中
技能表格路径 = "../CSV/技能.xlsx"

技能表格内容 = dict()

卡牌信息CSV表路径 = "../CSV/Cards.csv"

卡牌信息 = dict()

# Index	CardID	CardName	Skill1Type	Skill1Target	Skill1TargetID	Skill1Value	Skill2Type	Skill2Target	Skill2TargetID	Skill2Value

def ReadSkillExcel():
    # 检查文件是否存在
    try:
        with open(技能表格路径) as file:
            pass
    except FileNotFoundError:
        print("技能表格文件不存在")
        return
    df = pd.read_excel(技能表格路径)
    return df

# 将Excel内容转换为字典
def ExcelToDict():
    df = ReadSkillExcel()
    # 第一行是表头，不需要
    # 从第二行开始，处理到字典中
    # 期望的结构是
    # 技能表格内容[Index] = {CardID=CardID, CardName=CardName, Skill1Type=Skill1Type, Skill1Target=Skill1Target, Skill1TargetID=Skill1TargetID, Skill1Value=Skill1Value, Skill2Type=Skill2Type, Skill2Target=Skill2Target, Skill2TargetID=Skill2TargetID, Skill2Value=Skill2Value}
    for index, row in df.iterrows():
        技能表格内容[row["Index"]] = {"CardID":row["CardID"], "CardName":row["CardName"], "Skill1Type":row["Skill1Type"], "Skill1Target":row["Skill1Target"], "Skill1TargetID":row["Skill1TargetID"], "Skill1Value":row["Skill1Value"], "Skill2Type":row["Skill2Type"], "Skill2Target":row["Skill2Target"], "Skill2TargetID":row["Skill2TargetID"], "Skill2Value":row["Skill2Value"]}
    return 技能表格内容

def ReadCardCSV(file_path):    
    if not os.path.exists(file_path):
        print(f"错误：文件 '{file_path}' 不存在")
        return 卡牌信息

    try:
        with open(file_path, newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            
            # 检查表头是否正确
            expected_headers = ["CardID", "Name", "Value", "Season", "Describe", "Type", "Texture", "Special", "SpecialName", "SkillsID"]
            if not all(header in reader.fieldnames for header in expected_headers):
                print("错误：CSV文件缺少必要的列")
                return 卡牌信息

            for row in reader:
                name = row["Name"]
                if name in 卡牌信息:
                    print(f"警告：重复的卡牌名称 '{name}'，将被覆盖")

                卡牌信息[name] = {
                    "CardID": row["CardID"],
                    "Name": name,
                    "Value": row["Value"],
                    "Season": row["Season"],
                    "Describe": row["Describe"],
                    "Type": row["Type"],
                    "Texture": row["Texture"],
                    "Special": row["Special"],
                    "SpecialName": row["SpecialName"],
                    "SkillsID": row["SkillsID"]
                }

    except csv.Error as e:
        print(f"读取CSV文件时出错: {e}")
    except KeyError as e:
        print(f"CSV文件中缺少必要的列: {e}")
    except Exception as e:
        print(f"发生未知错误: {e}")

    return 卡牌信息

# 主函数
def main():
    ExcelToDict()
    # print(技能表格内容)
    ReadCardCSV(卡牌信息CSV表路径)

    # 遍历技能表格内容
    # 需要做的事情
    # 技能表格内容中的每一个元素，通过CardName属性，在卡牌信息中找到相同的key
    # 将卡牌信息中的CardID属性，赋值给技能表格内容中的CardID属性
    # 处理Skill1TargetID和Skill2TargetID，这两个值需要通过Skill1Target和Skill2Target的值，找到对应的技能ID，这里需要检查Skill1Target和Skill2Target的值能否和卡牌信息中的CardName对应上，如果可以就将对应的CardID赋值给Skill1TargetID和Skill2TargetID
    for index, row in 技能表格内容.items():
        # print(row)
        # print(row["CardName"])
        if row["CardName"] in 卡牌信息:
            # print(卡牌信息[row["CardName"]]["CardID"])
            row["CardID"] = 卡牌信息[row["CardName"]]["CardID"]
            if row["Skill1Target"] in 卡牌信息:
                row["Skill1TargetID"] = 卡牌信息[row["Skill1Target"]]["CardID"]
            if row["Skill2Target"] in 卡牌信息:
                row["Skill2TargetID"] = 卡牌信息[row["Skill2Target"]]["CardID"]
        else:
            print(f"卡牌信息中没有找到卡牌名称为'{row['CardName']}'的卡牌")
    print(技能表格内容)
    
if __name__ == "__main__":
    main()