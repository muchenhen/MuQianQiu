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
     * @brief ��ȡĳһ��ģʽ�����еĶ�Ӧ�Ŀ��Ƶ�ID
     * @param GameMode Ҫ��ȡ����Ϸģʽ
     * @param CardsID ��ģʽ�����еĿ���ID
     */
    static void GetCardsIDByGameMode(EGameMode GameMode, TArray<int32>& CardsID);
};
