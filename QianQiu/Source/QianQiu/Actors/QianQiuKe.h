// 玩家类

#pragma once

#include "CoreMinimal.h"
#include "CardBase.h"
#include "GameFramework/Character.h"
#include "QianQiuKe.generated.h"


USTRUCT()
struct FCardSlot
{
    GENERATED_BODY()
public:
    UPROPERTY(VisibleAnywhere)
    bool bEmpty = true;

    UPROPERTY(VisibleAnywhere)
    FTransform Transform;

    UPROPERTY(VisibleAnywhere)
    ACardBase* CardBase;
};

/*
 * 玩家类
 * 玩家的牌堆、分数、组合等信息和相关方法
 */
UCLASS()
class QIANQIU_API AQianQiuKe : public ACharacter
{
    GENERATED_BODY()

public:

protected:
    /* 玩家的手牌堆 */
    UPROPERTY(VisibleAnywhere)
    TMap<int, ACardBase*> PlayerCardInHands;

    /* 玩家的故事堆 */
    UPROPERTY(VisibleAnywhere)
    TMap<int, ACardBase*> PlayerCardInStory;

    /* 特殊牌堆 */
    UPROPERTY(VisibleAnywhere)
    TMap<int, ACardBase*> PlayerCardInSpecial;

    /* 玩家分数 */
    UPROPERTY(VisibleAnywhere)
    int Score;
    
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
    UFUNCTION(BlueprintCallable)
    void AddScore(const int& ScoreIncreased);

    
};
