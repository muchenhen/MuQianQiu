// Fill out your copyright notice in the Description page of Project Settings.


#include "GameManager.h"

#include "DataManager.h"

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
    UDataManager::GetRandomCardsIDByGameMode(GameMode, AllInitCardsID);
}

/*
 * 在前面的函数中，我们已经初始化了所有的牌的ID，现在我们需要将这些牌的ID分配给玩家和公共牌的Holder
 * 由于场景中动画的需要，已经创建过所有的Actor，这里需要按照ID去获取到对应的Actor
 * 给玩家分配之后，刷新玩家牌的位置
 */
void UGameManager::InitSendCards()
{
    for(int i = 0; i < AllInitCardsID.Num() - 1; i++)
    {
        int32 CardID = AllInitCardsID[i];
        // TODO：已经改成了场景中初始化好了的Actor，这里不需要再创建了
        ACardBase* Card = GetWorld()->SpawnActor<ACardBase>();
        Card->Init(CardID);
        // i < 20, 为玩家手牌，按照奇偶数给两个玩家发牌
        // TODO: 需要保存一下随机发给两位玩家的牌的ID，在播放场景加载的sequence的时候给这几个ID对应的Actor做不同的表现
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
        else
        {
            PublicCardsHolder->SetCardToPublicCardsHolder(Card);
        }
        
    }
    PlayerA->UpdateHandCardsTransform();
}
