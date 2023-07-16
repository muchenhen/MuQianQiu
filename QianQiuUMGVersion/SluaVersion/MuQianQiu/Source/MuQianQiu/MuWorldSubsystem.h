// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "MuWorldSubsystem.generated.h"

/**
 * 
 */
UCLASS()
class MUQIANQIU_API UMuWorldSubsystem : public UTickableWorldSubsystem
{
    GENERATED_BODY()
    
public:
    virtual void Tick(float DeltaTime) override;

    virtual TStatId GetStatId() const override;
    
    bool bWindowResized = false;
};
