// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "Engine/DataTable.h"
#include "MyStructs.generated.h"

USTRUCT(Blueprintable, BlueprintType)
struct QIANQIU_API FCardData : public FTableRowBase
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, DisplayName = "卡面ID")
	int CardID = 204;
	UPROPERTY(EditAnywhere, DisplayName = "卡面名称")
	FString Name = "阿阮";
	UPROPERTY(EditAnywhere, DisplayName = "卡面分值")
	int Value = 2;
	UPROPERTY(EditAnywhere, DisplayName = "卡面属性")
	FString Season = "春";
	UPROPERTY(EditAnywhere, DisplayName = "卡片描述")
	FString Describe = "楚梦沉醉朝复暮，\n清歌远上巫山低。";
	UPROPERTY(EditAnywhere, DisplayName = "卡面类型")
	FString Type = "Char";
	UPROPERTY(EditAnywhere, DisplayName = "卡面贴图")
	FString Texture = "Tex_Char_ARuan";
	UPROPERTY(EditAnywhere, DisplayName = "特殊卡")
	int SpecialName = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊卡")
	int EffectFirst = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊卡")
	int ParamFirst = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊卡")
	int EffectSecond = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊卡")
	int ParamSecond = 0;

	FCardData(){}
	
	FCardData(int InCardID, FString InName, int InValue, FString InSeason,
		FString InType, FString InTexture,
		int InSpecialName, int InEffectFirst, int InParamFirst, int InEffectSecond, int InParamSecond)
	{
		CardID = InCardID;
		Name = InName;
		Value = InValue;
		Season = InSeason;
		Type = InType;
		Texture = InTexture;
		SpecialName = InSpecialName;
		EffectFirst = InEffectFirst;
		ParamFirst = InParamFirst;
		EffectSecond = InEffectSecond;
		ParamSecond = InParamSecond;
	}

};