// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "CardBase.h"
#include "GameFramework/Character.h"
#include "PublicCardsHolder.generated.h"
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

    UPROPERTY()
    TMap<ACardBase*, FTransform> FirstShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> SecondShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> ThirdShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> FourthShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> FifthShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> SixthShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> SeventhShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> EighthShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> NinthShowCardTransform;

    UPROPERTY()
    TMap<ACardBase*, FTransform> TenthShowCardTransform;
    
public:

    UFUNCTION(BlueprintCallable)
    void ResetPublicCardsHolder();

    UFUNCTION()
    void UpdatePublicCardsHolderTransform(const FString PublicCardsHolderTop, const FString PublicCardsHolderButtom);

    UFUNCTION()
    void SetAllShowCardTransform();

    /**
     * @brief 向公共牌堆中添加一张牌
     * @param CardBase 牌
     */
    UFUNCTION(BlueprintCallable)
    void SetCardToPublicCardsHolder(ACardBase* CardBase);

    UFUNCTION(BlueprintCallable)
    void DealCardToPublicShowOnInit();
    
    /**
     * @brief 从公共牌堆中取出一张牌补位到展示的公共牌中
     */
    UFUNCTION(BlueprintCallable)
    void DealCardToPublicShow();
};
