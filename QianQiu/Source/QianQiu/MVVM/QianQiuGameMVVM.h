// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "MVVMViewModelBase.h"
#include "QianQiuGameMVVM.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UQianQiuGameMVVM : public UMVVMViewModelBase
{
    GENERATED_BODY()

public:
    // 当前玩家A的分数
    UPROPERTY(BlueprintReadWrite, Setter, Getter, FieldNotify)
    int32 PlayerAScore;

    // 当前玩家B的分数
    UPROPERTY(BlueprintReadWrite, Setter, Getter, FieldNotify)
    int32 PlayerBScore;

private:
    void SetPlayerAScore(int32 Value);
    int32 GetPlayerAScore() const;

    void SetPlayerBScore(int32 Value);
    int32 GetPlayerBScore() const;
};
