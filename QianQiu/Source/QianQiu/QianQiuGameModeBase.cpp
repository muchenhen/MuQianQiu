// Copyright Epic Games, Inc. All Rights Reserved.


#include "QianQiuGameModeBase.h"


void AQianQiuGameModeBase::StartPlay() {
    Super::StartPlay();
    UE_LOG(LogTemp, Warning, TEXT("Game StartPlay"));
    UDataManager::LoadCardData();
    UDataManager::LoadCardTransform();
}

void AQianQiuGameModeBase::EndPlay(const EEndPlayReason::Type EndPlayReason)
{
    Super::EndPlay(EndPlayReason);
    UE_LOG(LogTemp, Warning, TEXT("Game EndPlay"));
}
