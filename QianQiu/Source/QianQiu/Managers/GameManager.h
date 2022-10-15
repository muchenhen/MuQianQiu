// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "QianQiu/Actors/QianQiuKe.h"
#include "MuStructs.h"
#include "QianQiu/Actors/PublicCardsHolder.h"
#include "GameManager.generated.h"

DECLARE_LOG_CATEGORY_EXTERN(LogGameManager, Log, All);

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

    // 生成随机顺序的公共手牌ID
    UFUNCTION(BlueprintCallable)
    void InitCards();
    
    // 获取场景中已经初始化的Actor
    UFUNCTION(BlueprintCallable)
    void GetCardsInScene();

    // 初始化卡牌后，进行卡牌的分配，分别给玩家和公共卡池分配
    UFUNCTION(BlueprintCallable)
    void InitSendCards();

    UFUNCTION(BlueprintCallable)
    void ShowPublicCards();

private:
    // 随机卡牌ID顺序，游戏初始化时生成
    TArray<int32> AllInitCardsID;

    // 场景中已经初始化的Actor
    UPROPERTY()
    TMap<int, ACardBase*> Cards;
    
    // 玩家A的实例对象
    UPROPERTY()
    AQianQiuKe* PlayerA;

    // 玩家B的实例对象
    UPROPERTY()
    AQianQiuKe* PlayerB;

    UPROPERTY()
    APublicCardsHolder* PublicCardsHolder;
};
