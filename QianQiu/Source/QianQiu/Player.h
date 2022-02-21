// Fill out your copyright notice in the Description page of Project Settings.
/*
 *玩家类
 * ————持有手牌
 * ————当前分数
 * ————已完成组合
 * ————已使用的卡牌
 * ————带进场的特殊牌
 * ————AI行为模式
 **/
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Player.generated.h"

UCLASS()
class QIANQIU_API APlayer : public AActor {
    GENERATED_BODY()

public:
    // Sets default values for this actor's properties
    APlayer();

protected:
    // Called when the game starts or when spawned
    virtual void BeginPlay() override;

    // TMap<int,>

public:
    // Called every frame
    virtual void Tick(float DeltaTime) override;


};
