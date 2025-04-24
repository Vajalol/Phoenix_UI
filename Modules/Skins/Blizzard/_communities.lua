local Module = Phoenix_UI:NewModule("Skins.Communities");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(CommunitiesFrame, true)
        Phoenix_UI:Skin(CommunitiesFrame.GuildMemberDetailFrame, true)
        Phoenix_UI:Skin(CommunitiesFrame.GuildMemberDetailFrame.Border, true)
        Phoenix_UI:Skin(CommunitiesFrame.ChatEditBox, true)
        Phoenix_UI:Skin(CommunitiesFrame.Chat.InsetFrame, true)
        Phoenix_UI:Skin(CommunitiesFrame.Chat.InsetFrame.NineSlice, true)
        Phoenix_UI:Skin(CommunitiesFrame.MemberList.InsetFrame, true)
        Phoenix_UI:Skin(CommunitiesFrame.MemberList.InsetFrame.NineSlice, true)
        Phoenix_UI:Skin(CommunitiesFrame.NineSlice, true)
        Phoenix_UI:Skin(CommunitiesFrame.MemberList.ColumnDisplay, true)
        Phoenix_UI:Skin(CommunitiesFrameInset, true)
        Phoenix_UI:Skin(CommunitiesFrameInset.NineSlice, true)
        Phoenix_UI:Skin(CommunitiesFrameCommunitiesList, true)
        Phoenix_UI:Skin(CommunitiesFrameCommunitiesList.InsetFrame, true)
        Phoenix_UI:Skin(CommunitiesFrameCommunitiesList.InsetFrame.NineSlice, true)
        Phoenix_UI:Skin(CommunitiesFrameGuildDetailsFrame, true)
        Phoenix_UI:Skin(CommunitiesFrame.GuildBenefitsFrame, true)
        Phoenix_UI:Skin(ClubFinderGuildFinderFrame.InsetFrame, true)
        Phoenix_UI:Skin(ClubFinderGuildFinderFrame.InsetFrame.NineSlice, true)
        Phoenix_UI:Skin(ClubFinderCommunityAndGuildFinderFrame.InsetFrame, true)
        Phoenix_UI:Skin(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.NineSlice, true)
        Phoenix_UI:Skin({
            CommunitiesFrameCommunitiesListListScrollFrameThumbTexture,
            CommunitiesFrameCommunitiesListListScrollFrameTop,
            CommunitiesFrameCommunitiesListListScrollFrameMiddle,
            CommunitiesFrameCommunitiesListListScrollFrameBottom
        }, true, true)
    end
end



