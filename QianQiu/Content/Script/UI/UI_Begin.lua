--
-- DESCRIPTION
--
-- @COMPANY ZhiMengTech
-- @AUTHOR Muchenhen
-- @DATE 2022年3月13日19:11:47
--

require "UnLua"


local UI_Begin = Class()

function UI_Begin:Initialize(Initializer)
end

function UI_Begin:PreConstruct(IsDesignTime)
    self.StoryOne = true
    self.CheckBox_One:SetIsChecked(true)
    print("黑衣少侠传 载入")
    self.StoryTwo = true
    self.CheckBox_Two:SetIsChecked(true)
    print("蓝衫偃师记 载入")

    self.StoryThree = false

    self.GameMode = EGameMode.Classic
    print("当前模式 标准模式")

    self.bEnemyDark = true

    self.bPlayAudio = true
end

function UI_Begin:Construct()
    self.CheckBox_One.OnCheckStateChanged:Add(self, self.OnOneChooseChanged)
    self.CheckBox_Two.OnCheckStateChanged:Add(self, self.OnTwoChooseChanged)
    self.CheckBox_Three.OnCheckStateChanged:Add(self, self.OnThreeChooseChanged)


    self.Button_Normal.OnClicked:Add(self, self.OnNormalClick)
    self.Button_Monster.OnClicked:Add(self, self.OnMonsterClick)
    self.Button_OnlyMonster.OnClicked:Add(self, self.OnOnlyMonsterClick)

    self.Button_Dark.OnClicked:Add(self, self.OnDarkClick)
    self.Button_Light.OnClicked:Add(self, self.OnLightClick)
    
    self.Button_Slience.OnClicked:Add(self, self.OnSlienceClick)
    self.Button_Voice.OnClicked:Add(self, self.OnVoiceClick)

    self.Button_Begin.OnClicked:Add(self, self.StartGame)
end

function UI_Begin:OnOneChooseChanged()
    if self.CheckBox_One:IsChecked() then
        self.CheckBox_One:SetIsChecked(true)
        self.StoryOne = true
        print("黑衣少侠传 载入")
    else
        self.CheckBox_One:SetIsChecked(false)
        self.StoryOne = false
        print("黑衣少侠传 卸载")
    end
end

function UI_Begin:OnTwoChooseChanged()
    if self.CheckBox_Two:IsChecked() then
        self.CheckBox_Two:SetIsChecked(true)
        self.StoryOne = true
        print("蓝衫偃师记 载入")
    else
        self.CheckBox_Two:SetIsChecked(false)
        self.StoryOne = false
        print("蓝衫偃师记 卸载")
    end
end

function UI_Begin:OnThreeChooseChanged()
    if self.CheckBox_Three:IsChecked() then
        self.CheckBox_Three:SetIsChecked(true)
        self.StoryOne = true
        print("首山梦时书 载入")
    else
        self.CheckBox_Three:SetIsChecked(false)
        self.StoryOne = false
        print("首山梦时书 卸载")
    end
end

function UI_Begin:OnNormalClick()
    if self.GameMode == EGameMode.Classic then
        return
    end
    self:ChangeGameMode(EGameMode.Classic)
    print("模式选择：普通模式")
end

function UI_Begin:OnMonsterClick()
    if self.GameMode == EGameMode.Monster then
        return
    end
    self:ChangeGameMode(EGameMode.Monster)
    print("模式选择：撒野模式")
end

function UI_Begin:OnOnlyMonsterClick()
    if self.GameMode == EGameMode.OnlyExtra then
        return
    end
    self:ChangeGameMode(EGameMode.OnlyExtra)
    print("模式选择：仅撒野模式")
end

function UI_Begin:OnDarkClick()
    if self.bEnemyDark then
        return
    end
    self:ChangeCardDark()
    print("对手暗牌")
end

function UI_Begin:OnLightClick()
    if not self.bEnemyDark then
        return
    end
    self:ChangeCardDark()
    print("对手明牌")
end

function UI_Begin:OnSlienceClick()
    if not self.bPlayAudio then
        return
    end
    self:ChangeSlience()
    print("故事静音")
end

function UI_Begin:OnVoiceClick()
    if self.bPlayAudio then
        return
    end
    self:ChangeSlience()
    print("捅刀子plus")
end

function UI_Begin:StartGame()
    -- local MapName = "OneTwo"
    -- GameplayStatics.OpenLevel(self, MapName, true, "")

    local Tag = "QianQiuManager"
    local QianQiuManager = QianQiuBlueprintFunctionLibrary:GetActorByTag(self, Tag)
    if QianQiuManager ~= nil then
        print("开始游戏")
    end
end

function UI_Begin:ChangeCardDark()
    if self.bEnemyDark then
        self.bEnemyDark = false
        self:PlayAnimation(self.C12, 0, 1, 0, 1, false)
    else
        self.bEnemyDark = true
        self:PlayAnimation(self.C12, 0, 1, 1, 1, false)
    end
end

function UI_Begin:ChangeSlience()
    if self.bPlayAudio then
        self.bPlayAudio = false
        self:PlayAnimation(self.D12, 0, 1, 0, 1, false)
    else
        self.bPlayAudio = true
        self:PlayAnimation(self.D12, 0, 1, 1, 1, false)
    end
end

function UI_Begin:ChangeGameMode(AimMode)
    if self.GameMode == EGameMode.Classic then
        if AimMode == EGameMode.Monster then
            self.GameMode = EGameMode.Monster
            self.bNormalStory = true
            self.bStoryExtra = true
            self:PlayAnimation(self.B12, 0, 1, 0, 1, false)
        elseif AimMode == EGameMode.OnlyExtra then
            self.GameMode = EGameMode.OnlyExtra
            self.bNormalStory = false
            self.bStoryExtra = true
            self:PlayAnimation(self.B13, 0, 1, 0, 1, false)
        end
    elseif self.GameMode == EGameMode.Monster then
        if AimMode == EGameMode.Classic then
            self.GameMode = EGameMode.Classic
            self.bNormalStory = true
            self.bStoryExtra = false    
            self:PlayAnimation(self.B12, 0, 1, 1, 1, false)
        else
            self.GameMode = EGameMode.OnlyExtra
            self.bNormalStory = false
            self.bStoryExtra = true    
            self:PlayAnimation(self.B23, 0, 1, 0, 1, false)
        end
    elseif self.GameMode == EGameMode.OnlyExtra then
        if AimMode == EGameMode.Classic then
            self.GameMode = EGameMode.Classic
            self.bNormalStory = true
            self.bStoryExtra = false    
            self:PlayAnimation(self.B13, 0, 1, 1, 1, false)
        else
            self.GameMode = EGameMode.Monster
            self.bNormalStory = true
            self.bStoryExtra = true    
            self:PlayAnimation(self.B23, 0, 1, 1, 1, false)
        end
    end
end

--function UI/UI_Begin:Tick(MyGeometry, InDeltaTime)
--end

return UI_Begin
