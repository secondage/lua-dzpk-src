--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/10/20
-- Time: 9:29
-- To change this template use File | Settings | File Templates.
--

local Attribute = {}

Attribute.gameUserPos = {
    [0] = { x = 568, y  = 162 },
    [1] = { x = 856, y = 162 },
    [2] = { x = 1052, y = 298 },
    [3] = { x = 1000, y = 500 },
    [4] = { x = 772, y = 550 },
    [5] = { x = 363, y = 550 },
    [6] = { x = 136, y = 500 },
    [7] = { x = 84, y = 298 },
    [8] = { x = 280, y = 162 },
}

Attribute.gameUserCurBetPos = {
    [0] = { x = 514.58, y  = 260.535 },
    [1] = { x = 804.58, y = 260.535 },
    [2] = { x = 998.58, y = 396.535 },
    [3] = { x = 946.58, y = 398.535 },
    [4] = { x = 718.58, y = 448.535 },
    [5] = { x = 309.58, y = 448.535 },
    [6] = { x = 82.58, y = 398.535 },
    [7] = { x = 30.58, y = 396.535 },
    [8] = { x = 226.58, y = 260.535 },
}

Attribute.OtherCardRes = {
    CardBack = "#back-card.png",
    CardFace = "#face-card.png",
}

Attribute.CardTypes = {
    [0] = {Normal = "#spade.png", Small = "#spade_s.png" },
    [1] = {Normal = "#heart.png", Small = "#heart_s.png" },
    [2] = {Normal = "#club.png", Small = "#club_s.png" },
    [3] = {Normal = "#diamond.png", Small = "#diamond_s.png" }
}

Attribute.CardValue_Red = {
    "#r-A.png",
    "#r-2.png",
    "#r-3.png",
    "#r-4.png",
    "#r-5.png",
    "#r-6.png",
    "#r-7.png",
    "#r-8.png",
    "#r-9.png",
    "#r-10.png",
    "#r-J.png",
    "#r-Q.png",
    "#r-K.png",
    joker = "#r-joker.png",
}

Attribute.CardValue_Black = {
    "#b-A.png",
    "#b-2.png",
    "#b-3.png",
    "#b-4.png",
    "#b-5.png",
    "#b-6.png",
    "#b-7.png",
    "#b-8.png",
    "#b-9.png",
    "#b-10.png",
    "#b-J.png",
    "#b-Q.png",
    "#b-K.png",
    joker = "#b-joker.png",
}

Attribute.CardImg_Black = {                   --牌面图片
    J_Img = "#b-J-image.png",
    Q_Img = "#b-Q-image.png",
    K_Img = "#b-K-image.png",
    joker_Img = "#b-joker-image.png",
}

Attribute.CardImg_Red = {                   --牌面图片
    J_Img = "#r-J-image.png",
    Q_Img = "#r-Q-image.png",
    K_Img = "#r-K-image.png",
    joker_Img = "#r-joker-image.png",
}

Attribute.CardsInterval = {
    x = 27,
    y = 0
}

Attribute.PublicCardsPos = {
    [0] = {x = 385, y = 350},
    [1] = {x = 473, y = 350},
    [2] = {x = 561, y = 350},
    [3] = {x = 655, y = 350},
    [4] = {x = 751, y = 350}
}

Attribute.chipRes = {
   "#chip_0.png",
   "#chip_1.png",
   "#chip_2.png",
   "#chip_3.png",
   "#chip_4.png",
   "#chip_5.png",
   "#chip_6.png",
   "#chip_7.png",
   "#chip_8.png",
   "#chip_9.png",
   "#chip_10.png",
   "#chip_11.png",
   "#chip_12.png",
   "#chip_13.png",
   "#chip_14.png",
   "#chip_15.png",
}

Attribute.RoundEndPos = {x = 568, y = 307 }

Attribute.ChipPoolPos = {
    [0] = {x = 404, y = 419},
    [1] = {x = 568, y = 419},
    [2] = {x = 720, y = 419},
    [3] = {x = 860, y = 349},
    [4] = {x = 720, y = 280},
    [5] = {x = 568, y = 280},
    [6] = {x = 404, y = 280},
    [7] = {x = 274, y = 364},
    [8] = {x = 274, y = 334},
}

Attribute.EndTypeRes = {
    "#Single.png",
    "#Double.png",
    "#DoubleTwo.png",
    "#Three.png",
    "#SingleLoong.png",
    "#SameColor.png",
    "#ThreeTwo.png",
    "#Four.png",
    "#SameLoong.png",
    "#GodSameLoong.png",
}
return Attribute

