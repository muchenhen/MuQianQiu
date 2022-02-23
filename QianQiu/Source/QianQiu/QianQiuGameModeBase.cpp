// Copyright Epic Games, Inc. All Rights Reserved.


#include "QianQiuGameModeBase.h"


void AQianQiuGameModeBase::StartPlay() {
    Super::StartPlay();
    const UWorld* World = GetWorld();
    FVector Pos(0,0,0); 
    if(World)
    {
        UClass* BP_Card_Class = StaticLoadClass( AActor::GetClass(),nullptr,TEXT("Blueprint'/Game/Model/BP_Card.BP_Card_C'"));
        World->SpawnActor<BP_Card_Class>(Pos, FRotator::ZeroRotator);

    }
}
