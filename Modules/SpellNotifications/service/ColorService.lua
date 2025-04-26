local _, SpellNotifications = ...

-- Colors for the printed messages
SpellNotifications.colors = {
    DISPELLED    = "FF69CCF0",
    STOLEN       = "FF9482C9",
    INTERRUPTED  = "FFFF8000",
    RESISTED     = "FFFF2020",
    WHITE        = "FFFFFFFF"
}

-- Text sizes for different parts of the message
SpellNotifications.sizes = {
    NAME   = "20",
    ICON   = "12",
    RANK   = "11",
    DESC   = "12",
    CREDITS = "11"
} 