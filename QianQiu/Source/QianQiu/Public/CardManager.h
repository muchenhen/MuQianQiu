// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "Engine/DataTable.h"
#include "CardManager.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UCardManager : public UObject
{
	GENERATED_BODY()
	
private:

	static UDataTable* CardTable;

public:
	
	static void LoadCardData();
};
