// Fill out your copyright notice in the Description page of Project Settings.


#include "DataManager.h"

#include "Kismet/GameplayStatics.h"

DEFINE_LOG_CATEGORY(LogCardManager);

TSharedPtr<UDataTable> UDataManager::CardDataTable;
TSharedPtr<UDataTable> UDataManager::StoryDataTable;
TSharedPtr<UDataTable> UDataManager::CardTransformTable;


UDataManager::UDataManager()
{
}

UDataManager::~UDataManager()
{
}


void UDataManager::LoadCardData()
{
    if (CardDataTable.IsValid())
    {
        return;
    }
    if (UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/TB_Cards.TB_Cards'")))
    {
        CardDataTable = MakeShareable(DataTable);
        UE_LOG(LogCardManager, Display, TEXT("LoadCardData Success."));
    }
    else
    {
        UE_LOG(LogCardManager, Error, TEXT("LoadCardData Faild."));
    }
}

void UDataManager::LoadCardTransform()
{
    if (CardTransformTable.IsValid())
    {
        return;
    }
    if (UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/TB_Transforms.TB_Transforms'")))
    {
        CardTransformTable = MakeShareable(DataTable);
        UE_LOG(LogCardManager, Display, TEXT("LoadCardData Success."));
    }
    else
    {
        UE_LOG(LogCardManager, Error, TEXT("LoadCardData Faild."));
    }
}

FCardData UDataManager::GetCardData(const int& CardID)
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

FTransform UDataManager::GetCardTransform(const FString& TransformName)
{
    if (!TransformName.IsEmpty())
    {
        const FName RowID = FName(*TransformName);
        const FString ContextString = TEXT("FTransform::GetCardTransform");
        if (CardTransformTable.IsValid())
        {
            if (FCardPosition* CardPosition = CardTransformTable->FindRow<FCardPosition>(RowID, ContextString))
            {
                return CardPosition->CardTransform;
            }
        }
    }
    return FTransform();
}

FTransform UDataManager::GetCardTransformByPlayerPositionAndIndex(const FString& PlayerPosition, int Index)
{
    if (PlayerPosition == "A")
    {
        FString Name;
        if (Index <= 9)
        {
            Name = "A0" + FString::FromInt(Index);
        }
        else
        {
            Name = "A" + FString::FromInt(Index);
        }
        return GetCardTransform(Name);
    }
    else if (PlayerPosition == "B")
    {
        FString Name;
        if (Index <= 9)
        {
            Name = "B0" + FString::FromInt(Index);
        }
        else
        {
            Name = "B" + FString::FromInt(Index);
        }
        return GetCardTransform(Name);
    }
    else if(PlayerPosition == "P")
    {
        if (Index <= 9)
        {
            const FString Name = "P0" + FString::FromInt(Index);
            return GetCardTransform(Name);
        }
    }
    return FTransform::Identity;
}

void UDataManager::GetAllCardsInLevel()
{
    // TArray<AActor*> Actors;
    // UGameplayStatics::GetAllActorsOfClass(GetWorld(), ACardBase::StaticClass(), Actors);
    // for (const auto& Card: Actors)
    // {
    //     ACardBase* CardBase = Cast<ACardBase>(Card);
    //     int CardID = CardBase->CardData.CardID;
    //     CardsInLevel.Add(CardID, CardBase);
    // }
}

void UDataManager::GetCardsIDByGameMode(EGameMode GameMode, TArray<int32>& CardsID, bool bGetSpecialCard = false)
{
    if (!CardDataTable.IsValid())
    {
        return;
    }
    const FString ContextString = TEXT("FCardData::FindCardData");
    TArray<FCardData*> CardDatas;
    CardDataTable->GetAllRows<FCardData>(ContextString, CardDatas);
    if (GameMode == EGameMode::BC)
    {
        for (const auto& CardData : CardDatas)
        {
            if ((CardData->CardID / 100 == 2 || CardData->CardID / 100 == 3) && bGetSpecialCard == CardData->Special)
            {
                CardsID.Add(CardData->CardID);
            }
        }
    }
    else if (GameMode == EGameMode::AB)
    {
        for (const auto& CardData : CardDatas)
        {
            if ((CardData->CardID / 100 == 2 || CardData->CardID / 100 == 1) && bGetSpecialCard == CardData->Special)
            {
                CardsID.Add(CardData->CardID);
            }
        }
    }
    else if (GameMode == EGameMode::AC)
    {
        for (const auto& CardData : CardDatas)
        {
            if ((CardData->CardID / 100 == 1 || CardData->CardID / 100 == 3) && bGetSpecialCard == CardData->Special)
            {
                CardsID.Add(CardData->CardID);
            }
        }
    }
}

void UDataManager::RandomCardsID(TArray<int32>& CardsID)
{
    for (int i = 0; i < CardsID.Num(); i++)
    {
        const int32 Index = CardsID.Num() - i - 1 > 0 ? CardsID.Num() - i - 1 : 0;
        const int32 RandomPos = FMath::RandRange(0, Index);
        const int32 a = CardsID[CardsID.Num() - 1];
        const int32 b = CardsID[RandomPos];
        CardsID[CardsID.Num() - 1] = b;
        CardsID[RandomPos] = a;
    }
}

void UDataManager::GetRandomCardsIDByGameMode(EGameMode GameMode, TArray<int32>& CardsID)
{
    GetCardsIDByGameMode(GameMode, CardsID, false);
    RandomCardsID(CardsID);
}
