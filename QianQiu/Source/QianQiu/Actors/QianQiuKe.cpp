// Fill out your copyright notice in the Description page of Project Settings.


#include "QianQiuKe.h"
#include "QianQiu/Managers/DataManager.h"

void AQianQiuKe::ResetQianQiuKe()
{
    PlayerCardInHands.Empty();
    PlayerCardInStory.Empty();
    PlayerCardInSpecial.Empty();
    Score = 0;
}

// Called when the game starts or when spawned
void AQianQiuKe::BeginPlay()
{
    Super::BeginPlay();
}

// Called every frame
void AQianQiuKe::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void AQianQiuKe::AddScore(const int& ScoreIncreased)
{
    Score += ScoreIncreased;
}

void AQianQiuKe::SetScore(const int& InScore)
{
    Score = InScore;
}

void AQianQiuKe::SetCardToStory(ACardBase* CardBase)
{
    if (IsValid(CardBase))
    {
        const int& CardID = CardBase->CardData.CardID;
        PlayerCardInStory.Add(CardID, CardBase);
    }
}

void AQianQiuKe::SetCardsToStory(TArray<ACardBase*> Cards)
{
    for (const auto& Card : Cards)
    {
        SetCardToStory(Card);
    }
}

TMap<int, ACardBase*> AQianQiuKe::GetCardsInStory()
{
    return PlayerCardInStory;
}

void AQianQiuKe::SetCardToHands(ACardBase* CardBase)
{
    if (IsValid(CardBase) && PlayerCardInHands.Num() < 10)
    {
        PlayerCardInHands.Add(CardBase->CardData.CardID, CardBase);
    }
}

void AQianQiuKe::InitHandCardTransformPlayAnim(FString HandFirst, FString HandLast)
{
    if (PlayerCardInHands.IsEmpty())
    {
        return;
    }

    TMap<ACardBase*, FTransform> CardTargetTransform;
    
    const FTransform StartTransform = UDataManager::GetCardTransform(HandFirst);
    const FTransform EndTransform = UDataManager::GetCardTransform(HandLast);
    InitCollectHandCardsTransform(StartTransform, EndTransform,CardTargetTransform);
    if (CardTargetTransform.Num() > 0)
    {
        for (const auto& Item : CardTargetTransform)
        {
            if (IsValid(Item.Key))
            {
                Item.Key->PlayCardMoveAnim(Item.Value, EMoveState::MoveTransform);
                Item.Key->SetFixedTransform(Item.Value);
            }
        }
    }
}

void AQianQiuKe::InitCollectHandCardsTransform(FTransform StartTransform, FTransform EndTransform, TMap<ACardBase*, FTransform>& CardTargetTransform)
{
    TArray<FTransform> TargetTransforms;
    const float X = (EndTransform.GetTranslation().X - StartTransform.GetTranslation().X) / PlayerCardInHands.Num();
    const float Y = (EndTransform.GetTranslation().Y - StartTransform.GetTranslation().Y) / PlayerCardInHands.Num();
    const float Z = (EndTransform.GetTranslation().Z - StartTransform.GetTranslation().Z) / PlayerCardInHands.Num();
    int i = 0;
    for (const auto& Card : PlayerCardInHands)
    {
        FTransform Transform = StartTransform;
        auto Translation = Transform.GetTranslation();
        Translation.X += i*X;
        Translation.Y += i*Y;
        Translation.Z += i*Z;
        Transform.SetTranslation(Translation);
        CardTargetTransform.Add(Card.Value, Transform);
        i++;
    }
}

void AQianQiuKe::SetCardToSpecial(ACardBase* CardBase)
{
}

TMap<int, ACardBase*> AQianQiuKe::GetPlayerCardInHands()
{
    return PlayerCardInHands;
}
