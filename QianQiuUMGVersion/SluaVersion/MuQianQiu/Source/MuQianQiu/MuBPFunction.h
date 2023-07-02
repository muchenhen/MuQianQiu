// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
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
};
