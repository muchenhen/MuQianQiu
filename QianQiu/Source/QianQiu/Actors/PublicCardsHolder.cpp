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
    int i = 1;
    for (auto& Item : PublicCardShowTransforms)
    {
        if (!IsValid(Item.Value.Card))
        {
            Item.Value.Card = DealCardToPublicShow();
            if (IsValid(Item.Value.Card))
            {
                ACardBase* Card = Item.Value.Card;
                const FTransform Transform = Item.Value.Transform;
                FTimerDelegate TimerDelegate;
                FTimerHandle ATimerHandle;
                TimerDelegate.BindUFunction(this, FName(TEXT("MoveCardTranslation")), Card, Transform, ATimerHandle);
                GetWorld()->GetTimerManager().SetTimer(ATimerHandle, TimerDelegate, 0.5f * i , false);

                FTimerDelegate RotateDelegate;
                FTimerHandle RotateTimerHandle;
                RotateDelegate.BindUFunction(this, FName(TEXT("MoveCardRotation")), Card, Transform, ATimerHandle);
                GetWorld()->GetTimerManager().SetTimer(RotateTimerHandle, RotateDelegate, 0.5f * i + 2.0f, false);
                i++;

                Card->SetFixedTransform(Transform);
            }
        }
    }
}

void APublicCardsHolder::MoveCardTranslation(ACardBase* Card, FTransform Transform, FTimerHandle InTimerHandle)
{
    Card->PlayCardMoveAnim(Transform, EMoveState::MoveTransition);
    GetWorld()->GetTimerManager().ClearTimer(InTimerHandle);
}


void APublicCardsHolder::MoveCardRotation(ACardBase* Card, FTransform Transform, FTimerHandle InTimerHandle)
{
    Card->PlayCardMoveAnim(Transform, EMoveState::MoveRotation);
    GetWorld()->GetTimerManager().ClearTimer(InTimerHandle);
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
    const FTransform PublicShowCardFirst = UDataManager::GetCardTransform(TEXT("PublicShowCardFirst"));
    const FTransform PublicShowCardLast = UDataManager::GetCardTransform(TEXT("PublicShowCardLast"));

    TArray<FTransform> TargetTransforms;
    const float X = (PublicShowCardLast.GetTranslation().X - PublicShowCardFirst.GetTranslation().X) / 10;
    const float Y = (PublicShowCardLast.GetTranslation().Y - PublicShowCardFirst.GetTranslation().Y) / 10;
    const float Z = (PublicShowCardLast.GetTranslation().Z - PublicShowCardFirst.GetTranslation().Z) / 10;
    
    for (int i = 1; i <= 10; i++)
    {
        FPublicCardShowTransform PublicCardShowTransform;
        FTransform Transform = PublicShowCardFirst;
        auto Translation = Transform.GetTranslation();
        Translation.X += (i-1)*X;
        Translation.Y += (i-1)*Y;
        Translation.Z += (i-1)*Z;
        Transform.SetTranslation(Translation);
        
        PublicCardShowTransform.Transform = Transform;
        PublicCardShowTransform.Card = nullptr;
        PublicCardShowTransforms.Add(i, PublicCardShowTransform);
    }
}

