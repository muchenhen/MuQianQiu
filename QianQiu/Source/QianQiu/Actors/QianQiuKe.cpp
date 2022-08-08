// Fill out your copyright notice in the Description page of Project Settings.


#include "QianQiuKe.h"

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
        PlayerCardInHands.Add(CardID, CardBase);
    }
}

void AQianQiuKe::SetCardsToStory(TArray<ACardBase*> Cards)
{
    for (const auto& Card: Cards)
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
}

void AQianQiuKe::SetCardToSpecial(ACardBase* CardBase)
{
}

