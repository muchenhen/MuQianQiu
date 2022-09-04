// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "Managers/CardManager.h"
#include "QianQiuGameModeBase.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API AQianQiuGameModeBase : public AGameModeBase
{
    GENERATED_BODY()
    
    virtual void StartPlay() override;

    virtual void EndPlay(const EEndPlayReason::Type EndPlayReason) override;
};
