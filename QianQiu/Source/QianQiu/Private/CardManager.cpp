// Fill out your copyright notice in the Description page of Project Settings.


#include "CardManager.h"

void UCardManager::LoadCardData()
{
	auto DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Tables/TB_Cards.TB_Cards'"));
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
