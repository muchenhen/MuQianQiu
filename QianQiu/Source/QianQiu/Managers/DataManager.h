// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DataTable.h"
#include <QianQiu/Actors/CardBase.h>

#include "MuStructs.h"
#include "DataManager.generated.h"

DECLARE_LOG_CATEGORY_EXTERN(LogCardManager, Display, Display);

/**
 * 
 */
UCLASS(BlueprintType, Blueprintable)
class QIANQIU_API UDataManager : public UObject
{
	GENERATED_BODY()

public:
    UDataManager();
    virtual ~UDataManager() override;
	
private:
    static TMap<int, bool> VersionMap;

    static TMap<int, ACardBase*> CardsInLevel;

    static TSharedPtr<UDataTable> CardDataTable;

    static TSharedPtr<UDataTable> StoryDataTable;

    static TSharedPtr<UDataTable> CardTransformTable;
public:
    static void LoadCardData();

    static void LoadCardTransform();
    
    static FCardData GetCardData(const int& CardID);

    static FTransform GetCardTransform(const FString& TransformName);

    static void GetAllCardsInLevel();

    /**
     * @brief 获取某一个模式下所有的对应的卡牌的ID
     * @param GameMode 要获取的游戏模式
     * @param CardsID 该模式下所有的卡牌ID
     * @param bGetSpecialCard 是否获取特殊卡牌
     */
    static void GetCardsIDByGameMode(EGameMode GameMode, TArray<int32>& CardsID, bool bGetSpecialCard);

    /**
     * @brief 将卡牌ID进行随机排序
     * @param CardsID 卡牌ID数组
     */
    static void RandomCardsID(TArray<int32>& CardsID);

    /**
     * @brief 获取某一个模式下所有的对应的卡牌的ID，并进行随机排序
     * @param GameMode 
     * @param CardsID 
     */
    static void GetRandomCardsIDByGameMode(EGameMode GameMode, TArray<int32>& CardsID);
};
