PROJECT = "Player-LuatOS"
VERSION = "1.0.0"

tag = "Player"

sys = require("sys")
wifiLib = require("wifiLib")
httpLib = require("httpLib")

uiComponents = {}

function screen_btn1event_handler(obj, event)
    if event == lvgl.EVENT_CLICKED then
        lvgl.obj_clean(lvgl.scr_act())
        ui = {}
        setup.setup_scr_screen2(ui)
    end
end

function printTable(tbl, lv)
    lv = lv and lv .. "\t" or ""
    print(lv .. "{")
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            k = "\"" .. k .. "\""
        end
        if "string" == type(v) then
            local qv = string.match(string.format("%q", v), ".(.*).")
            v = qv == v and '"' .. v .. '"' or "'" .. v:toHex() .. "'"
        end
        if type(v) == "table" then
            print(lv .. "\t" .. tostring(k) .. " = ")
            printTable(v, lv)
        else

            print(lv .. "\t" .. tostring(k) .. " = " .. tostring(v) .. ",")
        end
    end
    print(lv .. "},")
end

function setPad0(styleObj)
    lvgl.style_set_pad_top(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_pad_bottom(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_pad_left(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_pad_right(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_pad_inner(styleObj, lvgl.STATE_DEFAULT, 0)
end

function setMargin0(styleObj)
    lvgl.style_set_margin_top(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_margin_bottom(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_margin_left(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_margin_right(styleObj, lvgl.STATE_DEFAULT, 0)
end

function removeSelfStyle(styleObj)
    setPad0(styleObj)
    setMargin0(styleObj)
    lvgl.style_set_radius(styleObj, lvgl.STATE_DEFAULT, 0)
    lvgl.style_set_border_width(styleObj, lvgl.STATE_DEFAULT, 0)
end

function musicListInit()

    tabview = lvgl.tabview_create(screen, nil)

    onlineTab = lvgl.tabview_add_tab(tabview, "在线音乐")
    localTab = lvgl.tabview_add_tab(tabview, "本地音乐")

    onlineTabStyle = lvgl.style_create()
    removeSelfStyle(onlineTabStyle)
    lvgl.obj_add_style(onlineTab, lvgl.TABVIEW_PART_BG_SCROLLABLE, onlineTabStyle)

    onlineList = lvgl.list_create(onlineTab, nil);
    lvgl.obj_set_size(onlineList, 160, 69);
    lvgl.obj_set_pos(onlineList, 0, 0);
    lvgl.obj_align(onlineList, nil, lvgl.ALIGN_CENTER, 0, 0);
    list_btn1 = lvgl.list_add_btn(onlineList, nil, lvgl.SYMBOL_FILE .. " New1")
    list_btn2 = lvgl.list_add_btn(onlineList, nil, lvgl.SYMBOL_FILE .. " New2")

    onlineListBtnStyle = lvgl.style_create()
    removeSelfStyle(onlineListBtnStyle)
    lvgl.obj_add_style(list_btn1, lvgl.BTN_PART_MAIN, onlineListBtnStyle)
    lvgl.obj_add_style(list_btn2, lvgl.BTN_PART_MAIN, onlineListBtnStyle)

    onlineListStyle = lvgl.style_create()
    removeSelfStyle(onlineListStyle)
    lvgl.obj_add_style(onlineList, lvgl.LIST_PART_BG, onlineListStyle)

    localTabLabel = lvgl.label_create(localTab, nil)
    lvgl.label_set_text(localTabLabel, "本地音乐列表")

    tabBgStyle = lvgl.style_create()
    setPad0(tabBgStyle)
    lvgl.style_set_bg_color(tabBgStyle, lvgl.STATE_DEFAULT, lvgl.color_make(0x00, 0x00, 0x00))
    lvgl.style_set_bg_opa(tabBgStyle, lvgl.STATE_DEFAULT, 255)
    lvgl.style_set_text_color(tabBgStyle, lvgl.STATE_DEFAULT, lvgl.color_make(0x00, 0x00, 0x00))
    lvgl.obj_add_style(tabview, lvgl.TABVIEW_PART_TAB_BG, tabBgStyle)

    tabBtnStyle = lvgl.style_create()
    setPad0(tabBtnStyle)
    lvgl.style_set_bg_color(tabBtnStyle, lvgl.STATE_DEFAULT, lvgl.color_make(0xFF, 0xFF, 0xFF))
    lvgl.style_set_bg_opa(tabBtnStyle, lvgl.STATE_DEFAULT, 255)
    lvgl.style_set_bg_color(tabBtnStyle, lvgl.STATE_CHECKED, lvgl.color_make(0xFF, 0x00, 0x00))
    lvgl.style_set_bg_opa(tabBtnStyle, lvgl.STATE_CHECKED, 255)
    lvgl.style_set_text_color(tabBtnStyle, lvgl.STATE_CHECKED, lvgl.color_make(0xFF, 0xFF, 0xFF))
    lvgl.obj_add_style(tabview, lvgl.TABVIEW_PART_TAB_BTN, tabBtnStyle)

    tabIndicStyle = lvgl.style_create()
    lvgl.style_set_size(tabIndicStyle, lvgl.STATE_DEFAULT, 0)
    lvgl.obj_add_style(tabview, lvgl.TABVIEW_PART_INDIC, tabIndicStyle)

    -- index = 0
    -- while true do
    --     if index > 1 then
    --         index = 0
    --     end
    --     lvgl.tabview_set_tab_act(tabview, index, lvgl.ANIM_ON)
    --     index = index + 1
    --     sys.wait(1000)
    -- end
end

function getRemoteMusicList()
    local res, code, body = httpLib.request("GET", "http://192.168.0.103:2333/getMusics")
    print(res, code, body)
end

function getLocalMusicList()

end

sys.taskInit(function()
    spiLcd = spi.deviceSetup(2, 7, 0, 0, 8, 60 * 1000 * 1000, spi.MSB, 1, 1)

    assert(spiLcd ~= nil, tag .. ".deviceSetup ERROR")

    assert(lcd.init("st7735v", {
        port = "device",
        pin_dc = 6,
        pin_rst = 10,
        pin_pwr = 11,
        direction = 3,
        w = 160,
        h = 80,
        xoffset = 0,
        yoffset = 24
    }, spiLcd) == true, tag .. ".lcd.init ERROR")

    lcd.invoff()

    assert(lvgl.init() == true, tag .. ".lvgl.init ERROR")
    screen = lvgl.scr_act()

    font = lvgl.font_get("opposans_m_8")
    lvgl.obj_set_style_local_text_font(screen, lvgl.OBJ_PART_MAIN, lvgl.STATE_DEFAULT, font)

    label = lvgl.label_create(screen, nil)
    lvgl.label_set_text(label, "等待wifi连接中 . . .")
    lvgl.label_set_align(label, lvgl.LABEL_ALIGN_CENTER)
    lvgl.obj_set_width(label, 160)
    lvgl.obj_align(label, nil, lvgl.ALIGN_CENTER, 0, 0)
    local connectRes = wifiLib.connect("Jeremy", "123456")
    log.info(tag .. ".connectRes", connectRes)
    if connectRes == false then
        lvgl.obj_del(label)
        label = lvgl.label_create(screen, nil)
        lvgl.label_set_text(label, "wifi连接失败, 20s后重启. . .")
        lvgl.label_set_align(label, lvgl.LABEL_ALIGN_CENTER)
        lvgl.obj_set_width(label, 160)
        lvgl.obj_align(label, nil, lvgl.ALIGN_CENTER, 0, 0)
        sys.wait(20000)
        rtos.reboot()
    end
    lvgl.obj_del(label)
    label = lvgl.label_create(screen, nil)
    lvgl.label_set_text(label, "wifi连接成功,获取音乐列表中. . .")
    lvgl.label_set_align(label, lvgl.LABEL_ALIGN_CENTER)
    lvgl.obj_set_width(label, 160)
    lvgl.obj_align(label, nil, lvgl.ALIGN_CENTER, 0, 0)
    log.info(tag .. ".meminfo", rtos.meminfo("sys"))
    log.info(tag .. ".meminfo", rtos.meminfo("lua"))
    getRemoteMusicList()
    musicListInit()
end)

sys.run()
