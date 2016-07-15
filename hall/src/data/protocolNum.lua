local ProtocolNumber = class("ProtocolNumber")
function ProtocolNumber:ctor(code, uid, pnum, mapid, syncid)
    self.protcolName = {}
    self.protcolNameOfMiniGame = {}
    self.PROTOCOL_PHONE = 51024
    local i = self.PROTOCOL_PHONE - 1
    local function incr(name)
        i = i + 1
        self.protcolName[i] = name
        return i
    end
    self.PL_PHONE_CL_LOGIN_REQ_P = incr("PL_PHONE_CL_LOGIN_REQ_P")
    self.PL_PHONE_LC_LOGIN_ACK_P = incr("PL_PHONE_LC_LOGIN_ACK_P")
    self.CL_PHONE_PHONECODE_REG_REQ_P = incr("CL_PHONE_PHONECODE_REG_REQ_P")
    self.CL_PHONE_CHECK_PHONECODE_P = incr("CL_PHONE_CHECK_PHONECODE_P")
    self.PL_PHONE_AL_LOGIN_ACK_P = incr("PL_PHONE_AL_LOGIN_ACK_P")
    self.PL_PHONE_LM_USERLOGIN_REQ_P = incr("PL_PHONE_LM_USERLOGIN_REQ_P")
    self.PL_PHONE_ML_LOGIN_ACK_P = incr("PL_PHONE_ML_LOGIN_ACK_P")
    self.PL_PHONE_CS_USERLOGIN_REQ_P = incr("PL_PHONE_CS_USERLOGIN_REQ_P")
    self.PL_PHONE_MS_USERLOGIN_ACK_P = incr("PL_PHONE_MS_USERLOGIN_ACK_P")
    self.PL_PHONE_DS_USERLOGIN_ACK_P = incr("PL_PHONE_DS_USERLOGIN_ACK_P")
    self.PL_PHONE_SC_USERLOGIN_ACK_P = incr("PL_PHONE_SC_USERLOGIN_ACK_P")
    self.PL_PHONE_CS_GAMELIST_REQ_P = incr("PL_PHONE_CS_GAMELIST_REQ_P")
    self.PL_PHONE_SC_GAMELIST_ACK_P = incr("PL_PHONE_SC_GAMELIST_ACK_P")
    self.PL_PHONE_CG_LOGIN_REQ_P = incr("PL_PHONE_CG_LOGIN_REQ_P")
    self.PL_PHONE_GC_LOGIN_ACK_P = incr("PL_PHONE_GC_LOGIN_ACK_P")
    self.PL_PHONE_GD_USERLOGIN_REQ_P = incr("PL_PHONE_GD_USERLOGIN_REQ_P")
    self.PL_PHONE_CG_ROOM_USERLIST_P = incr("PL_PHONE_CG_ROOM_USERLIST_P")
    self.PL_PHONE_CG_FAST_JOIN_GAME_REQ_P = incr("PL_PHONE_CG_FAST_JOIN_GAME_REQ_P")
    self.PL_PHONE_CG_FAST_JOIN_GAME_ACK_P = incr("PL_PHONE_CG_FAST_JOIN_GAME_ACK_P")
    self.PL_PHONE_CS_CHANGE_NICKNAME_P = incr("PL_PHONE_CS_CHANGE_NICKNAME_P")
    self.PL_PHONE_GD_CLEAR_BROKEN_RECORD_REQ_P = incr("PL_PHONE_GD_CLEAR_BROKEN_RECORD_REQ_P")
    self.PL_PHONE_GD_GETBESTRESULT_REQ_P = incr("PL_PHONE_GD_GETBESTRESULT_REQ_P")
    self.PL_PHONE_GC_GETBESTRESULT_ACK_P = incr("PL_PHONE_GC_GETBESTRESULT_ACK_P")
    self.PL_PHONE_GD_POINTCARDTYPE_REQ_P = incr("PL_PHONE_GD_POINTCARDTYPE_REQ_P")
    self.PL_PHONE_LD_USEPHONEVALICODELOGIN_REQ_P = incr("PL_PHONE_LD_USEPHONEVALICODELOGIN_REQ_P")
    self.PL_PHONE_DL_USEPHONEVALICODELOGIN_REQ_P = incr("PL_PHONE_DL_USEPHONEVALICODELOGIN_REQ_P")
    self.PL_PHONE_CL_TRAIL_LOGIN_REQ_P = incr("PL_PHONE_CL_TRAIL_LOGIN_REQ_P")
    self.PL_PHONE_CS_APPNAME_GAMELIST_REQ_P = incr("PL_PHONE_CS_APPNAME_GAMELIST_REQ_P")
    self.CL_PHONE_NOPHONECODE_REG_REQ_P = incr("CL_PHONE_NOPHONECODE_REG_REQ_P")
    self.PL_PHONE_IOS_RECHARGE_REQ_P = incr("PL_PHONE_IOS_RECHARGE_REQ_P")
    self.PL_PHONE_GD_IOS_RECHARGE_REQ_P = incr("PL_PHONE_GD_IOS_RECHARGE_REQ_P")
    self.PL_PHONE_IOS_RECHARGE_ACK_P = incr("PL_PHONE_IOS_RECHARGE_ACK_P")
    self.PL_PHONE_IOS_RECHARGEINFO_REQ_P = incr("PL_PHONE_IOS_RECHARGEINFO_REQ_P")
    self.PL_PHONE_IOS_RECHARGEINFO_ACK_P = incr("PL_PHONE_IOS_RECHARGEINFO_ACK_P")
    self.PL_ML_IOSRECHARGEINFO_ACK_P = incr("PL_ML_IOSRECHARGEINFO_ACK_P")                     --返回LOBBYSERVERIOS充值信息
    self.PL_ML_RECHARGEAWARDINFO_ACK_P = incr("PL_ML_RECHARGEAWARDINFO_ACK_P")  --返回LOBBYSERVER 配置的奖励信息
    self.PL_PHONE_LC_SHOWFIRSTINFO_ACK_P = incr("PL_PHONE_LC_SHOWFIRSTINFO_ACK_P")                        --发送给客户端是否显示首冲按钮
    self.PL_PHONE_GETRECHARGEAWARDINFO_REQ_P = incr("PL_PHONE_GETRECHARGEAWARDINFO_REQ_P")                        --获取充值奖励信息请求
    self.PL_PHONE_LD_GETRECHARGEAWARDINFO_REQ_P = incr("PL_PHONE_LD_GETRECHARGEAWARDINFO_REQ_P")                        --获取充值奖励信息
    self.PL_PHONE_DL_GETRECHARGEAWARDINFO_ACK_P = incr("PL_PHONE_DL_GETRECHARGEAWARDINFO_ACK_P")                        --返回充值信息给大厅服务器
    self.PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P = incr("PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P")                        --返回给客户端首冲奖励信息
    self.PL_PHONE_CL_GETRECHARGEAWARD_REQ_P = incr("PL_PHONE_CL_GETRECHARGEAWARD_REQ_P")                        --领取充值奖励申请
    self.PL_PHONE_LC_GETRECHARGEAWARD_ACK_P = incr("PL_PHONE_LC_GETRECHARGEAWARD_ACK_P")                        --大厅服务器返回给充值奖励给客户端
    self.PL_PHONE_LD_RECORDUSERTODAYRANK_REQ_P = incr("PL_PHONE_LD_RECORDUSERTODAYRANK_REQ_P")                        --发送给数据库服务器记录当天的三榜信息
    self.PL_PHONE_DL_RECORDUSERTOTAYRANK_ACK_P = incr("PL_PHONE_DL_RECORDUSERTOTAYRANK_ACK_P")                        --返回给LOBBYSERVER更新排行榜信息结果
    self.PL_PHONE_LD_GETRICHRANK_REQ_P = incr("PL_PHONE_LD_GETRICHRANK_REQ_P")                        --获取财富排行榜请求给数据库服务
    self.PL_PHONE_DL_GETRICHRANK_ACK_P = incr("PL_PHONE_DL_GETRICHRANK_ACK_P")                        --返回获取财富排行榜请求给大厅服务器
    self.PL_PHONE_LD_GETGAINRANK_REQ_P = incr("PL_PHONE_LD_GETGAINRANK_REQ_P")                        --获取盈利排行榜请求给数据库服务
    self.PL_PHONE_DL_GETGAINRANK_ACK_P = incr("PL_PHONE_DL_GETGAINRANK_ACK_P")                        --返回获取盈利排行榜给大厅服务器
    self.PL_PHONE_LD_GETHONORRANK_REQ_P = incr("PL_PHONE_LD_GETHONORRANK_REQ_P")                        --获取声望排行榜请求给数据库服务
    self.PL_PHONE_DL_GETHONORRANK_ACK_P = incr("PL_PHONE_DL_GETHONORRANK_ACK_P")                        --返回获取声望排行榜请求给大厅服务器
    self.PL_PHONE_CL_USERRANK_REQ_P = incr("PL_PHONE_CL_USERRANK_REQ_P")                        --请求玩家排名
    self.PL_PHONE_LC_USERRANK_ACK_P = incr("PL_PHONE_LC_USERRANK_ACK_P")                        --返回玩家排名
    self.PL_PHONE_LC_SELFUSERRANK_ACK_P = incr("PL_PHONE_LC_SELFUSERRANK_ACK_P")                        --返回自己的排名
    self.PL_ML_SIGNINAWARDINFO_ACK_P = incr("PL_ML_SIGNINAWARDINFO_ACK_P")                          --返回LOBBYSERVER 签到配置的奖励信息
    self.PL_PHONE_LC_INISIGNININFO_ACK_P = incr("PL_PHONE_LC_INISIGNININFO_ACK_P")                        --初始化签到信息给客户端
    self.PL_PHONE_CL_SIGNIN_REQ_P = incr("PL_PHONE_CL_SIGNIN_REQ_P")                        --签到请求
    self.PL_PHONE_LC_SIGNIN_ACK_P = incr("PL_PHONE_LC_SIGNIN_ACK_P")
    self.PL_PHONE_CL_CHECKSECONDPASSWORD_REQ_P = incr("PL_PHONE_CL_CHECKSECONDPASSWORD_REQ_P") --检测二级密码
    self.PL_PHONE_LC_CHECKSECONDPASSWORD_ACK_P = incr("PL_PHONE_LC_CHECKSECONDPASSWORD_ACK_P") --返回检测二级密码结果                    --返回签到结果给客户端
    self.PL_PHONE_CL_LOGINSUCESS_FINISHEDTASK_REQ_P = incr("PL_PHONE_CL_LOGINSUCESS_FINISHEDTASK_REQ_P") --登录吉林麻将成功后发送协议执行任务
    self.PL_PHONE_CL_REGSUCESS_REQ_P = incr("PL_PHONE_CL_REGSUCESS_REQ_P") --吉林麻将注册成功发送申请记录数据库
    self.PL_PHONE_AL_LOGINSUCESS_FINISHEDTASK_ACK_P = incr("PL_PHONE_AL_LOGINSUCESS_FINISHEDTASK_ACK_P") --返回吉林麻将注册信息个大厅服务器
    self.PL_PHONE_CL_JUDGEFINISHEDTASK_REQ_P = incr("PL_PHONE_CL_JUDGEFINISHEDTASK_REQ_P") --评价完成任务申请

    self.PL_PHONE_CC_CONNECT_P = self.PROTOCOL_PHONE + 500
    self.protcolName[self.PROTOCOL_PHONE + 500] = "PL_PHONE_CC_CONNECT_P"
    self.PL_PHONE_CC_DISCONNECT_P = incr("PL_PHONE_CC_DISCONNECT_P")

    self.PROTOCOL_SYSTEM = 11024
    i =  self.PROTOCOL_SYSTEM - 1
    self.SS_CONNECT_REQ_P = incr("SS_CONNECT_REQ_P")
    self.SS_CONNECT_ACK_P = incr("SS_CONNECT_ACK_P")
    self.CS_HEARTBEAT_CHECK_P = incr("CS_HEARTBEAT_CHECK_P")
    self.SC_HEARTBEAT_CHECK_P = incr("SC_HEARTBEAT_CHECK_P")


    self.PROTOCOL_GAMECOM = 13024
    i = self.PROTOCOL_GAMECOM - 1
    self.CG_ROOM_USERLIST_P = incr("CG_ROOM_USERLIST_P")    --请求房间人数列表
    self.GC_ROOM_USERLIST_P = incr("GC_ROOM_USERLIST_P")                       --发送房间人数列表给客户端
    self.GC_GAMEUSER_ADD_P = incr("GC_GAMEUSER_ADD_P")                         --添加用户
    self.GC_GAMEUSER_DEL_P = incr("GC_GAMEUSER_DEL_P")                        --删除用户
    self.GC_GAMEUSER_UP_P = incr("GC_GAMEUSER_UP_P")                         --更新用户
    self.GC_TABLE_STATSLIST_P = incr("GC_TABLE_STATSLIST_P")                     --发送桌子状态列表给客户段
    self.GC_TABLE_STATUS_UP_P = incr("GC_TABLE_STATUS_UP_P")                     --更新桌子状态
    self.GC_TABLE_USERLIST_P = incr("GC_TABLE_USERLIST_P")                      --发送桌子用户列表给客户端
    self.CG_ENTERTABLE_REQ_P = incr("CG_ENTERTABLE_REQ_P")                      --玩家请求坐桌子
    self.GC_ENTERTABLE_ACK_P = incr("GC_ENTERTABLE_ACK_P")                      --坐桌子回应
    self.CG_LEAVETABLE_REQ_P = incr("CG_LEAVETABLE_REQ_P")                      --离开桌子请求
    self.GC_ENTERTABLE_P = incr("GC_ENTERTABLE_P")                          --加入桌子广播
    self.CC_ENTERTABLE_P = incr("CC_ENTERTABLE_P")                          --大厅通知游戏玩家加入
    self.GC_LEAVETABLE_P = incr("GC_LEAVETABLE_P")                          --离开桌子广播
    self.CG_HANDUP_P = incr("CG_HANDUP_P")                              --举手请求
    self.GC_HANDUP_P = incr("GC_HANDUP_P")                              --举手请求广播
    self.GC_GAME_START_P = incr("GC_GAME_START_P")                          --本桌游戏开始通知
    self.CG_AGREELEAVE_REQ_P = incr("CG_AGREELEAVE_REQ_P")                      --请求协议退出
    self.GC_AGREELEAVE_ACK_P = incr("GC_AGREELEAVE_ACK_P")                      --协议退出结果
    self.GC_AGREELEAVE_ASK_P = incr("GC_AGREELEAVE_ASK_P")                      --询问其它玩家是否同意协议退出
    self.CG_AGREELEAVE_ASW_P = incr("CG_AGREELEAVE_ASW_P")                      --回复协议退出询问
    self.GC_STARTTIMER_P = incr("GC_STARTTIMER_P")                          --启动客户段定时器
    self.CG_TABLECHAT_P = incr("CG_TABLECHAT_P")                           --聊天
    self.GC_TABLECHAT_P = incr("GC_TABLECHAT_P")
    self.CG_ROOMCHAT_P = incr("CG_ROOMCHAT_P")
    self.GC_ROOMCHAT_P = incr("GC_ROOMCHAT_P")
    self.CG_KICKUSER_REQ_P = incr("CG_KICKUSER_REQ_P")                        --踢掉对方
    self.GC_KICKUSER_ACK_P = incr("GC_KICKUSER_ACK_P")
    self.GC_KICKUSER_NOT_P = incr("GC_KICKUSER_NOT_P")
    self.CG_INVITE_REQ_P = incr("CG_INVITE_REQ_P")                          --邀请其它用户参加游戏
    self.GC_INVITE_ASK_P = incr("GC_INVITE_ASK_P")                          --邀请询问
    self.CG_ROOM_SETING_REQ_P = incr("CG_ROOM_SETING_REQ_P")                     --设置请求
    self.CG_WATCH_SET_REQ_P = incr("CG_WATCH_SET_REQ_P")                       --是否允许旁观设置请求
    self.CG_TEST_NETDELAY_P = incr("CG_TEST_NETDELAY_P")
    self.GC_TEST_NETDELAY_P = incr("GC_TEST_NETDELAY_P")
    self.GD_UP_GAMEINFO_P = incr("GD_UP_GAMEINFO_P")                         --更新游戏信息
    self.CG_USE_ITEM_P = incr("CG_USE_ITEM_P")                            --使用道具
    self.GC_USE_ITEM_P = incr("GC_USE_ITEM_P")                            --使用道具结果
    self.GD_CLEAR_SCORE_P = incr("GD_CLEAR_SCORE_P")                         --负分清零
    self.DG_CLEAR_SCORE_P = incr("DG_CLEAR_SCORE_P")                         --负分清零结果
    self.SS_ONLINE_GIVE_P = incr("SS_ONLINE_GIVE_P")                         --在线送分
    self.GC_SYS_KICKUSER_NOT_P = incr("GC_SYS_KICKUSER_NOT_P")
    self.GC_TABLE_CHATFAIL_P = incr("GC_TABLE_CHATFAIL_P")
    self.GC_ROOM_CHATFAIL_P = incr("GC_ROOM_CHATFAIL_P")
    self.GC_ENTERTABLE_SAMEIP_P = incr("GC_ENTERTABLE_SAMEIP_P")
    self.CG_ENTERTABLE_SAMEIP_P = incr("CG_ENTERTABLE_SAMEIP_P")
    self.CG_FAST_JOIN_GAME_REQ_P = incr("CG_FAST_JOIN_GAME_REQ_P")				 --快速加入游戏请求
    self.CG_BLACK_SUREENTERTABLE_REQ_P = incr("CG_BLACK_SUREENTERTABLE_REQ_P")           --桌子上有黑名单也确定加入游戏
    self.CG_JOIN_TABLE_REQ_P = incr("CG_JOIN_TABLE_REQ_P")					 --加入指定桌子请求（没有指定椅子号）
    self.CG_TABLE_MAXNUM_REQ_P = incr("CG_TABLE_MAXNUM_REQ_P")					 --桌子游戏的最大人数请求
    self.GC_TABLE_MAXNUM_ACK_P = incr("GC_TABLE_MAXNUM_ACK_P")					 --桌子游戏的最大人数回复
    self.FC_BULLETIN_INFO_P = incr("FC_BULLETIN_INFO_P")						 --公告消息
    self.GF_BULLETIN_INFO_P = incr("GF_BULLETIN_INFO_P")						 --发送公告消息到功能服务器
    self.GC_ROUNDGAME_END_ACK_P = incr("GC_ROUNDGAME_END_ACK_P")                  --单局游戏结束协议
    self.GF_GAMEBULLETIN_INFO_P = incr("GF_GAMEBULLETIN_INFO_P")                  --发送小游戏公告信息到功能服务器
    self.FG_GAMEBULLETIN_INFO_P = incr("FG_GAMEBULLETIN_INFO_P")                  --返回小游戏公告信息给客户端
    self.GF_SENDAWARDPOOL_INFO_P = incr("GF_SENDAWARDPOOL_INFO_P")                --发送获取奖池信息给功能服务器
    self.FD_SENDAWARDPOOL_INFO_P = incr("FD_SENDAWARDPOOL_INFO_P")                --发送获取奖池信息给数据库服务器
    self.DF_SENDAWARDPOOL_INFO_P = incr("DF_SENDAWARDPOOL_INFO_P")                --返回所有游戏对应的奖池信息
    self.FG_SENDAWARDPOOL_INFO_P = incr("FG_SENDAWARDPOOL_INFO_P")                --返回奖池奖金给游戏服务器
    self.GC_LOTTDRAWQUALICATION_ACK_P = incr("GC_LOTTDRAWQUALICATION_ACK_P")      --发送抽奖资格信息给客户端
    self.CG_GETAWARDPOOL_INFO_P = incr("CG_GETAWARDPOOL_INFO_P")                  --获取奖池信息
    self.GF_GETAWARDPOOLMONEY_REQ_P = incr("GF_GETAWARDPOOLMONEY_REQ_P")          --获取奖池奖金
    self.FG_GETAWARDPOOLMONEY_ACK_P = incr("FG_GETAWARDPOOLMONEY_ACK_P")           --返回奖池奖金
    self.GC_BROADGETAWARDPOOLMONEY_ACK_P = incr("GC_BROADGETAWARDPOOLMONEY_ACK_P")        --广播给对应GAMEID的所有游戏服务器
    self.GD_GETAWARDPOOLRECORD_REQ_P = incr("GD_GETAWARDPOOLRECORD_REQ_P")          --获取用户奖池记录
    self.GC_GETLOTTERDRAWRECORD_ACK_P = incr("GC_GETLOTTERDRAWRECORD_ACK_P")          --发送抽奖记录给客户端
    self.GC_SELFLOTTERDRAWRECORD_ACK_P = incr("GC_SELFLOTTERDRAWRECORD_ACK_P")         --发送自己的抽奖记录给客户端
    self.GC_LOTTERDRAWRANK_ACK_P = incr("GC_LOTTERDRAWRANK_ACK_P")              --发送抽奖排行给客户端
    self.CG_LOTTERDRAW_REQ_P = incr("CG_LOTTERDRAW_REQ_P")                  --抽奖申请
    self.GF_LOTTERDRAW_REQ_P = incr("GF_LOTTERDRAW_REQ_P")                 --发送给功能服务器处理抽奖
    self.FD_LOTTERDRAW_REQ_P = incr("FD_LOTTERDRAW_REQ_P")                   --发送给数据服务器处理抽奖
    self.GC_LOTTERDRAW_ACK_P = incr("GC_LOTTERDRAW_ACK_P")                  --返回给客户端用户抽奖结果
    self.FD_SAVEAWARDPOOLINFO_REQ_P = incr("FD_SAVEAWARDPOOLINFO_REQ_P")             --发送给数据库服务器保存奖池信息
    self.GC_SENDSELFAWARDINFO_ACK_P = incr("GC_SENDSELFAWARDINFO_ACK_P")             --发送给自己中奖信息
    self.GD_GETBETSETINFO_REQ_P = incr("GD_GETBETSETINFO_REQ_P")                --发送给数据库服务器获取底注设置信息
    self.DG_GETBETSETINFO_ACK_P = incr("DG_GETBETSETINFO_ACK_P")                 --返回用户设置的底注给游戏服务器
    self.GC_GETBETSETINFO_ACK_P = incr("GC_GETBETSETINFO_ACK_P")                 --返回给用户设置的底注
    self.CG_SETBET_REQ_P = incr("CG_SETBET_REQ_P")                      --设置底注请求
    self.GC_SETBET_ACK_P = incr("GC_SETBET_ACK_P")                       --返回设置底注
    self.GC_TABLESETBET_INFO_ACK_P = incr("GC_TABLESETBET_INFO_ACK_P")             --广播桌子设置底注信息
    self.GC_CUSTOMTABLENUM_ACK_P = incr("GC_CUSTOMTABLENUM_ACK_P")               --发送自定义桌子人数信息给客户端
    self.GC_BETSETUPLIMIT_INFO_ACK_P = incr("GC_BETSETUPLIMIT_INFO_ACK_P")           --发送底注设置上限信息给客户端
    self.GC_BRINGGAMECURRENCY_INFO_ACK_P = incr("GC_BRINGGAMECURRENCY_INFO_ACK_P")        --发送携带游戏豆信息给客户端
    self.CG_CHECKBET_REQ_P = incr("CG_CHECKBET_REQ_P")                     --选择底注申请
    self.GC_CHECKBET_ACK_P = incr("GC_CHECKBET_ACK_P")                   --返回选择底注结果
    self.CG_SETCURRENTTABLE_USERINFO_REQ_P = incr("CG_SETCURRENTTABLE_USERINFO_REQ_P")         --设置本桌用户的信息
    self.CG_SUPPLYGAMECURRENCY_REQ_P = incr("CG_SUPPLYGAMECURRENCY_REQ_P")                --补充筹码请求

    self.GC_DZ_STARTTIMER_P = incr("GC_DZ_STARTTIMER_P")                     --启动客户段定时器
    self.CG_GETSHOWSETBETINFO_REQ_P = incr("CG_GETSHOWSETBETINFO_REQ_P")                 --获取是否显示设置底注信息
    self.GC_GETSHOWSETBETINFO_ACK_P = incr("GC_GETSHOWSETBETINFO_ACK_P")                 --返回是否显示设置底注信息
    self.GC_TABLEUSERBRINGGAMECURRENCY_ACK_P = incr("GC_TABLEUSERBRINGGAMECURRENCY_ACK_P")            --将桌子上玩家携带的游戏豆发给进入的玩家
    self.GC_SUPPLYINFO_ACK_P = incr("GC_SUPPLYINFO_ACK_P")                       --发送补充游戏豆结果信息给客户端

    self.CG_GETCREATEROOMINFO_REQ_P = incr("CG_GETCREATEROOMINFO_REQ_P")                       --获得是否显示创建房间界面请求
    self.GC_GETCREATEROOMINFO_ACK_P = incr("GC_GETCREATEROOMINFO_ACK_P")                       --返回是否显示创建房间界面回复
    self.CG_CREATEROOMINFO_REQ_P = incr("CG_CREATEROOMINFO_REQ_P")                       --创建房间信息请求
    self.GC_CREATEROOMINFO_ACK_P = incr("GC_CREATEROOMINFO_ACK_P")                       --创建房间信息回复
    self.GC_TABLEMASTER_INFO_P = incr("GC_TABLEMASTER_INFO_P")                       --通知房间房主信息
    self.GC_ROOMS_MASTER_P = incr("GC_ROOMS_MASTER_P")                       --通知房间房主
    -------------------------------登陆协议  止----------------------------------------
    self.PROTOCOL_LOGIN = 11524
    i = self.PROTOCOL_LOGIN - 1
    self.CL_LOGIN_REQ_P = incr("CL_LOGIN_REQ_P")             --请求登录，验证用户名密码，获取通行码
    self.LC_LOGIN_ACK_P = incr("LC_LOGIN_ACK_P")                                --登录结果，如验证成功，发放通行码
    self.ML_LOGIN_ACK_P = incr("ML_LOGIN_ACK_P")                                --管理服务器回应登录服务器用户登陆结果
    self.AL_LOGIN_ACK_P = incr("AL_LOGIN_ACK_P")                                --数据库服务器回应登录服务器用户登陆结果
    self.CL_VALIDATE_REQ_P = incr("CL_VALIDATE_REQ_P")                             --请求验证码
    self.LC_VALIDATE_ACK_P = incr("LC_VALIDATE_ACK_P")                             --发送验证码
    self.LM_USERLOGIN_REQ_P = incr("LM_USERLOGIN_REQ_P")                            --登录服务器到管理服务器验证用户登陆

    self.CS_USERLOGIN_REQ_P = incr("CS_USERLOGIN_REQ_P")                            --用户登录到大厅服务器
    self.SM_USERLOGOUT_REQ_P = incr("SM_USERLOGOUT_REQ_P")                           --用户登出管理服务器
    self.SC_USERLOGIN_ACK_P = incr("SC_USERLOGIN_ACK_P")                            --用户登录大厅服务器回应
    self.CS_VALIDATE_REQ_P = incr("CS_VALIDATE_REQ_P")                             --请求验证码
    self.SC_VALIDATE_ACK_P = incr("SC_VALIDATE_ACK_P")                             --发送验证码

    self.MS_USERLOGIN_ACK_P = incr("MS_USERLOGIN_ACK_P")                            --管理服务器通知大厅服务器验证用户登陆结果

    self.DS_USERLOGIN_ACK_P = incr("DS_USERLOGIN_ACK_P")                            --数据库回应大厅服务器玩家加载数据结果
    self.SS_KICKUSER_P = incr("SS_KICKUSER_P")                                 --服务器之间发送踢出玩家请求
    self.ML_LOGIN_FINISH_P = incr("ML_LOGIN_FINISH_P")                             --用户通过大厅服务器登录到了管理服务器，通知登录服务器断开连接
    self.CG_LOGIN_REQ_P = incr("CG_LOGIN_REQ_P")                                --登陆到游戏服务器
    self.GC_LOGIN_ACK_P = incr("GC_LOGIN_ACK_P")                                --游戏服务器登陆结果

    self.GM_USERLOGIN_REQ_P = incr("GM_USERLOGIN_REQ_P")                            --游戏服务器登陆用户到管理服务器
    self.GM_USERLOGOUT_REQ_P = incr("GM_USERLOGOUT_REQ_P")                           --游戏服务器用户登出管理服务器

    self.MG_USERLOGIN_ACK_P = incr("MG_USERLOGIN_ACK_P")                            --游戏服务器登录用户到管理服务器的返回结果
    self.GD_USERLOGIN_REQ_P = incr("GD_USERLOGIN_REQ_P")                            --游戏服务器登陆用户到数据库服务器
    self.DG_USERLOGIN_ACK_P = incr("DG_USERLOGIN_ACK_P") 							  --游戏服务器登录用户到数据库服务器的返回结果
    self.GD_MONEY_UNLOCK_REQ_P = incr("GD_MONEY_UNLOCK_REQ_P")                         --接触游戏豆的锁定
    self.GD_MONEY_LOCK_REQ_P = incr("GD_MONEY_LOCK_REQ_P")                           --锁定游戏豆

    self.SM_LOBBY_NUM_UP_P = incr("SM_LOBBY_NUM_UP_P")                             --大厅服务器向管理服务器更新大厅服务器人数
    self.GM_GAMEINFO_P = incr("GM_GAMEINFO_P")                                 --游戏服务器向管理服务器更新游戏信息
    self.GM_ROOM_NUM_UP_P = incr("GM_ROOM_NUM_UP_P")                              --游戏服务器向管理服务器更新房间人数信息

    self.SF_USERLOGIN_P = incr("SF_USERLOGIN_P")                                --用户从大厅服务器登陆社交服务器
    self.SF_USERLOGOUT_P = incr("SF_USERLOGOUT_P")                               --用户从大厅服务器登出社交服务器

    self.SC_KICKOUT_LOBBY_P = incr("SC_KICKOUT_LOBBY_P")                            --用户被提出大厅

    self.LC_DYNPWD_REQ_P = incr("LC_DYNPWD_REQ_P")                               --请求客户端输入动态密码
    self.CL_DYNPWD_ACK_P = incr("CL_DYNPWD_ACK_P")                               --输入动态密码

    self.CL_TRAIL_LOGIN_REQ_P = incr("CL_TRAIL_LOGIN_REQ_P")                          --试玩登录
    self.LC_TRAIL_LOGIN_ACK_P = incr("LC_TRAIL_LOGIN_ACK_P")                          --试玩登录回应
    self.ML_TRAIL_LOGIN_ACK_P = incr("ML_TRAIL_LOGIN_ACK_P")                          --管理服务器回应登录服务器用户登陆结果
    self.AL_TRAIL_LOGIN_ACK_P = incr("AL_TRAIL_LOGIN_ACK_P")                          --数据库服务器回应登录服务器用户登陆结果
    self.LM_TRAIL_USERLOGIN_REQ_P = incr("LM_TRAIL_USERLOGIN_REQ_P")                      --登录服务器到管理服务器验证用户登陆

    self.CS_TRAIL_TRANSFER_P = incr("CS_TRAIL_TRANSFER_P")                           --试玩完善信息
    self.SC_TRAIL_TRANSFER_P = incr("SC_TRAIL_TRANSFER_P")                           --试玩完善信息结果
    self.AD_TRAIL_CHECK_NICKNAME_P = incr("AD_TRAIL_CHECK_NICKNAME_P")                     --试玩完善信息检测昵称
    self.DA_TRAIL_CHECK_NICKNAME_P = incr("DA_TRAIL_CHECK_NICKNAME_P")                     --试玩完善信息检测昵称结果

    self.CS_ALLOCTRAIL_P = incr("CS_ALLOCTRAIL_P")                               --请求分配试玩帐号
    self.SC_ALLOCTRAIL_P = incr("SC_ALLOCTRAIL_P")                               --分配试玩帐号结果
    self.AD_ALLOC_CHECK_NICKNAME_P = incr("AD_ALLOC_CHECK_NICKNAME_P")                     --分配试玩完善信息检测昵称
    self.DA_ALLOC_CHECK_NICKNAME_P = incr("DA_ALLOC_CHECK_NICKNAME_P")                     --分配试玩完善信息检测昵称结果
    self.CA_ALLOC_P = incr("CA_ALLOC_P")
    self.AC_ALLOC_P = incr("AC_ALLOC_P")
    self.AD_ALLOC_P = incr("AD_ALLOC_P")
    self.SC_LOGIN_TOKEN_P = incr("SC_LOGIN_TOKEN_P")
    self.GD_USER_SAVE_BROKEN_GAME_P = incr("GD_USER_SAVE_BROKEN_GAME_P") 					  --用户断线后，保存游戏信息
    self.DC_USER_LOAD_BROKEN_GAME_P = incr("DC_USER_LOAD_BROKEN_GAME_P") 					  --获取断线游戏列表

    self.CL_PHONECODE_USECURRENCY_GETVALIDATECODE_REQ_P = incr("CL_PHONECODE_USECURRENCY_GETVALIDATECODE_REQ_P")  --使用游戏豆获取验证码请求
    self.LD_USEPHONEVALICODELOGIN_REQ_P = incr("LD_USEPHONEVALICODELOGIN_REQ_P")                 --使用手机验证码登录发送给数据库服务器
    self.DL_USEPHONEVALICODELOGIN_REQ_P = incr("DL_USEPHONEVALICODELOGIN_REQ_P")                 --使用手机验证码登录发送给登录服务器
    self.LC_USEPHONEVALICODELOGIN_ACK_P = incr("LC_USEPHONEVALICODELOGIN_ACK_P")                 --回复客户端是否使用手机验证码进行登录
    self.CS_USEVALICODELOGIN_DECGAMECURRENCY_REQ_P = incr("CS_USEVALICODELOGIN_DECGAMECURRENCY_REQ_P")   --使用验证码登录成功扣去游戏豆请求
    self.SC_USEVALICODELOGIN_DECGAMECURRENCY_ACK_P = incr("SC_USEVALICODELOGIN_DECGAMECURRENCY_ACK_P") --使用验证码登录成功扣去游戏豆回复
    self.CL_USEPHONEVALICODE_LOGIN_REQ_P = incr("CL_USEPHONEVALICODE_LOGIN_REQ_P") --使用手机验证码登录请求
    self.CL_LOGINGETSET_REQ_P = incr("CL_LOGINGETSET_REQ_P") --登录loginserver获取设置请求
    self.CL_LOGINGETSET_ACK_P = incr("CL_LOGINGETSET_ACK_P") --登录loginserver获取设置回复
    self.CS_LOGINGETSET_REQ_P = incr("CS_LOGINGETSET_REQ_P") --登录Lobbyserver获取设置请求
    self.CS_LOGINGETSET_ACK_P = incr("CS_LOGINGETSET_ACK_P") --登录lobbyserver获取设置回复
    self.CS_DIFFCITY_REQ_P = incr("CS_DIFFCITY_REQ_P") --获取异地登录请求
    self.GD_LOGINWRITEINFO_REQ_P = incr("GD_LOGINWRITEINFO_REQ_P") --登录写入登录信息请求
    self.GC_DIFFCITYRESULT_ACK_P = incr("GC_DIFFCITYRESULT_ACK_P") --返回异地登录结果给客户端


