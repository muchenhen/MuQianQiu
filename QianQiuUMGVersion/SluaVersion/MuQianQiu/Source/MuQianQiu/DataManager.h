// Fill out your copyright notice in the Description page of Project Settings.

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

public:
    UDataManager();

    UFUNCTION(BlueprintCallable, Category = "DataManager")
    static FCardData GetCardData(int CardID);
};
