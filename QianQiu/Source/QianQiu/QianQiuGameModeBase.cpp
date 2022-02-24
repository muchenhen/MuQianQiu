// Copyright Epic Games, Inc. All Rights Reserved.


#include "QianQiuGameModeBase.h"


void AQianQiuGameModeBase::StartPlay() {
    Super::StartPlay();
    UWorld* World = GetWorld();
    FVector Pos(0,0,0);
    FRotator Rot(0,0,0);
    if(World)
    {
        // FSoftObjectPath BP_Card_Class(FString("/Game/Model/BP_Card"));
        UClass* BP_Card_Class = StaticLoadClass(AActor::StaticClass(),nullptr,TEXT("Blueprint'/Game/Model/BP_Card.BP_Card_C'"));
        // auto obj = BP_Card_Class.ResolveObject();
        
        World->SpawnActor<AActor>(BP_Card_Class, Pos, Rot);

    }
}
