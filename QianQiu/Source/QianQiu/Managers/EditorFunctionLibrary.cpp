// Fill out your copyright notice in the Description page of Project Settings.

#include "EditorFunctionLibrary.h"

#include "DataManager.h"
#include "Kismet/GameplayStatics.h"
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
            TotalNum = 28;
            for (int i = 0; i < TotalNum; i++)
            {
                int32 CardID = 100 + i + 1;
                FActorSpawnParameters ActorSpawnParameters;
                FString ActorName = "Card" + FString::FromInt(CardID);
                ActorSpawnParameters.Name = FName(*ActorName);
                Location += CardSpacingDirVector;
                CreateCard(CardUClass, CardID, Location, Rotator, ActorSpawnParameters);
            }
            TotalNum = 0;
        }
        if (Second)
        {
            TotalNum = 28;
            for (int i = 0; i < TotalNum; i++)
            {
                int32 CardID = 200 + i + 1;
                FActorSpawnParameters ActorSpawnParameters;
                FString ActorName = "Card" + FString::FromInt(CardID);
                ActorSpawnParameters.Name = FName(*ActorName);
                Location += CardSpacingDirVector;
                CreateCard(CardUClass, CardID, Location, Rotator, ActorSpawnParameters);
            }
            TotalNum = 0;
        }
        if (Third)
        {
            TotalNum = 28;
            for (int i = 0; i < TotalNum; i++)
            {
                int32 CardID = 300 + i + 1;
                FActorSpawnParameters ActorSpawnParameters;
                FString ActorName = "Card" + FString::FromInt(CardID);
                ActorSpawnParameters.Name = FName(*ActorName);
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

void AUEditorFunctionLibrary::RenameAllCards()
{
    TArray<AActor*> Actors;
    UGameplayStatics::GetAllActorsOfClass(GetWorld(), ACardBase::StaticClass(), Actors);
    int i = 0;
    for (const auto& Actor : Actors)
    {
        FString Name = FString::Printf(TEXT("Card_%d"), i);
        Actor->SetActorLabel(Name, false);
        i++;
    }
}

void AUEditorFunctionLibrary::RandomInitCards()
{
    TArray<AActor*> Actors;
    TArray<int> CardsID;
    UGameplayStatics::GetAllActorsOfClass(GetWorld(), ACardBase::StaticClass(), Actors);
    EGameMode Game;
    if (First && Second)
    {
        Game = EGameMode::AB;
    }
    else if (First && Third)
    {
        Game = EGameMode::AC;
    }
    else
    {
        Game = EGameMode::BC;
    }

    const FString ContextString = TEXT("FCardData::FindCardData");
    TArray<FCardData*> CardDatas;
    TArray<FCardData> Datas;
    CardDataTable->GetAllRows<FCardData>(ContextString, CardDatas);
    for (const auto& CardData : CardDatas)
    {
        if (CardData->Special)
        {
            continue;
        }
        if (Game == EGameMode::BC && (CardData->CardID / 100 == 2 || CardData->CardID / 100 == 3))
        {
            CardsID.Add(CardData->CardID);
            Datas.Add(*CardData);
        }
        else if (Game == EGameMode::AB && (CardData->CardID / 100 == 2 || CardData->CardID / 100 == 1))
        {
            CardsID.Add(CardData->CardID);
            Datas.Add(*CardData);
        }
        else if (Game == EGameMode::AC && (CardData->CardID / 100 == 1 || CardData->CardID / 100 == 3))
        {
            CardsID.Add(CardData->CardID);
            Datas.Add(*CardData);
        }
    }

    UDataManager::RandomCardsID(CardsID);

    auto FindData = [Datas](const int& i) {
        FCardData CardData;
        for (auto& Data : Datas)
        {
            if (Data.CardID == i) CardData = Data;
        }
        return CardData;
    };

    if (Actors.Num() == CardsID.Num())
    {
        for (int i = 0; i < Actors.Num(); i++)
        {
            if (ACardBase* Card = Cast<ACardBase>(Actors[i]))
            {
                Card->Init(FindData(CardsID[i]));
            }
        }
    }
}

void AUEditorFunctionLibrary::ReadStoryCSVtoDataTable(UDataTable* DataTable, FString CSVPath)
{
    if (DataTable)
    {
        DataTable->EmptyTable();
        TArray<FString> FileContent;
        // 将UTF-8 CSV文件读取到FileContent中
        FFileHelper::LoadFileToStringArray(FileContent, *CSVPath);
        // 从第二行开始读取
        // 1,厨房功夫,风晴雪;焦炭;谢衣,102;128;206,10,A01
        // int FString TArray<FString> TArray<int> int FString
        // 
        for (int i = 1; i < FileContent.Num(); i++)
        {
            FString Line = FileContent[i];
            TArray<FString> LineArray;
            Line.ParseIntoArray(LineArray, TEXT(","), true);

            FStoryData StoryData;
            StoryData.Name = LineArray[1];
            TArray<FString> CardsNameArray;
            LineArray[2].ParseIntoArray(CardsNameArray, TEXT(";"), true);
            TArray<FString> CardsIDArray;
            LineArray[3].ParseIntoArray(CardsIDArray, TEXT(";"), true);
            TArray<int> CardsIDArrayInt;
            for (const auto& CardID : CardsIDArray)
            {
                CardsIDArrayInt.Add(FCString::Atoi(*CardID));
            }
            StoryData.CardsName = CardsNameArray;
            StoryData.CardsID = CardsIDArrayInt;
            StoryData.Score = FCString::Atoi(*LineArray[4]);
            StoryData.AudioID = LineArray[5];
            // i to FName
            const FName RowName = FName(*FString::FromInt(i));
            DataTable->AddRow(RowName, StoryData);
        }
    }
}
