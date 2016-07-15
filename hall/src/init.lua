--
-- Author: ChenShao
-- Date: 2015-08-28 10:59:07
--

require "data.protocolPublic"
require "loading"
--require "channel"

cc.dataMgr = require("data.dataMgr").new()
cc.protocolNumber = require("data.protocolNum").new()
cc.msgHandler = require("data.msgHandler").new()
cc.lobbyController = require("controller.lobbyController").new()
--cc.myApp = require("app.MyApp"):create()

require("app.func.AppDelegate")
require("app.func.EditBoxFactory")
require("app.func.Functions")
require("app.func.Iconv")
require("app.gameModule.taskModule.init") --初始化小游戏任务模块

app.toast = require("app.func.ToastLayer")
app.holdOn = require("app.func.HoldOnLayer")
app.audioPlayer = require("app.func.AudioPlayer")
app.msgBox = require("app.func.MessageBox")
app.popLayer = require("app.func.PopLayerAction")
app.utils = require("app.func.Utils")

app.sceneSwitcher = require("app.views.SceneSwitcher").new()
app.individualLogic = require("hall.logic.IndividualLogic").new()
app.cofferLogic = require("hall.logic.CofferLogic").new()
app.phoneLogic = require("hall.logic.PhoneLogic").new()
app.shopLogic = require("hall.logic.ShopLogic").new()
app.bulletinLogic = require("hall.logic.BulletinLogic").new()
app.signInLogic = require("hall.logic.SignInLogic").new()
app.benefitLogic = require("hall.logic.BenefitLogic").new()
app.reminderLogic = require("hall.logic.ReminderLogic").new()
app.funcPublic = require("data.funcPublic")

app.baseLivingProtocol = require("framework.components.behavior.EventProtocol").new()
require("hall.view.BaseLivingLayer")	--初始化低保

app.bulletinProtocol = require("framework.components.behavior.EventProtocol").new()
require("hall.view.BulletinLayer").initListener()		--初始化跑马灯

app.castMultipleSetLogic = require("hall.logic.CastMultipleSetLogic").new()
