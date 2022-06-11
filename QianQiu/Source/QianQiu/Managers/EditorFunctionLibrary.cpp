// Fill out your copyright notice in the Description page of Project Settings.


#include "EditorFunctionLibrary.h"

#include "QianQiu/Actors/CardBase.h"

void AUEditorFunctionLibrary::CreateCards()
{
    if (CardDataTable)
    {
        UClass* CardUClass = ACardBase::StaticClass();
        FVector Location = FVector(0, 0, 0);
        const FRotator Rotator = FRotator(0, 0, 0);

        int TotalNum = 0;
        if (First)
        {
            TotalNum = 24;
            for (int i = 0; i < TotalNum; i++)
            {
                const FActorSpawnParameters ActorSpawnParameters;
                Location += CardSpacingDirVector;
                AActor* Card = GetWorld()->SpawnActor(CardUClass, &Location, &Rotator, ActorSpawnParameters);
                int CardID = 100 + i + 1;
                FName RowName = FName(*FString::FromInt(CardID));
                FString ContextString = TEXT("FCardData::FindCardData");
                FCardData* CardData = CardDataTable->FindRow<FCardData>(RowName, ContextString);
                ACardBase* CardBase = Cast<ACardBase>(Card);
                CardBase->Init(*CardData);
            }
            TotalNum = 0;
        }
        if (Second)
        {
            TotalNum = 24;
            for (int i = 0; i < TotalNum; i++)
            {
                const FActorSpawnParameters ActorSpawnParameters;
                Location += CardSpacingDirVector;
                AActor* Card = GetWorld()->SpawnActor(CardUClass, &Location, &Rotator, ActorSpawnParameters);
                int CardID = 200 + i + 1;
                FName RowName = FName(*FString::FromInt(CardID));
                FString ContextString = TEXT("FCardData::FindCardData");
                FCardData* CardData = CardDataTable->FindRow<FCardData>(RowName, ContextString);
                ACardBase* CardBase = Cast<ACardBase>(Card);
                CardBase->Init(*CardData);
            }
            TotalNum = 0;
        }
        if (Third)
        {
            TotalNum = 24;
            for (int i = 0; i < TotalNum; i++)
            {
                const FActorSpawnParameters ActorSpawnParameters;
                Location += CardSpacingDirVector;
                AActor* Card = GetWorld()->SpawnActor(CardUClass, &Location, &Rotator, ActorSpawnParameters);
                int CardID = 300 + i + 1;
                FName RowName = FName(*FString::FromInt(CardID));
                FString ContextString = TEXT("FCardData::FindCardData");
                FCardData* CardData = CardDataTable->FindRow<FCardData>(RowName, ContextString);
                ACardBase* CardBase = Cast<ACardBase>(Card);
                CardBase->Init(*CardData);
            }
            TotalNum = 0;
        }
    }
}
