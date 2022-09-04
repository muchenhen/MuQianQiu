// Fill out your copyright notice in the Description page of Project Settings.


#include "CardManager.h"

#include "Kismet/GameplayStatics.h"

DEFINE_LOG_CATEGORY(LogCardManager);

TSharedPtr<UDataTable> UCardManager::CardDataTable;
TSharedPtr<UDataTable> UCardManager::StoryDataTable;
TSharedPtr<UDataTable> UCardManager::CardTransformTable;



UCardManager::UCardManager()
{
}

UCardManager::~UCardManager()
{
}


void UCardManager::LoadCardData()
{
    if (CardDataTable.IsValid())
    {
        return;
    }
    if(UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/TB_Cards.TB_Cards'")))
    {
        CardDataTable = MakeShareable(DataTable);
        UE_LOG(LogCardManager, Display, TEXT("LoadCardData Success."));
    }
    else
    {
        UE_LOG(LogCardManager, Error, TEXT("LoadCardData Faild."));
    }
}

void UCardManager::LoadCardTransform()
{
    if (CardTransformTable.IsValid())
    {
        return;
    }
    if(UDataTable* DataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/TB_Transforms.TB_Transforms'")))
    {
        CardTransformTable = MakeShareable(DataTable);
        UE_LOG(LogCardManager, Display, TEXT("LoadCardData Success."));
    }
    else
    {
        UE_LOG(LogCardManager, Error, TEXT("LoadCardData Faild."));
    }
}

FCardData UCardManager::GetCardData(const int& CardID)
{
	if(CardID != 0)
	{
        const FName RowID = FName(*FString::FromInt(CardID));
        const FString ContextString = TEXT("FCardData::FindCardData");
		if(CardDataTable.IsValid())
		{
			FCardData* CardData = CardDataTable->FindRow<FCardData>(RowID, ContextString);
			return *CardData;
		}
	}
	return FCardData();
}

FTransform UCardManager::GetCardTransform(const FString& TransformName)
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
    return  FTransform();
}

void UCardManager::GetAllCardsInLevel()
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

void UCardManager::GetCardsIDByGameMode(EGameMode GameMode, TArray<int32>& CardsID)
{
    if (!CardDataTable.IsValid())
    {
        return;
    }
    if (GameMode == EGameMode::BC)
    {
        const FString ContextString = TEXT("FCardData::FindCardData");
        TArray<FCardData*> CardDatas;
        CardDataTable->GetAllRows<FCardData>(ContextString, CardDatas);
        for (auto& CardData :CardDatas)
        {
            if (CardData->CardID / 100 == 2 || CardData->CardID / 100 == 3)
            {
                CardsID.Add(CardData->CardID);
            }
        }
    }
}
