// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UIManager.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UUIManager : public UGameInstanceSubsystem
{
    GENERATED_BODY()

public:

    UUIManager();

    // 打开全屏UI禁止输入
    UFUNCTION(BlueprintCallable)
    void OpenDisableInputUI();

    // 关闭全屏UI接受输入
    UFUNCTION(BlueprintCallable)
    void CloseDisableInputUI();

    // 强制关闭全屏UI
    UFUNCTION(BlueprintCallable)
    void ForceCloseDisableInputUI();
    
private:
    UPROPERTY()
    UUserWidget* DisableInputUI;

    // 记录打开全屏UI的次数
    UPROPERTY()
    int DisableInputCount;
    
};
