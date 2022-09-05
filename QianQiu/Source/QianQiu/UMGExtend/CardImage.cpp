// Fill out your copyright notice in the Description page of Project Settings.


#include "CardImage.h"
#include "MuStructs.h"
#include "QianQiu/Managers/DataManager.h"

void UCardImage::SetCard(const int& CardID)
{
	FCardData CardData = UDataManager::GetCardData(CardID);
	if (CardData.CardID == CardID)
	{
		auto Texture = LoadObject<UTexture2D>(NULL, UTF8_TO_TCHAR("Texture2D'/Game/Texture/Tex_Card_Back.Tex_Card_Back'"));
		SetBrushFromTexture(Texture, true);
	}
}
