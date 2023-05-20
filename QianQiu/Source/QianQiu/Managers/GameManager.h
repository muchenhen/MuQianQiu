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
private: // 初始化
    
    // 控制生成哪些卡牌
    UPROPERTY()
    EGameMode GameMode = EGameMode::BC;

    // 随机卡牌ID顺序，游戏初始化时生成
    UPROPERTY()
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

    // 公共卡池的实例对象
    UPROPERTY()
    APublicCardsHolder* PublicCardsHolder;

    UPROPERTY()
    int MoveEndCardNum = 0;

    UPROPERTY()
    int InitPublicMoveEndCardNum = 0;

public: // 初始化用的方法

    // 每一局游戏开始时调用
    UFUNCTION(BlueprintCallable)
    void BeginGame();

    // 生成随机顺序的公共手牌ID
    UFUNCTION(BlueprintCallable)
    void InitCards();
    
    // 获取场景中已经初始化的Actor
    UFUNCTION(BlueprintCallable)
    void GetCardsInScene();

    UFUNCTION()
    void SetSeasonCardSelected(const ACardBase* CardActor);
    
    UFUNCTION()
    void OnCardChoose(ACardBase* CardActor);
    
    // 初始化卡牌后，进行卡牌的分配，分别给玩家和公共卡池分配
    UFUNCTION(BlueprintCallable)
    void InitSendCards();

    // 将所有卡设置为未选中
    UFUNCTION()
    void SetAllCardsUnSelected();

private: // 进行游戏时

    // 当前回合数
    UPROPERTY()
    int CurrentRound = 0;

    // 当前玩家A选择的卡牌
    UPROPERTY()
    ACardBase* CurrentPlayerAChooseCard;

    // 当前玩家B选择的卡牌
    UPROPERTY()
    ACardBase* CurrentPlayerBChooseCard;

public:

    UFUNCTION()
    void ChangeRound();

    // 当前是否有玩家正在选择卡牌
    UFUNCTION()
    bool GetIsPlayerChoosing();
    
private:
    UPROPERTY()
    bool bIsPlayerAChoosing = false;

    UPROPERTY()
    bool bIsPlayerBChoosing = false;

    UPROPERTY()
    ACardBase* CurrentPlayerChooseCard;
    
};