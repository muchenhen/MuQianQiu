﻿// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "MuStructs.h"
#include "DataManager.generated.h"

/**
 * 
 */
UCLASS()
class MUQIANQIU_API UDataManager : public UGameInstanceSubsystem
{
    GENERATED_BODY()
private:
    static TSharedPtr<UDataTable> CardDataTable;

    static TSharedPtr<UDataTable> StoryDataTable;

    static TSharedPtr<UDataTable> SkillDataTable;

public:
    UDataManager();

    UFUNCTION(BlueprintCallable, Category = "DataManager")
    static FCardData GetCardData(int CardID);

    UFUNCTION(BlueprintCallable, Category = "DataManager")
    static TArray<FStoryData> GetAllStoryData();

    UFUNCTION(BlueprintCallable, Category = "DataManager")
    static FStoryData GetStoryData(int StoryID);

    UFUNCTION(BlueprintCallable, Category = "DataManager")
    static TArray<FCardData> GetAllSpecialCardDatas();

    UFUNCTION(BlueprintCallable, Category = "DataManager")
    static FSkillData GetSkillData(int SkillID);
};
