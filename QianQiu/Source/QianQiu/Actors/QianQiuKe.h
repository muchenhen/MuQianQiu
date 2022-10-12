// 玩家类

#pragma once

#include "CoreMinimal.h"
#include "CardBase.h"
#include "MuStructs.h"
#include "GameFramework/Character.h"
#include "QianQiuKe.generated.h"




/*
 * 玩家类
 * 玩家的牌堆、分数、组合等信息和相关方法
 */
UCLASS()
class QIANQIU_API AQianQiuKe : public ACharacter
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
    AQianQiuKe();


protected:
    // Called when the game starts or when spawned
    virtual void BeginPlay() override;

public:
    // Called every frame
    virtual void Tick(float DeltaTime) override;

    // Called to bind functionality to input
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

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

    UFUNCTION(BlueprintCallable)
    void UpdateHandCardsTransform();

    UFUNCTION(BlueprintCallable)
    void SetCardToSpecial(ACardBase* CardBase);

    
};
