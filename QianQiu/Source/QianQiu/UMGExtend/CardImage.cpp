// Fill out your copyright notice in the Description page of Project Settings.


#include "CardImage.h"

#include "CardManager.h"

void UCardImage::SetCard(int CardID)
{
	FCardData CardData = UCardManager::GetCardData(CardID);
	if (CardData.CardID == CardID)
	{
		auto Brush = LoadObject<UTexture>(NULL, UTF8_TO_TCHAR(""));
	}
}
