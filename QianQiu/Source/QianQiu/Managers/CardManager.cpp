// Fill out your copyright notice in the Description page of Project Settings.


#include "CardManager.h"

static TSharedPtr<UDataTable> CardDataTable;


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
