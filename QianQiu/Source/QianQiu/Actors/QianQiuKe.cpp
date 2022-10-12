// Fill out your copyright notice in the Description page of Project Settings.


#include "QianQiuKe.h"

#include "QianQiuBlueprintFunctionLibrary.h"
#include "QianQiu/Managers/DataManager.h"

void AQianQiuKe::ResetQianQiuKe()
{
    PlayerCardInHands.Empty();
    PlayerCardInStory.Empty();
    PlayerCardInSpecial.Empty();
    Score = 0;
}

// Sets default values
AQianQiuKe::AQianQiuKe()
{
    // Set this character to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
    PrimaryActorTick.bCanEverTick = true;
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

// Called to bind functionality to input
void AQianQiuKe::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
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

void AQianQiuKe::UpdateHandCardsTransform()
{
    if (PlayerCardInHands.IsEmpty())
    {
        return;
    }
    const FTransform StartTransform = UDataManager::GetCardTransform("PlayerAHandFirst");
    const FTransform EndTransform = UDataManager::GetCardTransform("PlayerAHandLast");
    const float X = (EndTransform.GetTranslation().X - StartTransform.GetTranslation().X) / PlayerCardInHands.Num();
    const float Y = (EndTransform.GetTranslation().Y - StartTransform.GetTranslation().Y) / PlayerCardInHands.Num();
    int i = 0;
    for (const auto& Card : PlayerCardInHands)
    {
        FTransform Transform = StartTransform;
        auto Translation = Transform.GetTranslation();
        Translation.X += i*X;
        Translation.Y += i*Y;
        Transform.SetTranslation(Translation);
        Card.Value->SetActorTransform(Transform);
        i++;
    }
}

void AQianQiuKe::SetCardToSpecial(ACardBase* CardBase)
{
}
