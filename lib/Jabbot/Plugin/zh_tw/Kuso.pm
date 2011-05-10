package Jabbot::Plugin::zh_tw::Kuso;
use Jabbot::Plugin;

my @foods = (
    "永康街肉圓", "排骨飯" , "酸白鍋",
    "客家菜" , "大食團" , "燒餅油條",
    "姊妹花雞排", "魚排飯", "堤拉米蘇",
    "小籠包", "黯然銷魂飯", "火雲荷包蛋",
    "輻射污染魚","水晶膠跟雙氧水","魚排飯",
    "別吃了吧？", "再吃會胖喔", "胖媽雞排",
    "慚愧棒棒糖", "誠實豆沙包", "魚酥羹麵",
    "牛肉燴飯", "宮保雞丁", "三鮮炒麵",
    "更營養水餃", "大腸","小腸","大腸包小腸",
    "牛肉麵","雞絲麵","御飯糰","咖哩飯",
    "滷味","老婆餅","太陽餅","潤餅","可麗餅",
    "餃子","鍋貼","麻辣鍋","清粥小菜","粗茶淡飯",
    "是洋蔥", "山東刀削麵","豬腳麵線","布丁",
    "大布丁", "統一布丁","爛飯糰","蔬食",
    "壯志饑餐紅燒肉，笑談渴飲小米酒",
    "黑鮪魚", "迴轉壽司", "壽司便當","橙汁雞腿",
    "筍子雞肉","沙朗牛排", "麥當勞薯條","麥當勞薯叔",
    "油豆腐粉絲湯","紅松雞","八寶鴨","椒鹽排骨","螞蟻上樹","上海菜飯",
    "清蒸桂花魚","豉汁蒸倉魚","豉汁蒸鱔","豉汁蒸烏頭","鹹檸檬蒸烏頭",
    "西湖醋魚","火腩三文魚頭煲","火腩大鱔煲","龍井蝦仁","油豆腐粉絲湯",
    "蝦米清蒸豆腐","麻婆豆腐","碗豆黃","螞蟻上樹","豆角炒肉鬆","金銀蛋莧菜",
    "上海菜飯","芙蓉蛋","鹹蛋蒸水蛋","鹹蛋蒸肉餅","金銀蛋莧菜","皮蛋瘦肉粥",
    "蛋炒飯","紅松雞","芙蓉蛋","中式牛仔骨","洋蔥豬扒","八寶鴨","金針雲耳蒸雞",
    "芋頭糕","蘿蔔糕","清蒸桂花魚","豉汁蒸倉魚","豉汁蒸鱔","豉汁蒸烏頭",
    "鹹檸檬蒸烏頭","蝦米清蒸豆腐","鹹蛋蒸水蛋","鹹蛋蒸肉餅","百花釀冬菇",
    "皮蛋瘦肉粥","炒貴刁","干炒牛河","豉油皇炒麵","生炒牛肉飯","生炒糯米飯",
    "蛋炒飯","上海菜飯","青紅蘿蔔鯊魚骨湯","青紅籮蔔豬骨湯",
    "粟米紅籮蔔豬骨湯","菜乾豬骨湯","雪耳木瓜豬骨湯","合掌瓜瘦肉湯",
    "清保涼瘦肉湯","油豆腐粉絲湯","蕃茄薯仔魚湯","椰子煲雞湯",
    "海底椰合桃花生煲雞湯","茶樹菇雞湯","猴頭菇瘦肉湯",
    "猴頭菇桑椹子金蟬花湯","猴頭菇靈芝金霍斛湯","蓮藕章魚湯",
    "豬腳筋瘦肉湯","西湖牛肉羹","碗仔翅","雜碎麵",
    "小便當", "大便當", "超大便當"
);

sub can_answer { 1 }

sub answer {
    my ($text) = @args;

    my $reply;

    my $confidence = 0.5;

    given($text) {
        when("!") {
            $reply = "驚嘆號是棒槌";
        }
        when(/還不賴/) {
            $self->{habiulai_count} ||= 0;
            $self->{habiulai_count} +=  1;

            if ($self->{habiulai_count} > 1 + 4 * rand) {
                $reply = "還不賴！";
                $confidence = 1;
                $self->{habiulai_count} = 0;
            }
        }
        when(/^make\s+me\s?./i) {
            $reply = "WHAT? MAKE IT YOURSELF"
        }
        when(/^sudo\s+make/) {
            $reply = "OKAY"
        }
        when(/(?:早上|中午|晚上|早餐|午餐|晚餐|宵夜|現在|\A)要?(吃|喫)(啥|什麼)?/) {
            $reply = "";
            $reply .= $foods[ int(rand( @foods )) ];
        }
    }

    return {
        content => $reply,
        confidence => $confidence
    } if $reply;
}

1;
