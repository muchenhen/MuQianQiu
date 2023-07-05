// Fill out your copyright notice in the Description page of Project Settings.


#include "DataManager.h"

TSharedPtr<UDataTable> UDataManager::CardDataTable;

UDataManager::UDataManager()
{
    if (!CardDataTable.IsValid())
    {
        if (UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/DT_Cards.DT_Cards'")))
        {
            CardDataTable = MakeShareable(DataTable);
        }
    }
}

FCardData UDataManager::GetCardData(int CardID)
{
    if (CardID != 0)
    {
        const FName RowID = FName(*FString::FromInt(CardID));
        const FString ContextString = TEXT("FCardData::FindCardData");
        if (CardDataTable.IsValid())
        {
            FCardData* CardData = CardDataTable->FindRow<FCardData>(RowID, ContextString);
            return *CardData;
        }
    }
    return FCardData();
}