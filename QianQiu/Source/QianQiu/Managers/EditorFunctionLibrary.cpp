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
                int CardID = 100 + i + 1;
                FActorSpawnParameters ActorSpawnParameters;
                FName ActorName = *FString(FString(TEXT("Card") + FString(FString::FromInt(CardID))));
                ActorSpawnParameters.Name = ActorName;
                Location += CardSpacingDirVector;
                CreateCard(CardUClass, CardID, Location, Rotator, ActorSpawnParameters);
            }
            TotalNum = 0;
        }
        if (Second)
        {
            TotalNum = 24;
            for (int i = 0; i < TotalNum; i++)
            {
                int CardID = 200 + i + 1;
                FActorSpawnParameters ActorSpawnParameters;
                FName ActorName = FName(*FString::FromInt(CardID));
                ActorSpawnParameters.Name = ActorName;
                Location += CardSpacingDirVector;
                CreateCard(CardUClass, CardID, Location, Rotator, ActorSpawnParameters);
            }
            TotalNum = 0;
        }
        if (Third)
        {
            TotalNum = 24;
            for (int i = 0; i < TotalNum; i++)
            {
                int CardID = 300 + i + 1;
                FActorSpawnParameters ActorSpawnParameters;
                FName ActorName = *FString(FString(TEXT("Card") + FString(FString::FromInt(CardID))));
                ActorSpawnParameters.Name = ActorName;
                Location += CardSpacingDirVector;
                CreateCard(CardUClass, CardID, Location, Rotator, ActorSpawnParameters);
            }
            TotalNum = 0;
        }
    }
}

void AUEditorFunctionLibrary::CreateCard(UClass* CardUClass, const int& CardID, const FVector& Location, const FRotator& Rotator, const FActorSpawnParameters& ActorSpawnParameters)
{
    AActor* Card = GetWorld()->SpawnActor(CardUClass, &Location, &Rotator, ActorSpawnParameters);
    const FName RowName = FName(*FString::FromInt(CardID));
    const FString ContextString = TEXT("FCardData::FindCardData");
    const FCardData* CardData = CardDataTable->FindRow<FCardData>(RowName, ContextString);
    ACardBase* CardBase = Cast<ACardBase>(Card);
    CardBase->Init(*CardData);
}
