// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class QianQiu : ModuleRules
{
	public QianQiu(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "WebSockets" });
		PrivateDependencyModuleNames.AddRange(new string[] { "slua_unreal", "Slate", "SlateCore", "UMG" });
		PrivateIncludePathModuleNames.AddRange(new string[] { "slua_unreal" });
		PublicIncludePathModuleNames.AddRange(new string[] { "slua_unreal" });
		// Uncomment if you are using Slate UI
		// PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore" });

		// Uncomment if you are using online features
		// PrivateDependencyModuleNames.Add("OnlineSubsystem");

		// To include OnlineSubsystemSteam, add it to the plugins section in your uproject file with the Enabled attribute set to true
	}
}
