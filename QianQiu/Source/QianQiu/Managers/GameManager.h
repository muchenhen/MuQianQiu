// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "QianQiu/Actors/QianQiuKe.h"
#include "GameManager.generated.h"

UENUM()
enum class EGameMode : uint8
{
    AB, // 1+2
    AC, // 1+3
    BC  // 2+3
};

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
    
private:
    // 玩家A的实例对象
    UPROPERTY()
    AQianQiuKe* PlayerA;

    // 玩家B的实例对象
    UPROPERTY()
    AQianQiuKe* PlayerB;
};