-------------------------------登陆协议  止----------------------------------------

------------------------------注册协议 起------------------------------------------
    self.PROTOCOL_REG = 12024
    i = self.PROTOCOL_REG - 1
    self.CL_REG_REQ_P = incr("CL_REG_REQ_P")                  --注册帐号请求
    self.LC_REG_ACK_P = incr("LC_REG_ACK_P")                                 --注册结果
    self.AD_CHECK_NICKNAME_P = incr("AD_CHECK_NICKNAME_P")                          --帐号服务器到主数据库服务器验证昵称是否可以注册
    self.DA_CHECK_NICKNAME_P = incr("DA_CHECK_NICKNAME_P")                          --昵称验证结果
    self.CL_CHECK_ACCOUNT_P = incr("CL_CHECK_ACCOUNT_P")                           --检测用户名
    self.LC_CHECK_ACCOUNT_P = incr("LC_CHECK_ACCOUNT_P")                           --检测用户名结果
    self.CL_CHECK_NICKNAME_P = incr("CL_CHECK_NICKNAME_P")                          --检测昵称
    self.LC_CHECK_NICKNAME_P = incr("LC_CHECK_NICKNAME_P")                          --检测昵称结果

    --************************ 手机号码在PC端注册协议  起 ***************************************
    self.CL_CHECK_PHONECODE_P = incr("CL_CHECK_PHONECODE_P")                        --检查手机号码
    self.LC_CHECK_PHONECODE_P = incr("LC_CHECK_PHONECODE_P")                        --检查手机号码回复
    self.AD_CHECK_PHONECODE_USERD_P = incr("AD_CHECK_PHONECODE_USERD_P")                  --检查手机号码是否被使用
    self.DA_CHECK_PHONECODE_USERD_P = incr("DA_CHECK_PHONECODE_USERD_P")                  --返回检查手机号码是否被使用
    self.CL_PHONECODE_GET_VALIDATECODE_REQ_P = incr("CL_PHONECODE_GET_VALIDATECODE_REQ_P")         --获取验证码
    self.LC_PHONECODE_GET_VALIDATECODE_ACK_P = incr("LC_PHONECODE_GET_VALIDATECODE_ACK_P")         --获取验证码回复
    self.CL_CHECK_PHONEVALIDATECODE_REQ_P = incr("CL_CHECK_PHONEVALIDATECODE_REQ_P")            --检查手机验证码
    self.LA_CHECK_PHONEVALIDATECODE_REQ_P = incr("LA_CHECK_PHONEVALIDATECODE_REQ_P")            --验证手机验证码请求发送给账号数据库
    self.LC_CHECK_PHONEVALIDATECODE_ACK_P = incr("LC_CHECK_PHONEVALIDATECODE_ACK_P")            --检查手机验证码回复
    self.LA_PHONECODE_GET_VALIDATECODE_REQ_P = incr("LA_PHONECODE_GET_VALIDATECODE_REQ_P")         --获取验证码发送给账号服务器
    self.LA_PHONECODE_UPDATE_STATUS_P = incr("LA_PHONECODE_UPDATE_STATUS_P")                --更新用户获取手机验证码状态
    self.CL_PHONECODE_REG_REQ_P = incr("CL_PHONECODE_REG_REQ_P")                          --手机号注册请求
    self.LC_PHONECODE_REG_ACK_P = incr("LC_PHONECODE_REG_ACK_P")                          --手机号注册结果
    self.AD_PHONE_CHECK_NICKNAME_P = incr("AD_PHONE_CHECK_NICKNAME_P")                   --帐号服务器到主数据库服务器验证昵称和手机号是否可以注册
    self.DL_PHONE_CHECK_PHONEBINDACCOUNTLIMIT_ACK_P = incr("DL_PHONE_CHECK_PHONEBINDACCOUNTLIMIT_ACK_P")        --检查手机号绑定是否超过上限

    --************************ 手机号码在PC端注册协议  止 ***************************************

