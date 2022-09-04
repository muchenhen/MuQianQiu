// Fill out your copyright notice in the Description page of Project Settings.


#include "GameManager.h"

#include "CardManager.h"

void UGameManager::BeginGame()
{
    const FVector Pos(0, 0, 0);
    const FRotator Rot(0, 0, 0);
    if (! IsValid(PlayerA))
    {
        PlayerA = GetWorld()->SpawnActor<AQianQiuKe>(Pos, Rot);
    }
    if (! IsValid(PlayerB))
    {
        PlayerB = GetWorld()->SpawnActor<AQianQiuKe>(Pos, Rot);
    }
    if (! IsValid(PublicCardsHolder))
    {
        PublicCardsHolder = GetWorld()->SpawnActor<APublicCardsHolder>(Pos, Rot);
    }
    if (IsValid(PlayerA) && IsValid(PlayerB))
    {
        PlayerA->ResetQianQiuKe();
        PlayerB->ResetQianQiuKe();
        PublicCardsHolder->ResetPublicCardsHolder();
    }
}

void UGameManager::InitCards()
{
    TArray<int32> CardsID;
    UCardManager::GetCardsIDByGameMode(GameMode, CardsID);

    for (int i = 0; i < CardsID.Num(); i++)
    {
        int32 index = CardsID.Num() - i - 1 > 0 ? CardsID.Num() - i - 1 : 0;
        int32 RandomPos = FMath::RandRange(0, index);
        int32 a = CardsID[CardsID.Num() - 1];
        int32 b = CardsID[RandomPos];
        CardsID[CardsID.Num() - 1] = b;
        CardsID[RandomPos] = a;
    }

    AllInitCardsID = CardsID;
}

void UGameManager::SendCardsToPlayer()
{
    for(int i = 0; i < AllInitCardsID.Num() - 1; i++)
    {
        int32 CardID = AllInitCardsID[i];
        ACardBase* Card = GetWorld()->SpawnActor<ACardBase>();
        Card->Init(CardID);
        // i < 20, 为玩家手牌，按照奇偶数给两个玩家发牌
        if(i < 20)
        {
            if(i % 2 == 0)
            {
                PlayerB->SetCardToHands(Card);
            }
            else
            {
                PlayerA->SetCardToHands(Card);
            }
        }
        // 后面的全数给到公共卡池
        
    }
    PlayerA->UpdateHandCardsTransform();
}
