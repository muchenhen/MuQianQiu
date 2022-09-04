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

void UQianQiuBlueprintFunctionLibrary::GetActorsByTag(UObject* WorldContext, FString Tag, TArray<AActor*>& Actors)
{
    UGameplayStatics::GetAllActorsWithTag(WorldContext, *Tag, Actors);
}

void UQianQiuBlueprintFunctionLibrary::InitCardManager(TMap<int, bool> Versions)
{
    for (auto& Version : Versions)
    {
        UE_LOG(LogTemp, Warning, TEXT("Version %d is %s"), Version.Key, Version.Value ? TEXT("TRUE") : TEXT("FALSE"));
    }
}

FString UQianQiuBlueprintFunctionLibrary::GetProBase()
{
    return FApp::GetProjectName();
}

void UQianQiuBlueprintFunctionLibrary::DumpCardData(FCardData CardData)
{
    CardData.Dump();
}