------------------------------注册协议 起------------------------------------------


------------------------------银行协议 起------------------------------------------
    self.PROTOCOL_BANK = 14024
    i = self.PROTOCOL_BANK - 1
    self.CS_BANKDATA_REQ_P = incr("CS_BANKDATA_REQ_P")
    self.SC_BACKDATA_ACK_P = incr("SC_BACKDATA_ACK_P")
    self.CS_COFFER_RENEWALS_REQ_P = incr("CS_COFFER_RENEWALS_REQ_P")
    self.SC_COFFER_RENEWALS_ACK_P = incr("SC_COFFER_RENEWALS_ACK_P")
    self.CS_COFFER_OP_REQ_P = incr("CS_COFFER_OP_REQ_P")
    self.SC_COFFER_OP_ACK_P = incr("SC_COFFER_OP_ACK_P")
    self.CS_MONEYTANSF_REQ_P = incr("CS_MONEYTANSF_REQ_P")
    self.SC_MONEYTANSF_ACK_P = incr("SC_MONEYTANSF_ACK_P")
------------------------------银行协议 止------------------------------------------

-----------------------------个人中心协议 起---------------------------------------
    self.PROTOCOL_INDIVIDUAL = 15024
    i = self.PROTOCOL_INDIVIDUAL - 1

    self.CS_VIP_PAY_P = incr("CS_VIP_PAY_P")
    self.SC_VIP_PAY_P = incr("SC_VIP_PAY_P")

    self.CS_CHANGE_PASSWD_P = incr("CS_CHANGE_PASSWD_P")
    self.SC_CHANGE_PASSWD_P = incr("SC_CHANGE_PASSWD_P")

    self.CS_CREATE_SEPASSWD_P = incr("CS_CREATE_SEPASSWD_P")
    self.SC_CREATE_SEPASSWD_P = incr("SC_CREATE_SEPASSWD_P")

    self.CS_BINDMAC_P = incr("CS_BINDMAC_P")
    self.CS_UNBINDMAC_P = incr("CS_UNBINDMAC_P")
    self.SC_UNBINDMAC_P = incr("SC_UNBINDMAC_P")

    self.CS_USERMORE_P = incr("CS_USERMORE_P")
    self.SC_USERMORE_P = incr("SC_USERMORE_P")

    self.CS_CHANGE_INFO_P = incr("CS_CHANGE_INFO_P")
    self.SC_CHANGE_INFO_P = incr("SC_CHANGE_INFO_P")

    self.CS_CHANGE_NICKNAME_P = incr("CS_CHANGE_NICKNAME_P")
    self.SC_CHANGE_NICKNAME_P = incr("SC_CHANGE_NICKNAME_P")

    self.CS_CHANGE_SEPWD_P = incr("CS_CHANGE_SEPWD_P")
    self.SC_CHANGE_SEPWD_P = incr("SC_CHANGE_SEPWD_P")

    self.CL_GETPWD_P = incr("CL_GETPWD_P")
    self.LC_GETPWD_P = incr("LC_GETPWD_P")

    self.CL_UNBINDMAC_P = incr("CL_UNBINDMAC_P")
    self.LC_UNBINDMAC_P = incr("LC_UNBINDMAC_P")

    self.CS_UP_DYNPWD_P = incr("CS_UP_DYNPWD_P")                       --更新动态密码
    self.SC_UP_DYNPWD_P = incr("SC_UP_DYNPWD_P")                       --更新动态密码结果

    self.CL_GETDYNPWD_P = incr("CL_GETDYNPWD_P")                       --找回动态密码
    self.LC_GETDYNPWD_P = incr("LC_GETDYNPWD_P")                       --找回动态密码结果

    self.CS_PHONE_INFO_P = incr("CS_PHONE_INFO_P")                      --获取手机号绑定的信息
    self.SC_PHONE_INFO_P = incr("SC_PHONE_INFO_P")                      --发送手机号绑定的信息

    self.CS_PHONE_VALID_P = incr("CS_PHONE_VALID_P")                     --请求手机号验证码
    self.SC_PHONE_VALID_P = incr("SC_PHONE_VALID_P")                     --请求手机号验证码结果

    self.CS_PHONE_BIND_P = incr("CS_PHONE_BIND_P")                      --请求绑定手机号
    self.SC_PHONE_BIND_P = incr("SC_PHONE_BIND_P")

    self.CS_PHONE_UNBIND_P = incr("CS_PHONE_UNBIND_P")                    --请求解除绑定手机号
    self.SC_PHONE_UNDIND_P = incr("SC_PHONE_UNDIND_P")

    self.CS_CHANGE_EMAIL_P = incr("CS_CHANGE_EMAIL_P")					  --修改邮箱请求
    self.SC_CHANGE_EMAIL_P = incr("SC_CHANGE_EMAIL_P")					  --修改邮箱回复

    self.CS_SHOWGETLOGINAWARDUI_REQ_P = incr("CS_SHOWGETLOGINAWARDUI_REQ_P")               --发送获取登录福利奖励界面
    self.SC_SHOWGETLOGINAWARDUI_ACK_P = incr("SC_SHOWGETLOGINAWARDUI_ACK_P")               --回复客户端是否显示登录福利奖励界面
    self.CS_GETLOGINAWARD_REQ_P = incr("CS_GETLOGINAWARD_REQ_P")                    --领取登录奖励请求
    self.SC_GETLOGINAWARD_ACK_P = incr("SC_GETLOGINAWARD_ACK_P")                    --领取登录奖励回复

    self.CS_PHONEBIND_CHECK_PHONECODE_P = incr("CS_PHONEBIND_CHECK_PHONECODE_P")              --手机号码绑定风雷号检查申请
    self.SC_PHONEBIND_CHECK_PHONECODE_P = incr("SC_PHONEBIND_CHECK_PHONECODE_P")              --手机号码绑定风雷号检查回复
    self.CS_GETPHONECODEBIND_RESULT_REQ_P = incr("CS_GETPHONECODEBIND_RESULT_REQ_P")           --得到手机号码绑定结果请求
    self.SC_GETPHONECODEBIND_RESULT_ACK_P = incr("SC_GETPHONECODEBIND_RESULT_ACK_P")           --得到手机号码绑定结果回复
    self.CS_PHONECODEBIND_REQ_P = incr("CS_PHONECODEBIND_REQ_P")                      --绑定手机号申请
    self.SC_PHONECODEBIND_ACK_P = incr("SC_PHONECODEBIND_ACK_P")                      --绑定手机号回复
    self.CS_BIND_GETAWARD_REQ_P = incr("CS_BIND_GETAWARD_REQ_P")                      --绑定获取奖励申请
    self.SC_BIND_GETAWARD_ACK_P = incr("SC_BIND_GETAWARD_ACK_P")                      --绑定获取奖励回复
    self.SD_BIND_GETAWARD_REQ_P = incr("SD_BIND_GETAWARD_REQ_P")                      --绑定手机号发送给数据库服务器执行
    self.CS_REMOVEPHONEBIND_REQ_P = incr("CS_REMOVEPHONEBIND_REQ_P")                    --解除手机绑定请求
    self.SC_REMOVEPHONEBIND_ACK_P = incr("SC_REMOVEPHONEBIND_ACK_P")                    --回复解除手机绑定请求
    self.CS_CHECKUSEPHONELOGIN_REQ_P = incr("CS_CHECKUSEPHONELOGIN_REQ_P")                 --检查使用手机号登录请求
    self.SC_CHECKUSEPHONELOGIN_ACK_P = incr("SC_CHECKUSEPHONELOGIN_ACK_P")                 --检查使用手机号登录回复
    self.CS_SETUSEPHONELOGIN_REQ_P = incr("CS_SETUSEPHONELOGIN_REQ_P")                   --设置使用手机号登录请求
    self.SC_SETUSEPHONELOGIN_ACK_P = incr("SC_SETUSEPHONELOGIN_ACK_P")                   --设置使用手机号登录回复
    self.SA_SETUSEPHONELOGIN_REQ_P = incr("SA_SETUSEPHONELOGIN_REQ_P")                   --设置使用手机号登录发送给账号服务器更新用户手机
    self.SA_CANCELUSEPHONELOGIN_REQ_P = incr("SA_CANCELUSEPHONELOGIN_REQ_P")                --取消使用手机号登录发送给账号服务器
    self.CS_CACELUSERPHONELOGIN_REQ_P = incr("CS_CACELUSERPHONELOGIN_REQ_P")                --取消用户使用手机号登录申请
    self.SC_CACELUSERPHONELOGIN_ACK_P = incr("SC_CACELUSERPHONELOGIN_ACK_P")               --取消用户使用手机号登录回复
    self.CS_SETUSEPHONEVALICODE_LOGIN_REQ_P = incr("CS_SETUSEPHONEVALICODE_LOGIN_REQ_P")           --设置使用手机验证码登录请求
    self.SC_SETUSEPHONEVALICODE_LOGIN_ACK_P = incr("SC_SETUSEPHONEVALICODE_LOGIN_ACK_P")         --设置使用手机验证码登录回复
    self.CS_CANCELUSEPHONEVALICODE_LOGIN_REQ_P = incr("CS_CANCELUSEPHONEVALICODE_LOGIN_REQ_P")        --取消使用手机验证码登录请求
    self.SC_CANCELUSEPHONEVALICODE_LOGIN_ACK_P = incr("SC_CANCELUSEPHONEVALICODE_LOGIN_ACK_P")         --取消使用手机验证码登录回复
    self.GF_GETBASELIVEING_REQ_P = incr("GF_GETBASELIVEING_REQ_P")                        --发送领取低保协议
    self.FD_GETBASELIVEING_REQ_P = incr("FD_GETBASELIVEING_REQ_P")                     --发送领取低保协议给数据库服务
    self.GC_GETBASELIVEING_ACK_P = incr("GC_GETBASELIVEING_ACK_P")                     --发送领取低保协议给客户端
    self.CG_GETBASELIVINGCURRENCY_REQ_P = incr("CG_GETBASELIVINGCURRENCY_REQ_P")              --客户端发送领取低保
    self.GC_GETBASELIVINGCURRENCY_ACK_P = incr("GC_GETBASELIVINGCURRENCY_ACK_P")              --返回给客户端领取低保结果
    self.DL_CHANGEBINDPHONECODE_ACK_P = incr("DL_CHANGEBINDPHONECODE_ACK_P")                --数据库服务发送给Gameserver更新绑定的手机号
