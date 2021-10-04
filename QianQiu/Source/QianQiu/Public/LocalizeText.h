// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "LocalizeText.generated.h"


#define LOCTEXT_NAMESPACE "MuLocSpace"
/**
 * 
 */
UCLASS()
class QIANQIU_API ULocalizeText : public UObject
{
	GENERATED_BODY()

		const FText QianQiuXi = NSLOCTEXT("MuLocSpace","QianQiuXi", "千秋戏");
};

#undef LOCTEXT_NAMESPACE
