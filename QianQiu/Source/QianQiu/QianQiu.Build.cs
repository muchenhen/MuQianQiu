// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class QianQiu : ModuleRules
{
	public QianQiu(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "WebSockets", "UnLua" });
		PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore", "UMG", "UnLua" });
		PrivateIncludePathModuleNames.AddRange(new string[] { "UnLua" });
		PublicIncludePathModuleNames.AddRange(new string[] { "UnLua" });
		// Uncomment if you are using Slate UI
		// PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore" });

		// Uncomment if you are using online features
		// PrivateDependencyModuleNames.Add("OnlineSubsystem");

		// To include OnlineSubsystemSteam, add it to the plugins section in your uproject file with the Enabled attribute set to true
	}
}
