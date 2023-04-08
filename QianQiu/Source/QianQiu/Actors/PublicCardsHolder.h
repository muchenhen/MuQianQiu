// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "CardBase.h"
#include "PublicCardsHolder.generated.h"


USTRUCT()
struct FPublicCardShowTransform
{
    GENERATED_BODY()
public:
    UPROPERTY()
    ACardBase* Card;

    UPROPERTY()
    FTransform Transform;
};

/**
 * 公共牌堆类 负责管理公共牌堆的牌
 */
UCLASS()
class QIANQIU_API APublicCardsHolder : public AActor
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
    /* 公共牌堆 */
    UPROPERTY(VisibleAnywhere, BlueprintReadWrite, DisplayName = "公共牌堆")
    TMap<int, ACardBase*> PublicCards;

    /* 已经展示出来的公共牌堆
     * Key 是 索引 不是ID
     */
    UPROPERTY(VisibleAnywhere, BlueprintReadWrite, DisplayName = "公共牌堆")
    TMap<int, ACardBase*> PublicCardsShow;

    UPROPERTY()
    TMap<int, FPublicCardShowTransform> PublicCardShowTransforms;

    UPROPERTY()
    FTimerHandle TimerHandle;

private:
    UPROPERTY()
    TArray<ACardBase*> SpringCardsShow;

    UPROPERTY()
    TArray<ACardBase*> SummerCardsShow;

    UPROPERTY()
    TArray<ACardBase*> AutumnCardsShow;

    UPROPERTY()
    TArray<ACardBase*> WinterCardsShow;
    
public:

    /**
     * @brief 清空公共牌堆
     */
    UFUNCTION(BlueprintCallable)
    void ResetPublicCardsHolder();

    /**
     * @brief 向公共牌堆中添加一张牌
     * @param CardBase 牌
     */
    UFUNCTION(BlueprintCallable)
    void SetCardToPublicCardsHolder(ACardBase* CardBase);

    /**
     * @brief 初始化时将公共牌堆中的牌展示出来
     */
    UFUNCTION(BlueprintCallable)
    void DealCardToPublicShowOnInit();
    
    /**
     * @brief 从公共牌堆中取出一张牌补位到展示的公共牌中
     */
    UFUNCTION(BlueprintCallable)
    void SupplementedPublicShow();

    UFUNCTION(BlueprintCallable)
    void GetNowPublicShowCardsBySeason(const FString& Season, TArray<ACardBase*>& OutCards);

    /**
     * @brief 从PublicCardsShow中移除一张牌
     */
    UFUNCTION(BlueprintCallable)
    void RemoveCardFromPublicShow(ACardBase* Card);

    /**
     * @brief 将Card加入对应的季节的展示牌堆中
     */
    UFUNCTION(BlueprintCallable)
    void AddCardToSeasonShow(ACardBase* Card);
};
