// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DataTable.h"
#include "MyStructs.h"
#include "CardManager.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UCardManager : public UObject
{
	GENERATED_BODY()
	
private:
    TArray<FCardData> CardDataArray;

public:
    void LoadCardData();
    static FCardData GetCardData(const int& CardID);
};