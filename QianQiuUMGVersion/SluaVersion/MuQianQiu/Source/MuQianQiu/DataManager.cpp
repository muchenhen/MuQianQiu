// Fill out your copyright notice in the Description page of Project Settings.


#include "DataManager.h"

TSharedPtr<UDataTable> UDataManager::CardDataTable;
TSharedPtr<UDataTable> UDataManager::StoryDataTable;
TSharedPtr<UDataTable> UDataManager::SkillDataTable;

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
    if (!SkillDataTable.IsValid())
    {
        if (UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/DT_Skills.DT_Skills'")))
        {
            SkillDataTable = MakeShareable(DataTable);
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

FStoryData UDataManager::GetStoryData(int StoryID)
{
    if (StoryID != 0)
    {
        const FName RowID = FName(*FString::FromInt(StoryID));
        const FString ContextString = TEXT("FStoryData::FindStoryData");
        if (StoryDataTable.IsValid())
        {
            FStoryData* StoryData = StoryDataTable->FindRow<FStoryData>(RowID, ContextString);
            return *StoryData;
        }
    }
    return FStoryData();
}

TArray<FCardData> UDataManager::GetAllSpecialCardDatas()
{
    TArray<FCardData*> CardDataArray;
    if (CardDataTable.IsValid())
    {
        CardDataTable->GetAllRows<FCardData>(nullptr, CardDataArray);
    }
    TArray<FCardData> CardData;
    for (int i = 0; i < CardDataArray.Num(); i++)
    {
        if (CardDataArray[i]->Special)
        {
            CardData.Add(*CardDataArray[i]);
        }
    }
    return CardData;
}

FSkillData UDataManager::GetSkillData(int SkillID)
{
    if (SkillID != 0)
    {
        const FName RowID = FName(*FString::FromInt(SkillID));
        const FString ContextString = TEXT("FSkillData::FindSkillData");
        if (SkillDataTable.IsValid())
        {
            FSkillData* SkillData = SkillDataTable->FindRow<FSkillData>(RowID, ContextString);
            return *SkillData;
        }
    }
    return FSkillData();
}