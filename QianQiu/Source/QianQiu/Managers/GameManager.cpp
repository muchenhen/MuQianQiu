// Fill out your copyright notice in the Description page of Project Settings.


#include "GameManager.h"

#include "DataManager.h"
#include "Kismet/GameplayStatics.h"
#include "Kismet/KismetMathLibrary.h"

DEFINE_LOG_CATEGORY(LogGameManager);


void UGameManager::BeginGame()
{
    // 初始化玩家
    if (!IsValid(PlayerA))
    {
        PlayerA = GetWorld()->SpawnActor<AQianQiuKe>();
    }
    if (!IsValid(PlayerB))
    {
        PlayerB = GetWorld()->SpawnActor<AQianQiuKe>();
    }
    // 初始化公共卡池
    if (!IsValid(PublicCardsHolder))
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

void UGameManager::SetSeasonCardSelected(const ACardBase* CardActor)
{
    const FString CardSeason = CardActor->CardData.Season;
    TArray<ACardBase*> PublicShowCards;
    PublicCardsHolder->GetNowPublicShowCardsBySeason(CardSeason, PublicShowCards);
    for (ACardBase* PublicShowCard : PublicShowCards)
    {
        PublicShowCard->SetCardChoosing(true);
    }
}

void UGameManager::OnCardChoose(ACardBase* CardActor)
{
    if (!IsValid(CardActor))
    {
        UE_LOG(LogTemp, Error, TEXT("GameManager::OnCardChoose() - CardActor is invalid!"));
        return;
    }
    // 首先确认选中的卡牌是属于谁的
    const ECardBelongType CardBelongType = CardActor->CardBelongType;
    // TODO:完成选中的逻辑
    // 目前没有玩家正在选中自己的手牌
    if (!GetIsPlayerChoosing())
    {
        // 当前是玩家选中了自己的手牌
        if (CardBelongType == ECardBelongType::PlayerA)
        {
            // 将公共卡池中展示出来的和当前选中的卡牌同季节的卡牌设置为选中状态
            SetSeasonCardSelected(CardActor);
            bIsPlayerAChoosing = true;
            CurrentPlayerChooseCard = CardActor;
            CardActor->SetCardChoosing(true);
        }
    }
    // 当前玩家已经选中了一张牌
    else
    {
        // 玩家选择公共卡池中展示出来的牌
        if (CardBelongType == ECardBelongType::PublicShow)
        {
            if (bIsPlayerAChoosing)
            {
                // 将玩家选中的牌和玩家现在选择的公共卡池中展示出来的牌都送进玩家的故事牌堆
                // 修改牌的所属
                CurrentPlayerChooseCard->SetCardBelongType(ECardBelongType::PlayerAScore);
                CardActor->SetCardBelongType(ECardBelongType::PlayerAScore);
                // 修改牌的所属数组
                PlayerA->SetCardToStory(CurrentPlayerChooseCard);
                PlayerA->SetCardToStory(CardActor);
                PlayerA->RemoveCardFromHands(CurrentPlayerChooseCard);
                PlayerA->RemoveCardFromHands(CardActor);
                // 去掉holder public show中的牌
                PublicCardsHolder->RemoveCardFromPublicShow(CardActor);
                // 补充holder public show中的牌
                PublicCardsHolder->SupplementedPublicShow();
                // 修改牌的位置
                CurrentPlayerChooseCard->SetActorTransform(UDataManager::GetStoryDeckTransform(ECardBelongType::PlayerAScore));
                CardActor->SetActorTransform(UDataManager::GetStoryDeckTransform(ECardBelongType::PlayerAScore));
                // 完成了一次选择 消除选中状态
                SetAllCardsUnSelected();
                // 结束已经有玩家在选中自己的手牌的状态
                bIsPlayerAChoosing = false;
                // 玩家回合结束
                ChangeRound();
            }
        }
        else if (CardBelongType == ECardBelongType::PlayerA)
        {
            const int CardID = CardActor->CardData.CardID;
            const int CurrentPlayerChooseCardID = CurrentPlayerChooseCard->CardData.CardID;
            // 再次选择相同的牌则取消所有选择
            if (CardID == CurrentPlayerChooseCardID)
            {
                SetAllCardsUnSelected();
                bIsPlayerAChoosing = false;
                CurrentPlayerChooseCard = nullptr;
                return;
            }
            else
            {
                SetAllCardsUnSelected();
                CardActor->SetCardChoosing(true);
                SetSeasonCardSelected(CardActor);
                bIsPlayerAChoosing = true;
                CurrentPlayerChooseCard = CardActor;
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
    const FTransform TransformPStoreTop = UDataManager::GetCardTransform("PStoreTop");
    const FTransform TransformPStoreBottom = UDataManager::GetCardTransform("PStoreBottom");
    const int CardNum = AllInitCardsID.Num();
    int IndexA = 1;
    int IndexB = 1;

    // AllInitCardsID 
    for (int i = 0; i < CardNum; i++)
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
        }

        if (!Card)
        {
            UE_LOG(LogTemp, Error, TEXT("GameManager::InitSendCards() - Card is invalid!"));
        }

        Card->OnPlayerChooseCard.AddDynamic(this, &UGameManager::OnCardChoose);

        // 从0开始，位置从TransformPStoreTop累计到TransformPStoreBottom，设置牌的位置
        float LerpValue = static_cast<float>(i / CardNum);

        FTransform Transform = UKismetMathLibrary::TLerp(TransformPStoreTop, TransformPStoreBottom, LerpValue, ELerpInterpolationMode::QuatInterp);
        Card->SetActorTransform(Transform);

        // i < 20, 为玩家手牌，按照奇偶数给两个玩家发牌
        // TODO: 需要保存一下随机发给两位玩家的牌的ID，在播放场景加载的sequence的时候给这几个ID对应的Actor做不同的表现
        if (i < 20)
        {
            if (i % 2 == 0)
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
            Card->SetCardBelongType(ECardBelongType::Public);
        }
    }

    // 初始化玩家手牌的位置
    auto CardsA = PlayerA->GetPlayerCardInHands();
    for (TTuple<int, ACardBase*> ACard : CardsA)
    {
        auto Card = ACard.Value;
        Card->SetCardBelongType(ECardBelongType::PlayerA);
        FTransform Transform = UDataManager::GetCardTransformByPlayerPositionAndIndex("A", IndexA);
        Card->SetActorTransform(Transform);
        IndexA++;
    }

    auto CardsB = PlayerB->GetPlayerCardInHands();
    for (TTuple<int, ACardBase*> BCard : CardsB)
    {
        auto Card = BCard.Value;
        Card->SetCardBelongType(ECardBelongType::PlayerB);
        FTransform Transform = UDataManager::GetCardTransformByPlayerPositionAndIndex("B", IndexB);
        Card->SetActorTransform(Transform);
        IndexB++;
    }
    // 初始化公共卡池的位置
    PublicCardsHolder->DealCardToPublicShowOnInit();
}

void UGameManager::SetAllCardsUnSelected()
{
    for (auto Card : Cards)
    {
        Card.Value->SetCardChoosing(false);
    }
}

void UGameManager::ChangeRound()
{
    CurrentRound++;
    // 判断当前是哪个玩家的回合 偶数为A 奇数为B
    if (CurrentRound % 2 == 0)
    {
    }
    else
    {
        if (PlayerB)
        {
            if (PlayerB->GetIsAI())
            {
                PlayerB->AIActionSimple();
            }
        }
    }
}

bool UGameManager::GetIsPlayerChoosing()
{
    return bIsPlayerAChoosing || bIsPlayerBChoosing;
}
