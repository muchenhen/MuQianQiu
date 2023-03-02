// Fill out your copyright notice in the Description page of Project Settings.


#include "QianQiuGameMVVM.h"

void UQianQiuGameMVVM::SetPlayerAScore(int32 Value)
{
    PlayerAScore = Value;
}

int32 UQianQiuGameMVVM::GetPlayerAScore() const
{
    return PlayerAScore;
}

void UQianQiuGameMVVM::SetPlayerBScore(int32 Value)
{
    PlayerAScore = Value;
}

int32 UQianQiuGameMVVM::GetPlayerBScore() const
{
    return PlayerBScore;
}
