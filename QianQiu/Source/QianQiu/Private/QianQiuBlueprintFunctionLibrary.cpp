// Fill out your copyright notice in the Description page of Project Settings.


#include "QianQiuBlueprintFunctionLibrary.h"

#include "Kismet/GameplayStatics.h"

UWorld* UQianQiuBlueprintFunctionLibrary::GetWorld() const {
    return Super::GetWorld();
}

void UQianQiuBlueprintFunctionLibrary::LoadMap(FString MapName)
{
    FLatentActionInfo LatentActionInfo;
    UGameplayStatics::LoadStreamLevel(this, FName(*MapName), true, true, LatentActionInfo);
}

AActor* UQianQiuBlueprintFunctionLibrary::GetActorByTag(UObject* WorldContext, FString Tag)
{
    TArray<AActor*> Actors;
    UGameplayStatics::GetAllActorsWithTag(WorldContext, *Tag, Actors);
    if (Actors.Num()>0)
    {
        return Actors[0];
    }
    else
    {
        return nullptr;
    }
}
