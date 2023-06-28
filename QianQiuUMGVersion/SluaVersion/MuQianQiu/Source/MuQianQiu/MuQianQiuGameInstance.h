// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "slua.h"
#include "Engine/GameInstance.h"
#include "MuQianQiuGameInstance.generated.h"

/**
 * 
 */
UCLASS()
class MUQIANQIU_API UMuQianQiuGameInstance : public UGameInstance
{
    GENERATED_BODY()
public:

    UMuQianQiuGameInstance();
    
    virtual void Init() override;

    virtual void Shutdown() override;

    void LuaStateInitCallback(NS_SLUA::lua_State* L);

    void CreateLuaState();
    
    void CloseLuaState();

    NS_SLUA::LuaState* State;
};
