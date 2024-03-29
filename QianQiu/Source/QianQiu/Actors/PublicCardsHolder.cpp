// Fill out your copyright notice in the Description page of Project Settings.


#include "PublicCardsHolder.h"

#include "QianQiu/Managers/DataManager.h"


// Sets default values
APublicCardsHolder::APublicCardsHolder()
{
    // Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
    PrimaryActorTick.bCanEverTick = true;
}

// Called every frame
void APublicCardsHolder::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

// Called when the game starts or when spawned
void APublicCardsHolder::BeginPlay()
{
    Super::BeginPlay();
}

void APublicCardsHolder::ResetPublicCardsHolder()
{
    PublicCards.Empty();
}

void APublicCardsHolder::SetCardToPublicCardsHolder(ACardBase* CardBase)
{
    if (IsValid(CardBase))
    {
        PublicCards.Add(CardBase->CardData.CardID, CardBase);
    }
}

void APublicCardsHolder::DealCardToPublicShowOnInit()
{
    // 使用迭代器遍历PublicCards 将前8张从PublicCards中移除到PublicCardsShow中
    int Count = 1;
    for (auto It = PublicCards.CreateIterator(); It; ++It)
    {
        if (Count <= 8)
        {
            ACardBase* Card = It->Value;
            PublicCardsShow.Add(Count, Card);
            // 按照季节分别存储到SpringCardsShow SummerCardsShow AutumnCardsShow WinterCardsShow中
            if (Card->CardData.Season == TEXT("春"))
            {
                SpringCardsShow.Add(Card);
            }
            else if (Card->CardData.Season == TEXT("夏"))
            {
                SummerCardsShow.Add(Card);
            }
            else if (Card->CardData.Season == TEXT("秋"))
            {
                AutumnCardsShow.Add(Card);
            }
            else if (Card->CardData.Season == TEXT("冬"))
            {
                WinterCardsShow.Add(Card);
            }
            FTransform Transform = UDataManager::GetCardTransformByPlayerPositionAndIndex("P", Count);
            Card->SetActorTransform(Transform);
            Card->SetCardBelongType(ECardBelongType::PublicShow);
            It.RemoveCurrent();
            Count++;
        }
        else
        {
            break;
        }
    }
}

void APublicCardsHolder::SupplementedPublicShow()
{
    if (PublicCardsShow.Num() == 8)
    {
        return;
    }
    // 查找PublicCardsShow 缺少 1-8 的哪个key
    TArray<int> IndexArray;
    TArray<int> Keys;
    PublicCardsShow.GetKeys(Keys);
    for (int i = 1; i <= 8; i++)
    {
        if (!Keys.Contains(i))
        {
            IndexArray.Add(i);
        }
    }
    // 从PublicCards中取出IndexArray张补充到PublicCardsShow中
    for (int i = 0; i < IndexArray.Num(); i++)
    {
        int Index = IndexArray[i];
        if (PublicCards.Num() > 0)
        {
            auto It = PublicCards.CreateIterator();
            ACardBase* Card = It->Value;
            PublicCardsShow.Add(Index, Card);
            AddCardToSeasonShow(Card);
            FTransform Transform = UDataManager::GetCardTransformByPlayerPositionAndIndex("P", Index);
            Card->SetActorTransform(Transform);
            Card->SetCardBelongType(ECardBelongType::PublicShow);
            It.RemoveCurrent();
        }
    }
}

void APublicCardsHolder::GetNowPublicShowCardsBySeason(const FString& Season, TArray<ACardBase*>& OutCards)
{
    if (Season == TEXT("春"))
    {
        OutCards = SpringCardsShow;
    }
    else if (Season == TEXT("夏"))
    {
        OutCards = SummerCardsShow;
    }
    else if (Season == TEXT("秋"))
    {
        OutCards = AutumnCardsShow;
    }
    else if (Season == TEXT("冬"))
    {
        OutCards = WinterCardsShow;
    }
}

void APublicCardsHolder::RemoveCardFromPublicShow(ACardBase* Card)
{
    if (IsValid(Card))
    {
        const int* Index = PublicCardsShow.FindKey(Card);
        if (Index)
        {
            PublicCardsShow.Remove(*Index);
        }
        if (Card->CardData.Season == TEXT("春"))
        {
            SpringCardsShow.Remove(Card);
        }
        else if (Card->CardData.Season == TEXT("夏"))
        {
            SummerCardsShow.Remove(Card);
        }
        else if (Card->CardData.Season == TEXT("秋"))
        {
            AutumnCardsShow.Remove(Card);
        }
        else if (Card->CardData.Season == TEXT("冬"))
        {
            WinterCardsShow.Remove(Card);
        }
    }
}

void APublicCardsHolder::AddCardToSeasonShow(ACardBase* Card)
{
    if (IsValid(Card))
    {
        if (Card->CardData.Season == TEXT("春"))
        {
            SpringCardsShow.Add(Card);
        }
        else if (Card->CardData.Season == TEXT("夏"))
        {
            SummerCardsShow.Add(Card);
        }
        else if (Card->CardData.Season == TEXT("秋"))
        {
            AutumnCardsShow.Add(Card);
        }
        else if (Card->CardData.Season == TEXT("冬"))
        {
            WinterCardsShow.Add(Card);
        }
    }
}
