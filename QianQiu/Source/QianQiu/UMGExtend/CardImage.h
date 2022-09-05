// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Components/Image.h"
#include "CardImage.generated.h"

class UDataManager;

/**
 * 
 */
UCLASS()
class QIANQIU_API UCardImage : public UImage
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="卡面相关", DisplayName="卡片ID")
	int ID;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="卡面相关", DisplayName="卡片尺寸")
	FVector2D CardSize;
	
	UFUNCTION(BlueprintCallable)
	void SetCard(const int& CardID);
};
