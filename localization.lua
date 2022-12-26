local function _4Xcb(_rwxq)
    return _rwxq ~= nil and type(_rwxq) == "table"
end
local function _30Vl(_oyGf)
    return _oyGf ~= nil and type(_oyGf) == "string"
end
local function _qJzU(_vczb)
    return _30Vl(_vczb) and #_vczb > 0x0
end
local _sgQO = {}
_sgQO.fallback = "en"
_sgQO.language = _sgQO.fallback
_sgQO.supportedLanguage = _sgQO.fallback
function _sgQO:SetLanguage(_Sddr)
    local _bo2c = self:GetSupportedLanguage(_Sddr)
    self.language = _Sddr or self:GetLanguage()
    self.supportedLanguage = _bo2c
    self.strings = self:GetStrings(_bo2c)
end
function _sgQO:L2S(_wcc8)
    local _sYdA = self["strings_" .. _wcc8]
    if _sYdA then
        _sYdA._LANGUAGE = _wcc8
    elseif self["strings_" .. self.fallback] then
        self["strings_" .. self.fallback]._LANGUAGE = self.fallback
    end
    return _sYdA or self["strings_" .. self.fallback]
end
function _sgQO:GetLanguage()
    return string.lower(LanguageTranslator and LanguageTranslator.defaultlang or self.fallback)
end
function _sgQO:GetSupportedLanguage(_MnXS)
    local _mtQg = _MnXS or self:GetLanguage()
    if _mtQg and type(_mtQg) == "string" then
        _mtQg = string.lower(_mtQg)
        return self.languageAliasTable[_mtQg] or self.fallback
    end
    return self.fallback
end
function _sgQO:GetStrings(_FKw2)
    local _xaSl = self:GetSupportedLanguage(_FKw2)
    local _QTIZ = self:L2S(_xaSl)
    _QTIZ.GetString = function(_XDj9, _FETo, _GBCH)
        _FETo = string.lower(_FETo)
        return (_qJzU(_XDj9[_FETo]) and _XDj9[_FETo]) or (_30Vl(self.strings_en[_FETo]) and self.strings_en[_FETo]) or _GBCH or "N/A"
    end
    _QTIZ.HasString = function(_89zf, _t7Bz)
        _t7Bz = string.lower(_t7Bz)
        return _qJzU(_89zf[_t7Bz]) or _30Vl(self.strings_en[_t7Bz])
    end
    _QTIZ.GetStrings = function(_w6WA, _19Ov)
        local _t1rI = _4Xcb(_w6WA[_19Ov]) and _w6WA[_19Ov] or {}
        if not _t1rI.GetString then
            _t1rI.GetString = function(_qnMi, _dXmR, _JCKe)
                return _qnMi[_dXmR] or (_4Xcb(self.strings_en[_19Ov]) and self.strings_en[_19Ov][_dXmR]) or _JCKe or "N/A"
            end
        end
        return _t1rI
    end
    if not self.strings then
        self.language = _FKw2 or self:GetLanguage()
        self.supportedLanguage = _xaSl
        self.strings = _QTIZ
    end
    return _QTIZ
end
function _sgQO:GetString(_iY3y, _KN1S)
    if not self.strings then
        self:GetStrings()
    end
    return self.strings:GetString(_iY3y, _KN1S)
end
function _sgQO:HasString(_riC0)
    if not self.strings then
        self:GetStrings()
    end
    return self.strings:HasString(_riC0)
