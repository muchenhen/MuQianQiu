// Fill out your copyright notice in the Description page of Project Settings.


#include "GameManager.h"

#include "DataManager.h"
#include "Kismet/GameplayStatics.h"

DEFINE_LOG_CATEGORY(LogGameManager);


void UGameManager::BeginGame()
{
    // 初始化玩家
    if (! IsValid(PlayerA))
    {
        PlayerA = GetWorld()->SpawnActor<AQianQiuKe>();
    }
    if (! IsValid(PlayerB))
    {
        PlayerB = GetWorld()->SpawnActor<AQianQiuKe>();
    }
    // 初始化公共卡池
    if (! IsValid(PublicCardsHolder))
    {
        PublicCardsHolder = GetWorld()->SpawnActor<APublicCardsHolder>();
    }
    // 玩家对象都存在的情况下进行重置
    if (IsValid(PlayerA) && IsValid(PlayerB) && IsValid(PublicCardsHolder))
    {
        PlayerA->ResetQianQiuKe();
        PlayerB->ResetQianQiuKe();
        PublicCardsHolder->ResetPublicCardsHolder();
    }
    else
    {
        UE_LOG(LogTemp, Error, TEXT("GameManager::BeginGame() - PlayerA or PlayerB or PublicCardsHolder is invalid!"));
        return;
    }
    // 准备当前的场景中的Actors
    if (Cards.IsEmpty())
    {
        GetCardsInScene();
    }
    // 初始化卡牌ID
    InitCards();
    // 发牌 并设置卡牌的位置
    InitSendCards();
}

void UGameManager::InitCards()
{
    UDataManager::GetRandomCardsIDByGameMode(GameMode, AllInitCardsID);
}

void UGameManager::GetCardsInScene()
{
    TArray<AActor*> AllActors;
    UGameplayStatics::GetAllActorsOfClass(GetWorld(), ACardBase::StaticClass(), AllActors);
    for (const auto& Actor : AllActors)
    {
        if (IsValid(Actor))
        {
            if (ACardBase* Card = Cast<ACardBase>(Actor); IsValid(Card))
            {
                Cards.Add(Card->CardData.CardID, Card);
            }
        }
    }
}

/*
 * 在前面的函数中，我们已经初始化了所有的牌的ID，现在我们需要将这些牌的ID分配给玩家和公共牌的Holder
 * 由于场景中动画的需要，已经创建过所有的Actor，这里需要按照ID去获取到对应的Actor
 * 给玩家分配之后，刷新玩家牌的位置
 */
void UGameManager::InitSendCards()
{
    for(int i = 0; i < AllInitCardsID.Num(); i++)
    {
        const int32 CardID = AllInitCardsID[i];
        ACardBase* Card;
        if (Cards.Find(CardID))
        {
            Card = Cards[CardID];
        }
        else
        {
            Card = GetWorld()->SpawnActor<ACardBase>();
            Card->Init(CardID);
            UE_LOG(LogGameManager, Error, TEXT("GameManager::InitSendCards() - CardID: %d is not in Cards!"), CardID);
        }
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
    PlayerA->UpdateHandCardsTransform(TEXT("PlayerAHandFirst"), TEXT("PlayerAHandLast"));
    PlayerB->UpdateHandCardsTransform(TEXT("PlayerBHandFirst"), TEXT("PlayerBHandLast"));
    PublicCardsHolder->UpdatePublicCardsHolderTransform(TEXT("PublicCardsHolderTop"), TEXT("PublicCardsHolderButtom"));
    PublicCardsHolder->SetAllShowCardTransform();
}

void UGameManager::ShowPublicCards()
{
    if (IsValid(PublicCardsHolder))
    {
        PublicCardsHolder->DealCardToPublicShowOnInit();
    }
}
