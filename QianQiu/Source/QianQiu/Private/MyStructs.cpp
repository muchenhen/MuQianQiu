// Fill out your copyright notice in the Description page of Project Settings.


#include "MyStructs.h"

USTRUCT(BlueprintType)
struct FCardData : FTableRowBase
{
	GENERATED_USTRUCT_BODY()
public:
	FCardData(): CardID(204), Value(2), SpecialName(0), EffectFirst(0), ParamFirst(0), EffectSecond(0), ParamSecond(0)
	{
		Name = "阿阮";
		Season = "春";
		Describe = "楚梦沉醉朝复暮，\n清歌远上巫山低。";
		Type = "Char";
		Texture = "Tex_Char_ARuan";
	}

	int CardID;
	FString Name;
	int Value;
	FString Season;
	FString Describe;
	FString Type;
	FString Texture;
	int SpecialName;
	int EffectFirst;
	int ParamFirst;
	int EffectSecond;
	int ParamSecond;
};