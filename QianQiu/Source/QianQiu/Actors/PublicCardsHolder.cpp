// Fill out your copyright notice in the Description page of Project Settings.


#include "PublicCardsHolder.h"

#include "QianQiu/Managers/DataManager.h"


// Sets default values
APublicCardsHolder::APublicCardsHolder()
{
    // Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
    PrimaryActorTick.bCanEverTick = true;
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

void APublicCardsHolder::DealCardToPublicShow()
{
}

// Called every frame
void APublicCardsHolder::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void APublicCardsHolder::UpdatePublicCardsHolderTransform(const FString PublicCardsHolderTop, const FString PublicCardsHolderButtom)
{
    TMap<ACardBase*, FTransform> CardTargetTransform;
    
    const FTransform StartTransform = UDataManager::GetCardTransform(PublicCardsHolderTop);
    const FTransform EndTransform = UDataManager::GetCardTransform(PublicCardsHolderButtom);
    
    TArray<FTransform> TargetTransforms;
    const float X = (EndTransform.GetTranslation().X - StartTransform.GetTranslation().X) / PublicCards.Num();
    const float Y = (EndTransform.GetTranslation().Y - StartTransform.GetTranslation().Y) / PublicCards.Num();
    const float Z = (EndTransform.GetTranslation().Z - StartTransform.GetTranslation().Z) / PublicCards.Num();
    int i = 0;
    for (const auto& Card : PublicCards)
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
    if (CardTargetTransform.Num() > 0)
    {
        for (const auto& Item : CardTargetTransform)
        {
            if (IsValid(Item.Key))
            {
                Item.Key->PlayCardMoveAnim(Item.Value);
            }
        }
    }
}

void APublicCardsHolder::SetAllShowCardTransform()
{
    const FTransform FirstTransform = UDataManager::GetCardTransform(TEXT("FirstShowCardTransform"));
    const FTransform SecondTransform = UDataManager::GetCardTransform(TEXT("SecondShowCardTransform"));
    const FTransform ThirdTransform = UDataManager::GetCardTransform(TEXT("ThirdShowCardTransform"));
    const FTransform FourthTransform = UDataManager::GetCardTransform(TEXT("FourthShowCardTransform"));
    const FTransform FifthTransform = UDataManager::GetCardTransform(TEXT("FifthShowCardTransform"));
    const FTransform SixthTransform = UDataManager::GetCardTransform(TEXT("SixthShowCardTransform"));
    const FTransform SeventhTransform = UDataManager::GetCardTransform(TEXT("SeventhShowCardTransform"));
    const FTransform EighthTransform = UDataManager::GetCardTransform(TEXT("EighthShowCardTransform"));
    const FTransform NinthTransform = UDataManager::GetCardTransform(TEXT("NinthShowCardTransform"));
    const FTransform TenthTransform = UDataManager::GetCardTransform(TEXT("TenthShowCardTransform"));

    FirstShowCardTransform.Add(nullptr, FirstTransform);
    FirstShowCardTransform.Add(nullptr, SecondTransform);
    FirstShowCardTransform.Add(nullptr, ThirdTransform);
    FirstShowCardTransform.Add(nullptr, FourthTransform);
    FirstShowCardTransform.Add(nullptr, FifthTransform);
    FirstShowCardTransform.Add(nullptr, SixthTransform);
    FirstShowCardTransform.Add(nullptr, SeventhTransform);
    FirstShowCardTransform.Add(nullptr, EighthTransform);
    FirstShowCardTransform.Add(nullptr, NinthTransform);
    FirstShowCardTransform.Add(nullptr, TenthTransform);
}