end
_sgQO.strings_en = { menu_title = "SHB Settings", menu_gstyle = "Global HB Style:", menu_cstyle = "Player HB Style:", menu_bstyle = "Boss HB Style:", menu_preview = "Preview:", menu_value = "Health Value:", menu_length = "HB Length:", menu_thickness = "HB Thickness:", menu_pos = "HB Position:", menu_color = "HB Color:", menu_opacity = "HB Opacity:", menu_dd = "Damage Display:", menu_limit = "Limit:", menu_anim = "HB Animation:", menu_wallhb = "Wall HB:", menu_hotkey = "Hotkey:", menu_icon = "Icon:", menu_visit = "Visit:", hint_gstyle = "HB Style for ordinary creatures.", hint_cstyle = "Your own HB style! Different from other players!", hint_value = "Show health value or not.", hint_thickness = "Not working with text healthbar.", hint_opacity = "Not working with text healthbar.", hint_dd = "Show damage dealt and health healed?", hint_limit = "Limit the number of HB displayed to increase performance?", hint_anim = "Disable animation to increase performance?", hint_wallhb = "Disable wall healthbars to increase performance?", hint_hotkey = "Hotkey to turn on/off setting window.", hint_icon = "Show the heart icon?", hint_overhead2 = "Health value shown inside healthbar.", hint_dynamic = "Color varies with health percentage of the mob.", hint_dynamic2 = "Color varies with hostility of the mob.", hint_dynamic_dark = "Darker dynamic color.", hint_thb = "No preview for text health bar.", hint_apply = "Apply current settings!", hint_fixedthickness = "Fixed thickness(unit: pixel)!", hint_dynamicthickness = "Dynamic thickness(varies with mob's size)!", hint_mistake = "Looks like you disabled both icon and hotkey! If it was a mistake, enter 'shb.reset()' in console!", hint_hotkeyreminder = "Hint: you can press %s to open SHB setting window!", followcfg = "Use Configuration", followglobal = "Use Global Style", nomodification = "No unauthorized modification is allowed!", title = "SimpleHealthBar", draggable = "Mouse Left to drag", about = "About", abouttext = " ", more = "More", back = "Back", receiveitem = "New item obtained", thx = "Thanks for supporting!", happysf = "Happy Spring Festival!", chosenone = "Congrats!", message = "Message", locked = "Locked", unlock = "Unlock", ok = "OK", tieba = "Baidu Forum", steam = "Steam", getplayerid = "Get Player Id", playerid = "Player Id", unlimited = "Unlimited", standard = "Standard", shadow = "Shadow", claw = "Claw", victorian = "Victorian", buckhorn = "Buckhorn", pixel = "Pixel", simple = "Simple", basic = "Basic", hidden = "Hidden", heart = "Heart", circle = "Circle", square = "Square", diamond = "Diamond", star = "Star", square2 = "Square2", apply = "Apply", on = "ON", off = "OFF", bottom = "Bottom", overhead = "Overhead", overhead2 = "Overhead2", dynamic = "Dynamic", dynamic2 = "Dynamic_Hostility", dynamic_dark = "Dynamic_Dark", white = "White", black = "Black", red = "Red", green = "Green", blue = "Blue", yellow = "Yellow", cyan = "Cyan", magenta = "Magenta", gray = "Gray", orange = "Orange", purple = "Purple", none = "None", }
_sgQO.strings_chs = { menu_title = "简易血条设置", menu_gstyle = "全局血条样式:", menu_cstyle = "玩家血条样式:", menu_bstyle = "Boss血条样式:", menu_preview = "预览:", menu_value = "生命值:", menu_length = "血条长度:", menu_thickness = "血条厚度:", menu_pos = "血条位置:", menu_color = "血条颜色:", menu_opacity = "不透明度:", menu_dd = "伤害显示:", menu_limit = "数量限制:", menu_anim = "血条动画:", menu_wallhb = "墙体血条:", menu_hotkey = "热键:", menu_icon = "图标:", menu_visit = "访问:", hint_gstyle = "普通生物的血条样式", hint_cstyle = "你自己的样式，与其他玩家不同的", hint_value = "是否显示血量", hint_thickness = "字符血条此项无效", hint_opacity = "字符血条此项无效", hint_dd = "显示造成的伤害和治疗值？", hint_limit = "限制显示的血条数量来防卡顿？", hint_anim = "关闭动画来防止卡顿？", hint_wallhb = "关闭墙的血条以防止卡顿？", hint_hotkey = "用以开启和关闭设置窗口的热键", hint_icon = "是否显示心形图标？", hint_overhead2 = "生命值显示在血条内", hint_dynamic = "颜色随生物生命百分比而变化", hint_dynamic2 = "颜色随生物敌意而变化", hint_dynamic_dark = "更暗的动态颜色", hint_thb = "文本血条无法预览", hint_apply = "应用当前设置！", hint_fixedthickness = "固定厚度(单位: 像素)!", hint_dynamicthickness = "动态厚度(随生物体积变化)!", hint_mistake = "检测到你似乎同时关闭了图标和热键！如果你只是手滑了，那么在控制台输入'shb.reset()'进行重置！", hint_hotkeyreminder = "温馨提示：你可以按%s键打开简易血条设置窗口！", followcfg = "跟随mod配置", followglobal = "使用全局样式", nomodification = "未经许可禁止擅自修改！", title = "简易血条", draggable = "鼠标左键可拖动", about = "关于", abouttext = "有问题访问贴吧steam留言", more = "更多", back = "返回", receiveitem = "恭喜您获得了", thx = "感谢您的支持！", happysf = "新年快乐！", chosenone = "就决定是你了！", message = "消息", locked = "未解锁", unlock = "解锁", ok = "确定", tieba = "百度贴吧", steam = "Steam", getplayerid = "查看玩家ID", playerid = "玩家ID", unlimited = "不限制", standard = "标准", shadow = "暗影", claw = "利爪", victorian = "维多利亚", buckhorn = "鹿角", pixel = "像素", simple = "简易", basic = "基础", hidden = "隐藏", heart = "心形", circle = "圆形", square = "方形", diamond = "钻石", star = "五角星", square2 = "方形2", apply = "应用", on = "开启", off = "关闭", bottom = "底部", overhead = "头顶", overhead2 = "头顶2", dynamic = "动态", dynamic2 = "动态_敌意", dynamic_dark = "动态_暗", white = "白", black = "黑", red = "红", green = "绿", blue = "蓝", yellow = "黄", cyan = "青", magenta = "品红", gray = "灰", orange = "橙", purple = "紫", none = "无", }
_sgQO.strings_kr = { menu_title = "체력바 설정", menu_gstyle = "전체 스타일:", menu_cstyle = "내 스타일:", menu_bstyle = "보스몹 스타일:", menu_preview = "미리보기:", menu_value = "체력 수치:", menu_length = "바 길이:", menu_thickness = "바 두께:", menu_pos = "바 위치:", menu_color = "바 색상:", menu_opacity = "불투명도:", menu_dd = "데미지 출력:", menu_limit = "개수 제한:", menu_anim = "바 애니메이션:", menu_wallhb = "벽 체력바:", menu_hotkey = "단축키:", menu_icon = "설정 버튼:", menu_visit = "방문:", hint_gstyle = "일반적인 생물의 체력바 스타일.", hint_cstyle = "당신의 체력바 스타일，다른 구성원들과 차별화 하세요!", hint_value = "체력 수치를 표시할 것인가 아닌가.", hint_thickness = "체력바 두께, 문자형 스타일은 영향받지 않습니다.", hint_opacity = "체력바 불투명도, 문자형 스타일은 영향받지 않습니다.", hint_dd = "데미지 효과를 표시하겠습니까?", hint_limit = "성능향상을 위해 표시 개수를 제한하겠습니까?", hint_anim = "성능향상을 위해 애니메이션을 끄시겠습니까?", hint_wallhb = "성능향상을 위해 벽 체력바를 끄시겠습니까?", hint_hotkey = "설정창의 단축키", hint_icon = "설정창 버튼을 표시하겠습니까?", hint_overhead2 = "수치를 체력바 내부에 표시.", hint_dynamic = "몹의 체력 수준에 따라 체력바 색상 변화.", hint_dynamic2 = "몹의 적대적 성향에 따라 체력바 색상 변화.", hint_dynamic_dark = "좀 더 어두운 색상 변화.", hint_thb = "문자형 체력바에 미리보기 없음.", hint_apply = "현재 설정을 적용하기!", hint_fixedthickness = "고정 두께(단위: 픽셀)!", hint_dynamicthickness = "가변 두께(몹의 크기에 따라 변화)!", followcfg = "모드 설정을 사용", followglobal = "전역 스타일 사용", nomodification = "설정을 바꿀 권한이 없습니다!", title = "간단한 체력바", draggable = "마우스 왼쪽 드래그 가능", about = "소개", abouttext = "문의 사항은 스팀 창작마당을 통해서 연락 주십시오.", more = "더보기", back = "뒤로", receiveitem = "새 아이템 획득", thx = "지원해 주셔서 감사합니다!", happysf = "행복한 봄축제 되세요!", chosenone = "당신의 선택에 달려있습니다!", message = "메세지", locked = "잠김", unlock = "잠금 해제", ok = "OK", tieba = "바이두 포럼", steam = "스팀", getplayerid = "게이머ID 확인", playerid = "게이머ID", unlimited = "무제한", standard = "표준", shadow = "그림자", claw = "클로", victorian = "빅토리안", buckhorn = "벅혼", pixel = "픽셀", simple = "단순", basic = "기본", hidden = "숨김", heart = "하트", circle = "원형", square = "사각형", diamond = "다이아몬드형", star = "별모양", square2 = "사각형2", apply = "적용", on = "켜기", off = "끄기", bottom = "하단", overhead = "머리위", overhead2 = "머리위2", dynamic = "변화", dynamic2 = "변화(적대감)", dynamic_dark = "변화(어두움)", white = "하양", black = "검정", red = "빨강", green = "초록", blue = "파랑", yellow = "노랑", cyan = "하늘", magenta = "주홍", gray = "회색", orange = "오렌지", purple = "보라", none = "없음" }
_sgQO.languageAliasTable = { en = "en", english = "en", chs = "chs", cn = "chs", sc = "chs", zh = "chs", zhr = "chs", chinese = "chs", simplifiedchinese = "chs", cht = "cht", tw = "cht", traditionalchinese = "cht", kr = "kr", ko = "kr", kor = "kr", korean = "kr", }
return _sgQO