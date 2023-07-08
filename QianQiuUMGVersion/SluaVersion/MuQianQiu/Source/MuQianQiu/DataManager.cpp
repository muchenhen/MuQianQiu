// Fill out your copyright notice in the Description page of Project Settings.


#include "DataManager.h"

TSharedPtr<UDataTable> UDataManager::CardDataTable;
TSharedPtr<UDataTable> UDataManager::StoryDataTable;

UDataManager::UDataManager()
{
    if (!CardDataTable.IsValid())
    {
        if (UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/DT_Cards.DT_Cards'")))
        {
            CardDataTable = MakeShareable(DataTable);
        }
    }
    if (!StoryDataTable.IsValid())
    {
        if (UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/DT_Stories.DT_Stories'")))
        {
            StoryDataTable = MakeShareable(DataTable);
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

TArray<FStoryData> UDataManager::GetAllStoryData()
{
    TArray<FStoryData*> StoryDataArray;
    if (StoryDataTable.IsValid())
    {
        StoryDataTable->GetAllRows<FStoryData>(nullptr, StoryDataArray);
    }
    TArray<FStoryData> StoryData;
    for (int i = 0; i < StoryDataArray.Num(); i++)
    {
        StoryData.Add(*StoryDataArray[i]);
    }
    return StoryData;
}
