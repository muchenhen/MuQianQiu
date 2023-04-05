// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "QianQiu/Actors/CardBase.h"
#include "UObject/Object.h"
#include "StoryCardsDeck.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UStoryCardsDeck : public UObject
{
    GENERATED_BODY()

private:
    UPROPERTY(BlueprintReadOnly)
    TArray<ACardBase*> Cards;

    UPROPERTY(BlueprintReadOnly)
    int Score;

public:
    UFUNCTION(BlueprintCallable)
    void SetCardToDeck(ACardBase* Card);

    UFUNCTION(BlueprintCallable)
    void UpdateScore();

    UFUNCTION(BlueprintCallable)
    int GetScore();
};
