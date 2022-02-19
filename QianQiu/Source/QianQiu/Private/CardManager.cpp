// Fill out your copyright notice in the Description page of Project Settings.


#include "CardManager.h"

void UCardManager::LoadCardData()
{
	auto CardTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Tables/TB_Cards.TB_Cards'"));
}
