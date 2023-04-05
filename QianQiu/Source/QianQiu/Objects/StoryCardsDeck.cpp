// Fill out your copyright notice in the Description page of Project Settings.


#include "StoryCardsDeck.h"

void UStoryCardsDeck::SetCardToDeck(ACardBase* Card)
{
    if (IsValid(Card))
    {
        Cards.Add(Card);
    }
}

void UStoryCardsDeck::UpdateScore()
{
}

int UStoryCardsDeck::GetScore()
{
}
