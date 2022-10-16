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

void APublicCardsHolder::DealCardToPublicShowOnInit()
{
    for (auto& Item : PublicCardShowTransforms)
    {
        if (!IsValid(Item.Value.Card))
        {
            Item.Value.Card = DealCardToPublicShow();
            if (IsValid(Item.Value.Card))
            {
                ACardBase* Card = Item.Value.Card;
                const FTransform Transform = Item.Value.Transform;
                Card->PlayCardMoveAnim(Transform, EMoveState::MoveTransition);
            }
        }
    }
}

ACardBase* APublicCardsHolder::DealCardToPublicShow()
{
    ACardBase* Card = PublicCards.begin().Value();
    if (IsValid(Card))
    {
        PublicCards.Remove(Card->CardData.CardID);
        return Card;
    }
    return nullptr;
}

// Called every frame
void APublicCardsHolder::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void APublicCardsHolder::UpdatePublicCardsHolderTransform(const FString PublicCardsHolderTop, const FString PublicCardsHolderBottom)
{
    TMap<ACardBase*, FTransform> CardTargetTransform;
    
    const FTransform StartTransform = UDataManager::GetCardTransform(PublicCardsHolderTop);
    const FTransform EndTransform = UDataManager::GetCardTransform(PublicCardsHolderBottom);
    
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
                Item.Key->PlayCardMoveAnim(Item.Value, EMoveState::MoveTransform);
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

    FPublicCardShowTransform PublicCardShowTransformFirst;
    PublicCardShowTransformFirst.Transform = FirstTransform;
    PublicCardShowTransformFirst.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformSecond;
    PublicCardShowTransformSecond.Transform = SecondTransform;
    PublicCardShowTransformSecond.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformThird;
    PublicCardShowTransformThird.Transform = ThirdTransform;
    PublicCardShowTransformThird.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformFourth;
    PublicCardShowTransformFourth.Transform = FourthTransform;
    PublicCardShowTransformFourth.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformFifth;
    PublicCardShowTransformFifth.Transform = FifthTransform;
    PublicCardShowTransformFifth.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformSixth;
    PublicCardShowTransformSixth.Transform = SixthTransform;
    PublicCardShowTransformSixth.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformSeventh;
    PublicCardShowTransformSeventh.Transform = SeventhTransform;
    PublicCardShowTransformSeventh.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformEighth;
    PublicCardShowTransformEighth.Transform = EighthTransform;
    PublicCardShowTransformEighth.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformNinth;
    PublicCardShowTransformNinth.Transform = NinthTransform;
    PublicCardShowTransformNinth.Card = nullptr;
    FPublicCardShowTransform PublicCardShowTransformTenth;
    PublicCardShowTransformTenth.Transform = TenthTransform;
    PublicCardShowTransformTenth.Card = nullptr;

    PublicCardShowTransforms.Add(1, PublicCardShowTransformFirst);
    PublicCardShowTransforms.Add(2, PublicCardShowTransformSecond);
    PublicCardShowTransforms.Add(3, PublicCardShowTransformThird);
    PublicCardShowTransforms.Add(4, PublicCardShowTransformFourth);
    PublicCardShowTransforms.Add(5, PublicCardShowTransformFifth);
    PublicCardShowTransforms.Add(6, PublicCardShowTransformSixth);
    PublicCardShowTransforms.Add(7, PublicCardShowTransformSeventh);
    PublicCardShowTransforms.Add(8, PublicCardShowTransformEighth);
    PublicCardShowTransforms.Add(9, PublicCardShowTransformNinth);
    PublicCardShowTransforms.Add(10, PublicCardShowTransformTenth);
}

