import pandas as pd
import csv
import os

# 相对路径，文件在当前py文件上一级目录下的CSV文件夹中
技能表格路径 = "../CSV/技能.xlsx"

技能表格内容 = dict()

技能信息CSV表路径 = "../CSV/Skills.csv"

卡牌信息CSV表路径 = "../CSV/Cards.csv"

卡牌信息 = dict()

故事信息CSV表路径 = "../CSV/Story.csv"

故事信息 = dict()

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


# Index,StoryID,Name,CardsName,CardsID,Score,AudioID
def ReadStoryCSV(file_path):
    if not os.path.exists(file_path):
        print(f"错误：文件 '{file_path}' 不存在")
        return 故事信息
    try:
        with open(file_path, newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            # 检查表头是否正确
            expected_headers = ["Index", "StoryID", "Name", "CardsName", "CardsID", "Score", "AudioID"]
            if not all(header in reader.fieldnames for header in expected_headers):
                print("错误：CSV文件缺少必要的列")
                return 故事信息

            for row in reader:
                name = row["Name"]
                if name in 故事信息:
                    print(f"警告：重复的故事名称 '{name}'，将被覆盖")

                故事信息[name] = {
                    "Index": row["Index"],
                    "StoryID": row["StoryID"],
                    "Name": name,
                    "CardsName": row["CardsName"],
                    "CardsID": row["CardsID"],
                    "Score": row["Score"],
                    "AudioID": row["AudioID"]
                }
    except csv.Error as e:
        print(f"读取CSV文件时出错: {e}")
    except KeyError as e:
        print(f"CSV文件中缺少必要的列: {e}")
    except Exception as e:
        print(f"发生未知错误: {e}")

    return 故事信息

# Index	CardID	CardName	Skill1Type	Skill1Target	Skill1TargetID	Skill1Value	Skill2Type	Skill2Target	Skill2TargetID	Skill2Value
def WriteSkillCSV():
    # 写入技能表 Index从1开始累加 其他信息从技能表格内容中获取，utf-8编码
    with open(技能信息CSV表路径, "w", newline='', encoding='utf-8') as csvfile:
        fieldnames = ["Index", "CardID", "CardName", "Skill1Type", "Skill1Target", "Skill1TargetID", "Skill1Value", "Skill2Type", "Skill2Target", "Skill2TargetID", "Skill2Value"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for index, row in 技能表格内容.items():
            writer.writerow({"Index":index, "CardID":row["CardID"], "CardName":row["CardName"], "Skill1Type":row["Skill1Type"], "Skill1Target":row["Skill1Target"], "Skill1TargetID":row["Skill1TargetID"], "Skill1Value":row["Skill1Value"], "Skill2Type":row["Skill2Type"], "Skill2Target":row["Skill2Target"], "Skill2TargetID":row["Skill2TargetID"], "Skill2Value":row["Skill2Value"]})
     

# 主函数
def main():
    ExcelToDict()
    # print(技能表格内容)
    ReadCardCSV(卡牌信息CSV表路径)
    ReadStoryCSV(故事信息CSV表路径)

    百里屠苏ID = 卡牌信息["百里屠苏"]["CardID"]
    风晴雪ID = 卡牌信息["风晴雪"]["CardID"]
    方兰生ID = 卡牌信息["方兰生"]["CardID"]
    襄铃ID = 卡牌信息["襄铃"]["CardID"]
    红玉ID = 卡牌信息["红玉"]["CardID"]
    尹千觞ID = 卡牌信息["尹千觞"]["CardID"]

    乐无异ID = 卡牌信息["乐无异"]["CardID"]
    闻人羽ID = 卡牌信息["闻人羽"]["CardID"]
    夏夷则ID = 卡牌信息["夏夷则"]["CardID"]
    阿阮ID = 卡牌信息["阿阮"]["CardID"]

    北洛ID = 卡牌信息["北洛"]["CardID"]
    云无月ID = 卡牌信息["云无月"]["CardID"]
    岑缨ID = 卡牌信息["岑缨"]["CardID"]
    姬轩辕ID = 卡牌信息["姬轩辕"]["CardID"]
    
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
            if row["Skill1Target"] in 故事信息:
                row["Skill1TargetID"] = 故事信息[row["Skill1Target"]]["StoryID"]
            if row["Skill2Target"] in 故事信息:
                row["Skill2TargetID"] = 故事信息[row["Skill2Target"]]["StoryID"]

            # 特殊处理的Target
            if row["Skill1Target"] == "古剑奇谭一":
                # 目标是古剑奇谭一，意思就是目标卡是 百里屠苏、风晴雪、方兰生、襄铃、红玉、尹千觞
                row["Skill1TargetID"] = f"{百里屠苏ID},{风晴雪ID},{方兰生ID},{襄铃ID},{红玉ID},{尹千觞ID}"
            if row["Skill1Target"] == "古剑奇谭二":
                # 目标是古剑奇谭二，目标卡是 乐无异、闻人羽、夏夷则、阿阮
                row["Skill1TargetID"] = f"{乐无异ID},{闻人羽ID},{夏夷则ID},{阿阮ID}"
            if row["Skill1Target"] == "古剑奇谭三":
                # 北洛、云无月、岑缨、姬轩辕
                row["Skill1TargetID"] = f"{北洛ID},{云无月ID},{岑缨ID},{姬轩辕ID}"
            if row["Skill2Target"] == "古剑奇谭一":
                # 目标是古剑奇谭一，意思就是目标卡是 百里屠苏、风晴雪、方兰生、襄铃、红玉、尹千觞
                row["Skill2Target"] = f"{百里屠苏ID},{风晴雪ID},{方兰生ID},{襄铃ID},{红玉ID},{尹千觞ID}"
            if row["Skill2Target"] == "古剑奇谭二":
                # 目标是古剑奇谭二，目标卡是 乐无异、闻人羽、夏夷则、阿阮
                row["Skill2Target"] = f"{乐无异ID},{闻人羽ID},{夏夷则ID},{阿阮ID}"
            if row["Skill2Target"] == "古剑奇谭三":
                # 北洛、云无月、岑缨、姬轩辕
                row["Skill2Target"] = f"{北洛ID},{云无月ID},{岑缨ID},{姬轩辕ID}"

            # 有多个实际的Target的情况，这种情况下Skill1TargetID和Skill2TargetID是一个分号分隔的字符串
            if isinstance(row["Skill1Target"], str) and ";" in row["Skill1Target"]:
                # 有分号，表示有多个Target
                targets = row["Skill1Target"].split(";")
                target_ids = []
                for target in targets:
                    if target in 卡牌信息:
                        target_ids.append(卡牌信息[target]["CardID"])
                    if target in 故事信息:
                        target_ids.append(故事信息[target]["StoryID"])
                row["Skill1TargetID"] = ";".join(target_ids)
            if isinstance(row["Skill2Target"], str) and ";" in row["Skill2Target"]:
                # 有分号，表示有多个Target
                targets = row["Skill2Target"].split(";")
                target_ids = []
                for target in targets:
                    if target in 卡牌信息:
                        target_ids.append(卡牌信息[target]["CardID"])
                    if target in 故事信息:
                        target_ids.append(故事信息[target]["StoryID"])
                row["Skill2TargetID"] = ";".join(target_ids)


        else:
            print(f"卡牌信息中没有找到卡牌名称为'{row['CardName']}'的卡牌")
    # print(技能表格内容)
    WriteSkillCSV()
    
if __name__ == "__main__":
    main()