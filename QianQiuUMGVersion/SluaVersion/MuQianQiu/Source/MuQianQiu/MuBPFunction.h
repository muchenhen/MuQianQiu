﻿// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "MuStructs.h"
#include "Components/Image.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "MuBPFunction.generated.h"

/**
 * 
 */
UCLASS()
class MUQIANQIU_API UMuBPFunction : public UBlueprintFunctionLibrary
{
    GENERATED_BODY()

private:
    static UGameInstance* GameInstance;

public:
    static void SetGameInstance(UGameInstance* InGameInstance);

    UFUNCTION(BlueprintCallable, Category = "MuBPFunction")
    static void Test(const FString& String);

    UFUNCTION(BlueprintCallable, Category = "MuBPFunction")
    static UTexture2D* LoadTexture2D(FString CardType, FString TexturePath);

    UFUNCTION(BlueprintCallable, Category = "MuBPFunction")
    static UUserWidget* CreateUserWidget(const FString& WidgetPath);

    UFUNCTION(BlueprintCallable, Category = "MuBPFunction")
    static FVector2D GetWidgetAbsolutePosition(const UWidget* Widget);

    UFUNCTION(BlueprintCallable, Category = "MuBPFunction")
    static FVector2D GetMonitorBestDisplaySize();

    UFUNCTION(BlueprintCallable, Category = "MuBPFunction")
    static USoundBase* LoadSoundBase(const FString& SoundPath);

    UFUNCTION(BlueprintCallable, Category = "Widget")
    static FVector2D GetWidgetPositionInViewport(UWidget* Widget);

    UFUNCTION(BlueprintCallable, Category = "Widget")
    static void SetWidgetPositionInViewport(UWidget* Widget, const FVector2D& NewPosition);
};