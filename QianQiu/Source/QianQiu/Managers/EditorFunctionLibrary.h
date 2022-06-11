// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/Object.h"
#include "EditorFunctionLibrary.generated.h"

class UDataTable;
/**
 * 
 */
UCLASS()
class QIANQIU_API AUEditorFunctionLibrary : public AActor
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, DisplayName="CardDataTable")
    UDataTable* CardDataTable;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    bool First = false;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    bool Second = true;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    bool Third = true;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    int FirstIDBegin = 101;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    int FirstIDEnd = 124;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    int SecondIDBegin = 201;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    int SecondIDEnd = 224;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    int ThirdIDBegin = 301;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    int ThirdIDEnd = 324;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Cards")
    FVector CardSpacingDirVector = FVector(0.0,0.1,0.0);

public:
    UFUNCTION(BlueprintCallable, CallInEditor, Category="Cards")
    void CreateCards();
};