-----------------------------------个人中心协议 止-----------------------------------
-----------------------------------排行榜 start-----------------------------------
    self.PL_PHONE_CL_USERRANK_REQ_P = 51075
    i =  self.PL_PHONE_CL_USERRANK_REQ_P - 1
    self.PL_PHONE_CL_USERRANK_REQ_P = incr("PL_PHONE_CL_USERRANK_REQ_P") --请求玩家排名
    self.PL_PHONE_LC_USERRANK_ACK_P = incr("PL_PHONE_LC_USERRANK_ACK_P") --返回玩家排名
    self.PL_PHONE_LC_SELFUSERRANK_ACK_P = incr("PL_PHONE_LC_SELFUSERRANK_ACK_P") --返回自己的排名
-----------------------------------排行榜 end  -----------------------------------
------------------------------------任务协议 始------------------------------------
    self.PROTOCOL_TASK = 38524
    i = self.PROTOCOL_TASK - 1
    self.TD_TASK_DATABASE_SAVE_INFO_REQ_P = incr("TD_TASK_DATABASE_SAVE_INFO_REQ_P")--发送给数据库获取任务保存信息请求
    self.DT_TASK_DATABASE_SAVE_INFO_ACK_P = incr("DT_TASK_DATABASE_SAVE_INFO_ACK_P")--数据库回复给游戏服务器获取任务保存信息请求
    self.GC_TASK_TASKINFOLIST_ACK_P = incr("GC_TASK_TASKINFOLIST_ACK_P")--发送任务列表信息给客户端
    self.TD_TASK_WRITETASKOPERINFO_REQ_P = incr("TD_TASK_WRITETASKOPERINFO_REQ_P")--向数据库写入操作信息请求
    self.TG_TASK_WRITETASKOPERINFO_ACK_P = incr("TG_TASK_WRITETASKOPERINFO_ACK_P")--返回给游戏服务器写入的任务操作请求
    self.GC_TASK_WRITETASKOPERINFO_ACK_P = incr("GC_TASK_WRITETASKOPERINFO_ACK_P")--返回给客户端任务操作
    self.CG_TASK_GETAWARD_REQ_P = incr("CG_TASK_GETAWARD_REQ_P")--获取任务奖励请求
    self.GT_TASK_GETAWARD_REQ_P = incr("GT_TASK_GETAWARD_REQ_P")--获取任务奖励请求发送给任务服务器
    self.TD_TASK_GETAWARD_REQ_P = incr("TD_TASK_GETAWARD_REQ_P")--获取任务奖励请求发送给数据库服务器
    self.DT_TASK_GETAWARD_ACK_P = incr("DT_TASK_GETAWARD_ACK_P")--发送获取任务奖励结果给任务服务器
    self.TG_TASK_GETAWARD_ACK_P = incr("TG_TASK_GETAWARD_ACK_P")--发送获取任务奖励结果给游戏服务器
    self.GC_TASK_GETAWARD_ACK_P = incr("GC_TASK_GETAWARD_ACK_P")--回复奖励信息给客户端
    self.GC_TASK_NEWTASK_ACK_P = incr("GC_TASK_NEWTASK_ACK_P")--发送给客户端新任务消息
    self.GC_TASK_UPDATE_GAMECURRENCY_P = incr("GC_TASK_UPDATE_GAMECURRENCY_P")--任务更新游戏豆通知
    self.GC_TASK_UPDATE_GOLD_P = incr("GC_TASK_UPDATE_GOLD_P")--任务更新风雷币通知
    self.GC_TASK_UPDATE_YUANBAO_P = incr("GC_TASK_UPDATE_YUANBAO_P")--任务更新元宝通知
    self.GT_TASK_GETTASKSAVEINFO_REQ_P = incr("GT_TASK_GETTASKSAVEINFO_REQ_P")--发送给任务服务查询是否保存了用户某款游戏的任务信息
    self.TG_TASK_GETTASKSAVEINFO_ACK_P = incr("TG_TASK_GETTASKSAVEINFO_ACK_P")--任务服务器返回给游戏服务器存在游戏任务结果
    self.GT_TASK_EXETASKOPER_REQ_P = incr("GT_TASK_EXETASKOPER_REQ_P")--给任务服务器发送执行任务请求
    self.GT_TASK_CLEARTASKINFO_REQ_P = incr("GT_TASK_CLEARTASKINFO_REQ_P")--发送给任务服务器清除任务信息
    self.TC_USER_GET_MAIL_ANNEX_ACK_P = incr("TC_USER_GET_MAIL_ANNEX_ACK_P")--发送给客户端领取商品信息
    self.GT_TASK_INIGAMETASKLIST_REQ_P = incr("GT_TASK_INIGAMETASKLIST_REQ_P")--初始化游戏任务列表
    self.TD_GLOBALTASK_DATABASE_SAVE_INFO_REQ_P = incr("TD_GLOBALTASK_DATABASE_SAVE_INFO_REQ_P")--从数据库中加载保存的主线固定任务
    self.DT_GLOBALTASK_DATABASE_SAVE_INFO_ACK_P = incr("DT_GLOBALTASK_DATABASE_SAVE_INFO_ACK_P")--数据库回复给游戏服务器获取任务保存信息请求
    self.LC_TASK_TASKINFOLIST_ACK_P = incr("LC_TASK_TASKINFOLIST_ACK_P")--发送主线任务列表信息给客户端
    self.LC_TASK_WRITETASKOPERINFO_ACK_P = incr("LC_TASK_WRITETASKOPERINFO_ACK_P")--返回给客户端主线任务操作
    self.CL_TASK_GETAWARD_REQ_P = incr("CL_TASK_GETAWARD_REQ_P")--获取任务奖励请求
    self.LC_TASK_GETAWARD_ACK_P = incr("LC_TASK_GETAWARD_ACK_P")--回复奖励信息给客户端
    self.LC_TASK_NEWTASK_ACK_P = incr("LC_TASK_NEWTASK_ACK_P")--发送给客户端新任务消息
    self.CL_GET_INVITETASK_STATUS_REQ_P = incr("CL_GET_INVITETASK_STATUS_REQ_P")--获取邀请任务状态
    self.LD_GET_INVITETASK_STATUS_REQ_P = incr("LD_GET_INVITETASK_STATUS_REQ_P")--发送给数据库服务器查看邀请任务完成状态
    self.DC_GET_INVITETASK_STATUS_ACK_P = incr("DC_GET_INVITETASK_STATUS_ACK_P")--发送给客户端查看邀请任务完成状态
    self.CL_GET_INVITERECORD_REQ_P = incr("CL_GET_INVITERECORD_REQ_P")--获取邀请记录
    self.LC_GET_INVITERECORD_ACK_P = incr("LC_GET_INVITERECORD_ACK_P")--返回邀请记录
    self.CL_WECHATSHARE_REQ_P = incr("CL_WECHATSHARE_REQ_P")--微信分享请求
    self.ML_INITASKINFO_ACK_P = incr("ML_INITASKINFO_ACK_P")--返回LOBBYSERVER 初始化的任务信息
    self.LT_CLEARALLTASK_INFO_REQ_P = incr("LT_CLEARALLTASK_INFO_REQ_P")--发送给任务服务器清除所有任务信息
