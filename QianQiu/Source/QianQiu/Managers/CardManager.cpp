// Fill out your copyright notice in the Description page of Project Settings.


#include "CardManager.h"

#include "Kismet/GameplayStatics.h"

static TSharedPtr<UDataTable> CardDataTable;


UCardManager::UCardManager()
{
}

UCardManager::UCardManager(TMap<int, bool> Versions)
{
    VersionMap = Versions;
}

UCardManager::~UCardManager()
{
}

void UCardManager::LoadCardData()
{
	UDataTable* DataTable = LoadObject<UDataTable>(NULL, UTF8_TO_TCHAR("DataTable'/Game/Table/TB_Cards.TB_Cards'"));
	if(DataTable)
		CardDataTable = MakeShareable(DataTable);
}

FCardData UCardManager::GetCardData(const int& CardID)
{
	if(CardID != 0)
	{
		FName RowID = FName(*FString::FromInt(CardID));
		FString ContextString = TEXT("FCardData::FindCardData");
		if(CardDataTable.IsValid())
		{
			FCardData* CardData = CardDataTable->FindRow<FCardData>(RowID, ContextString);
			return *CardData;
		}
	}
	return FCardData();
}

void UCardManager::GetAllCardsInLevel()
{
    TArray<AActor*> Actors;
    UGameplayStatics::GetAllActorsOfClass(GetWorld(), ACardBase::StaticClass(), Actors);
    for (const auto& Card: Actors)
    {
        ACardBase* CardBase = Cast<ACardBase>(Card);
        int CardID = CardBase->CardData.CardID;
        CardsInLevel.Add(CardID, CardBase);
    }
}
