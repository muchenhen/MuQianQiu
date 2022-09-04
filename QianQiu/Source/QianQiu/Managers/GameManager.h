// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "QianQiu/Actors/QianQiuKe.h"
#include "MuStructs.h"
#include "QianQiu/Actors/PublicCardsHolder.h"
#include "GameManager.generated.h"



/**
 * 
 */
UCLASS()
class QIANQIU_API UGameManager : public UGameInstanceSubsystem
{
    GENERATED_BODY()
public:
    UPROPERTY()
    EGameMode GameMode = EGameMode::BC;

    // 每一局游戏开始时调用
    UFUNCTION(BlueprintCallable)
    void BeginGame();

    // 生成随机顺序的公共手牌
    UFUNCTION(BlueprintCallable)
    void InitCards();

    UFUNCTION(BlueprintCallable)
    void SendCardsToPlayer();
    
private:

    //随机卡牌顺序
    TArray<int32> AllInitCardsID;
    
    // 玩家A的实例对象
    UPROPERTY()
    AQianQiuKe* PlayerA;

    // 玩家B的实例对象
    UPROPERTY()
    AQianQiuKe* PlayerB;

    UPROPERTY()
    APublicCardsHolder* PublicCardsHolder;
};