----------------------------------------任务协议 止---------------------------

----------------------------------------防作弊场协议 起---------------------------
    self.protcolName[17030] = "GC_NOCHEAT_MATCH_INFO_ACK_P"
----------------------------------------防作弊场协议 止---------------------------
----------------------------------------设置底注 起---------------------------
    self.protcolName[13101] = "GC_GETBETSETINFO_ACK_P"
----------------------------------------设置底注 止---------------------------
----------------------------------------挑战赛 起---------------------------
    self.protcolName[16276] = "GC_CHALLENGE_INFO_P"
----------------------------------------挑战赛 止---------------------------

    ----------- mini game pro ---------
    self.PROTOCOL_GAMESERVER = 21024
    self.PROTOCOL_GAMECLIENT = 31024
    ----------- mini game pro ---------
end

function ProtocolNumber:getProtocolName(code)
    return self.protcolName[code]
end

function ProtocolNumber:getProtocolNameOfMiniGame(code)
    return self.protcolNameOfMiniGame[code]
end

function ProtocolNumber:registerMiniGameProNumber()
    local target = self
    local startCode = self.PROTOCOL_GAMESERVER - 1
    local startCodeReq = self.PROTOCOL_GAMECLIENT - 1

    local lastCodeNum = 0
    target.protcolNameOfMiniGame = {}
    local gameNumber = require(app.codeSrc .."GameNumber").new()
    lastCodeNum = gameNumber:appendMiniGameProNumber(target, startCode)
    lastCodeNum = gameNumber:appendMiniGameProNumberReq(target, startCodeReq) + lastCodeNum
end

return ProtocolNumber
