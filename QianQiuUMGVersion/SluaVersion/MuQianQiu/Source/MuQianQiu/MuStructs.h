// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DataTable.h"
#include "MuStructs.generated.h"

#define ENUM_TO_STRING(EnumName, EnumValue) \
case EnumName::EnumValue: return TEXT(#EnumValue);

USTRUCT(Blueprintable, BlueprintType)
struct MUQIANQIU_API FCardData : public FTableRowBase
{
    GENERATED_BODY()

public:
    UPROPERTY(BlueprintReadWrite)
    int CardID = 204;
    UPROPERTY(BlueprintReadWrite)
    FString Name = TEXT("阿阮");
    UPROPERTY(BlueprintReadWrite)
    int Value = 2;
    UPROPERTY(BlueprintReadWrite)
    FString Season = TEXT("春");
    UPROPERTY(BlueprintReadWrite)
    FString Describe = TEXT("楚梦沉醉朝复暮，\n清歌远上巫山低。");
    UPROPERTY(BlueprintReadWrite)
    FString Type = "Char";
    UPROPERTY(BlueprintReadWrite)
    FString Texture = "Tex_Char_ARuan";
    UPROPERTY(BlueprintReadWrite)
    bool Special = false;
    UPROPERTY(BlueprintReadWrite)
    int SpecialName = 0;
    UPROPERTY(BlueprintReadWrite)
    TArray<int> SkillsID;

    FCardData()
    {
    }

    FCardData(int InCardID, FString InName, int InValue, FString InSeason,
              FString InType, FString InTexture, bool InSpecial,
              int InSpecialName)
    {
        CardID = InCardID;
        Name = InName;
        Value = InValue;
        Season = InSeason;
        Type = InType;
        Texture = InTexture;
        Special = InSpecial;
        SpecialName = InSpecialName;
    }

    void Dump() const
    {
        UE_LOG(LogTemp, Display, TEXT("当前选择的卡面信息: "));
        UE_LOG(LogTemp, Display, TEXT("ID:        %d"), CardID);
        UE_LOG(LogTemp, Display, TEXT("Name:      %s"), *Name);
        UE_LOG(LogTemp, Display, TEXT("Value:     %d"), Value);
        UE_LOG(LogTemp, Display, TEXT("Season:    %s"), *Season);
    }
};

// StoryData
USTRUCT(Blueprintable, BlueprintType)
struct MUQIANQIU_API FStoryData : public FTableRowBase
{
    GENERATED_BODY()

public:
    UPROPERTY(BlueprintReadWrite, EditAnywhere)
    int StoryID = 1;

    UPROPERTY(BlueprintReadWrite, EditAnywhere)
    FString Name = TEXT("厨房功夫");

    UPROPERTY(BlueprintReadWrite, EditAnywhere)
    TArray<FString> CardsName;

    UPROPERTY(BlueprintReadWrite, EditAnywhere)
    TArray<int> CardsID;

    UPROPERTY(BlueprintReadWrite, EditAnywhere)
    int Score = 0;

    UPROPERTY(BlueprintReadWrite, EditAnywhere)
    FString AudioID = TEXT("A01");
};

// SkillData
USTRUCT(Blueprintable, BlueprintType)
struct MUQIANQIU_API FSkillData : public FTableRowBase
{
    GENERATED_BODY()

public:
    UPROPERTY(BlueprintReadWrite)
    int CardID = 1;

    UPROPERTY(BlueprintReadWrite)
    FString CardName = TEXT("阿阮·山鬼");

    UPROPERTY(BlueprintReadWrite)
    FString Skill1Type = TEXT("保证出现");

    UPROPERTY(BlueprintReadWrite)
    FString Skill1Target = TEXT("夏夷则");

    UPROPERTY(BlueprintReadWrite)
    TArray<int> Skill1TargetID = { 203 };

    UPROPERTY(BlueprintReadWrite)
    int Skill1Value = 0;

    UPROPERTY(BlueprintReadWrite)
    FString Skill2Type = TEXT("翻开对手手牌");

    UPROPERTY(BlueprintReadWrite)
    FString Skill2Target = TEXT("");

    UPROPERTY(BlueprintReadWrite)
    TArray<int> Skill2TargetID;

    UPROPERTY(BlueprintReadWrite)
    int Skill2Value = 0;
};