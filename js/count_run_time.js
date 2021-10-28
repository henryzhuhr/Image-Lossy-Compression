function siteTime() {
    window.setTimeout("siteTime()", 1000);
    var seconds = 1000;
    var minutes = seconds * 60;
    var hours = minutes * 60;
    var days = hours * 24;
    var years = days * 365;
    var today = new Date();
    var todayYear = today.getFullYear();
    var todayMonth = today.getMonth() + 1;
    var todayDate = today.getDate();
    var todayHour = today.getHours();
    var todayMinute = today.getMinutes();
    var todaySecond = today.getSeconds();
    /* Date.UTC() -- 返回date对象距世界标准时间(UTC)1970年1月1日午夜之间的毫秒数(时间戳)
    year - 作为date对象的年份，为4位年份值
    month - 0-11之间的整数，做为date对象的月份
    day - 1-31之间的整数，做为date对象的天数
    hours - 0(午夜24点)-23之间的整数，做为date对象的小时数
    minutes - 0-59之间的整数，做为date对象的分钟数
    seconds - 0-59之间的整数，做为date对象的秒数
    microseconds - 0-999之间的整数，做为date对象的毫秒数 */

    //计划考研的日子，6月20日毕业典礼结束后，人生需要继续努力，加油，看到这句话的朋友们！
    //北京时间 20221-09-01 22:06:00 
    var t1 = Date.UTC(2021, 09, 01, 22, 06, 00);

    var t2 = Date.UTC(todayYear, todayMonth, todayDate, todayHour, todayMinute, todaySecond);
    var diff = t2 - t1;
    var diffYears = Math.floor(diff / years);
    var diffDays = Math.floor((diff / days) - diffYears * 365);
    var diffHours = Math.floor((diff - (diffYears * 365 + diffDays) * days) / hours);
    var diffMinutes = Math.floor((diff - (diffYears * 365 + diffDays) * days - diffHours * hours) / minutes);
    var diffSeconds = Math.floor((diff - (diffYears * 365 + diffDays) * days - diffHours * hours - diffMinutes * minutes) / seconds);
    document.getElementById("sitetime").innerHTML = " 网站已运行 " + diffYears + " 年 " + diffDays + " 天 " + diffHours + " 小时 " + diffMinutes + " 分 " + diffSeconds + " 秒 ";
}
siteTime();