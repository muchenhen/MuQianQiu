// 玩家类

#pragma once

#include "CoreMinimal.h"
#include "CardBase.h"
#include "QianQiuKe.generated.h"




/*
 * 玩家类
 * 玩家的牌堆、分数、组合等信息和相关方法
 */
UCLASS()
class QIANQIU_API AQianQiuKe : public AActor
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable)
    void ResetQianQiuKe();

protected:
    /* 玩家的手牌堆 */
    UPROPERTY(VisibleAnywhere, BlueprintReadWrite, DisplayName = "手牌堆")
    TMap<int, ACardBase*> PlayerCardInHands;

    /* 玩家的故事堆 */
    UPROPERTY(VisibleAnywhere, BlueprintReadWrite, DisplayName = "故事牌堆")
    TMap<int, ACardBase*> PlayerCardInStory;

    /* 特殊牌堆 */
    UPROPERTY(VisibleAnywhere, BlueprintReadWrite, DisplayName = "特殊牌堆")
    TMap<int, ACardBase*> PlayerCardInSpecial;

    /* 玩家分数 */
    UPROPERTY(VisibleAnywhere, BlueprintReadWrite, DisplayName = "分数")
    int Score = 0;

public:
    // Sets default values for this character's properties
    // AQianQiuKe();

    // AQianQiuKe(FObjectInitializer const& ObjectInitializer);

protected:
    // Called when the game starts or when spawned
    virtual void BeginPlay() override;

public:
    // Called every frame
    virtual void Tick(float DeltaTime) override;
    
    // 增加玩家分数
    UFUNCTION(BlueprintCallable, CallInEditor)
    void AddScore(const int& ScoreIncreased);

    // 设置玩家分数
    /**
     * @brief 直接设置玩家分数
     * @param InScore 传入的分数参数
     */
    UFUNCTION(BlueprintCallable, CallInEditor)
    void SetScore(const int& InScore);

    /**
     * @brief 获取玩家分数
     * @return 返回玩家分数
     */
    UFUNCTION(BlueprintCallable, CallInEditor)
    int GetScore();

    /**
     * @brief 计算玩家分数
     */
    UFUNCTION(BlueprintCallable)
    void CalculateScore();

    // 传递给玩家故事堆一张牌
    UFUNCTION(BlueprintCallable)
    void SetCardToStory(ACardBase* CardBase);

    // 传递给玩家故事堆一堆牌
    UFUNCTION(BlueprintCallable)
    void SetCardsToStory(TArray<ACardBase*> Cards);
    
    /**
     * @brief 获取玩家的故事牌堆
     * @return 返回玩家的故事牌堆
     */
    UFUNCTION(BlueprintCallable)
    TMap<int, ACardBase*> GetCardsInStory();

    // 给玩家一张手牌
    UFUNCTION(BlueprintCallable)
    void SetCardToHands(ACardBase* CardBase);

    // 从玩家手牌堆中移除一张牌、
    UFUNCTION(BlueprintCallable)
    void RemoveCardFromHands(ACardBase* CardBase);

    /**
     * @brief 初始化玩家手牌的位置 并播放发牌动画
     * @param HandFirst 起始位置
     * @param HandLast 结束位置
     */
    UFUNCTION(BlueprintCallable)
    void InitHandCardTransformPlayAnim(FString HandFirst, FString HandLast);

    /**
     * @brief 通过传入的起始位置和结束位置，计算出每张牌的目标位置
     * @param StartTransform 起始位置
     * @param EndTransform 结束位置
     * @param CardTargetTransform 牌的目标位置  
     */
    UFUNCTION(BlueprintCallable)
    void InitCollectHandCardsTransform(FTransform StartTransform, FTransform EndTransform, TMap<ACardBase*, FTransform>& CardTargetTransform);
    
    UFUNCTION(BlueprintCallable)
    void SetCardToSpecial(ACardBase* CardBase);

    // get PlayerCardInHands
    UFUNCTION(BlueprintCallable)
    TMap<int, ACardBase*> GetPlayerCardInHands();

private:

    UPROPERTY()
    bool bIsAI = false;
    
public:

    UFUNCTION()
    void AIActionSimple();

    UFUNCTION()
    bool GetIsAI();
};
