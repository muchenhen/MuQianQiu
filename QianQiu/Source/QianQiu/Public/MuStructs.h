// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "Engine/DataTable.h"
#include "MuStructs.generated.h"

#define ENUM_TO_STRING(EnumName, EnumValue) \
case EnumName::EnumValue: return TEXT(#EnumValue);

class ACardBase;
UENUM()
enum class EGameMode : uint8
{
    AB, // 1+2
    AC, // 1+3
    BC  // 2+3
};

USTRUCT()
struct FCardSlot
{
    GENERATED_BODY()
public:
    UPROPERTY(VisibleAnywhere)
    bool bEmpty = true;

    UPROPERTY(VisibleAnywhere)
    FTransform Transform;

    UPROPERTY(VisibleAnywhere)
    ACardBase* CardBase;
};

USTRUCT(Blueprintable, BlueprintType)
struct QIANQIU_API FCardPosition : public FTableRowBase
{
    GENERATED_BODY()
public:
    UPROPERTY(EditAnywhere, DisplayName = "卡牌位置")
    FTransform CardTransform = FTransform();
};

USTRUCT(Blueprintable, BlueprintType)
struct QIANQIU_API FCardData : public FTableRowBase
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, DisplayName = "卡面ID")
	int CardID = 204;
	UPROPERTY(EditAnywhere, DisplayName = "卡面名称")
	FString Name = TEXT("阿阮");
	UPROPERTY(EditAnywhere, DisplayName = "卡面分值")
	int Value = 2;
	UPROPERTY(EditAnywhere, DisplayName = "卡面属性")
	FString Season = TEXT("春");
	UPROPERTY(EditAnywhere, DisplayName = "卡片描述")
	FString Describe = TEXT("楚梦沉醉朝复暮，\n清歌远上巫山低。");
	UPROPERTY(EditAnywhere, DisplayName = "卡面类型")
	FString Type = "Char";
	UPROPERTY(EditAnywhere, DisplayName = "卡面贴图")
	FString Texture = "Tex_Char_ARuan";
    UPROPERTY(EditAnywhere, DisplayName = "是否为特殊牌")
    bool Special = false;
	UPROPERTY(EditAnywhere, DisplayName = "特殊卡名称")
	int SpecialName = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊效果1")
	int EffectFirst = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊效果1参数")
	int ParamFirst = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊效果2")
	int EffectSecond = 0;
	UPROPERTY(EditAnywhere, DisplayName = "特殊效果2参数")
	int ParamSecond = 0;

	FCardData(){}
	
	FCardData(int InCardID, FString InName, int InValue, FString InSeason,
		FString InType, FString InTexture, bool InSpecial,
		int InSpecialName, int InEffectFirst, int InParamFirst, int InEffectSecond, int InParamSecond)
	{
		CardID = InCardID;
		Name = InName;
		Value = InValue;
		Season = InSeason;
		Type = InType;
		Texture = InTexture;
	    Special = InSpecial;
		SpecialName = InSpecialName;
		EffectFirst = InEffectFirst;
		ParamFirst = InParamFirst;
		EffectSecond = InEffectSecond;
		ParamSecond = InParamSecond;
	}

    void Dump()
	{
	    UE_LOG(LogTemp, Display, TEXT("当前选择的卡面信息: "));   
	    UE_LOG(LogTemp, Display, TEXT("ID:        %d"), CardID);   
	    UE_LOG(LogTemp, Display, TEXT("Name:      %s"), *Name);
	    UE_LOG(LogTemp, Display, TEXT("Value:     %d"), Value);   
	    UE_LOG(LogTemp, Display, TEXT("Season:    %s"), *Season);
	}
};

UENUM()
enum class EMoveState : uint8
{
    Stop,
    MoveTransform,
    MoveTransition,
    MoveRotation,
};

UENUM()
enum class ECardBelongType : uint8
{
    Public,
    PublicShow,
    PlayerA,
    PlayerB,
    PlayerAScore,
    PlayerBScore,
};
