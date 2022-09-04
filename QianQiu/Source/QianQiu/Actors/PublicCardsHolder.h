// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "CardBase.h"
#include "GameFramework/Character.h"
#include "PublicCardsHolder.generated.h"

UCLASS()
class QIANQIU_API APublicCardsHolder : public ACharacter
{
    GENERATED_BODY()

public:
    // Sets default values for this actor's properties
    APublicCardsHolder();

    // Called every frame
    virtual void Tick(float DeltaTime) override;

protected:
    // Called when the game starts or when spawned
    virtual void BeginPlay() override;

public:
    /* 玩家的手牌堆 */
    UPROPERTY(VisibleAnywhere, BlueprintReadWrite, DisplayName = "公共牌堆")
    TMap<int, ACardBase*> PublicCards;

    UFUNCTION(BlueprintCallable)
    void ResetPublicCardsHolder();

    UFUNCTION(BlueprintCallable)
    void SetCardToPublicCardsHolder(ACardBase* CardBase);
};
