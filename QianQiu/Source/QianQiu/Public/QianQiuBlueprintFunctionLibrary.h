// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "QianQiuBlueprintFunctionLibrary.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UQianQiuBlueprintFunctionLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    virtual UWorld* GetWorld() const override;

    UFUNCTION(BlueprintCallable, Category="QianQiuFunc")
    void LoadMap(FString MapPath);

    UFUNCTION(BlueprintCallable, Category="QianQiuFunc")
    AActor* GetActorByTag(UObject* WorldContext, FString Tag);

    UFUNCTION(BlueprintCallable, Category="QianQiuFunc")
    void InitCardManager(TMap<int, bool> Versions);

    UFUNCTION(BlueprintCallable, Category="QianQiuFunc")
    FString GetProBase();
};
