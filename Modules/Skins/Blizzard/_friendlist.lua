local Module = Phoenix_UI:NewModule("Skins.Friendlist");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(AddFriendEntryFrame, true)
        Phoenix_UI:Skin(AddFriendFrame.Border, true)
        Phoenix_UI:Skin(FriendsFrame, true)
        Phoenix_UI:Skin(FriendsFrame.NineSlice, true)
        Phoenix_UI:Skin(FriendsFrameInset, true)
        Phoenix_UI:Skin(FriendsFrameInset.NineSlice, true)
        Phoenix_UI:Skin(FriendsFriendsFrame, true)
        Phoenix_UI:Skin(FriendsFriendsFrame.Border, true)
        Phoenix_UI:Skin(RecruitAFriendFrame, true)
        Phoenix_UI:Skin(RecruitAFriendFrame.RecruitList, true)
        Phoenix_UI:Skin(RecruitAFriendFrame.RecruitList.Header, true)
        Phoenix_UI:Skin(RecruitAFriendFrame.RecruitList.ScrollFrameInset, true)
        Phoenix_UI:Skin(RecruitAFriendFrame.RecruitList.ScrollFrameInset.NineSlice, true)
        Phoenix_UI:Skin(RecruitAFriendFrame.RewardClaiming, true)
        Phoenix_UI:Skin(RecruitAFriendFrame.RewardClaiming.Inset, true)
        Phoenix_UI:Skin(RecruitAFriendFrame.RewardClaiming.Inset.NineSlice, true)
        Phoenix_UI:Skin(RecruitAFriendRecruitmentFrame, true)
        Phoenix_UI:Skin(RecruitAFriendRecruitmentFrame.Border, true)
        Phoenix_UI:Skin(WhoFrameListInset, true)
        Phoenix_UI:Skin(WhoFrameListInset.NineSlice, true)
        Phoenix_UI:Skin(WhoFrameEditBoxInset, true)
        Phoenix_UI:Skin(WhoFrameEditBoxInset.NineSlice, true)
        Phoenix_UI:Skin(FriendsFrameBattlenetFrame.BroadcastFrame, true)
        Phoenix_UI:Skin(FriendsFrameBattlenetFrame.BroadcastFrame.Border, true)

        -- Tabs
        Phoenix_UI:Skin(FriendsTabHeaderTab1, true)
        Phoenix_UI:Skin(FriendsTabHeaderTab2, true)
        Phoenix_UI:Skin(FriendsTabHeaderTab3, true)
        Phoenix_UI:Skin(FriendsFrameTab1, true)
        Phoenix_UI:Skin(FriendsFrameTab2, true)
        Phoenix_UI:Skin(FriendsFrameTab3, true)
        Phoenix_UI:Skin(FriendsFrameTab4, true)
    end
end



