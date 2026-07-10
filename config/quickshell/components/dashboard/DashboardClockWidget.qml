import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell.Io

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: root.theme.cardBackground
    radius: root.theme.cardRadius
    border.width: 1
    border.color: root.theme.cardBorder

    property int todayContributions: 0
    property int leetcodeStreak: 0
    property var monthsModel: []

    function formatDateString(d) {
        var yyyy = d.getFullYear();
        var mm = d.getMonth() + 1;
        var dd = d.getDate();
        return yyyy + "-" + (mm < 10 ? "0" + mm : mm) + "-" + (dd < 10 ? "0" + dd : dd);
    }

    function generateMonthsData(contributions) {
        if (!contributions || contributions.length === 0) {
            return [];
        }
        
        var contribMap = {};
        for (var j = 0; j < contributions.length; j++) {
            var entry = contributions[j];
            contribMap[entry.date] = entry;
        }
        
        var today = new Date();
        var currentYear = today.getFullYear();
        var currentMonth = today.getMonth(); // 0-indexed
        
        var months = [];
        
        // Generate data for 2 months ago, 1 month ago, and current month
        for (var mOffset = -2; mOffset <= 0; mOffset++) {
            var targetMonth = currentMonth + mOffset;
            var targetYear = currentYear;
            if (targetMonth < 0) {
                targetMonth += 12;
                targetYear -= 1;
            }
            
            var firstDay = new Date(targetYear, targetMonth, 1);
            var startDayOfWeek = (firstDay.getDay() + 6) % 7; // Mon = 0, ..., Sun = 6
            var numDays = new Date(targetYear, targetMonth + 1, 0).getDate();
            
            var monthName = Qt.formatDate(firstDay, "MMM yyyy");
            var shortMonthName = Qt.formatDate(firstDay, "MMM");
            
            var cells = [];
            
            // 1. Add blank cells before the first day of the month
            for (var i = 0; i < startDayOfWeek; i++) {
                cells.push({
                    day: 0,
                    date: "",
                    count: 0,
                    level: -1
                });
            }
            
            // 2. Add cells for each day of the month
            for (var day = 1; day <= numDays; day++) {
                var dateObj = new Date(targetYear, targetMonth, day);
                var dateStr = formatDateString(dateObj);
                
                var isFuture = dateObj.getTime() > today.getTime();
                
                var count = 0;
                var level = 0;
                if (contribMap[dateStr] && !isFuture) {
                    count = contribMap[dateStr].count;
                    level = contribMap[dateStr].level;
                } else if (isFuture) {
                    level = -2;
                }
                
                cells.push({
                    day: day,
                    date: dateStr,
                    count: count,
                    level: level === -2 ? 0 : level,
                    isToday: (dateStr === formatDateString(today))
                });
            }
            
            // 3. Pad to end of the week (multiple of 7)
            var totalCells = cells.length;
            var nextMultipleOf7 = Math.ceil(totalCells / 7) * 7;
            if (nextMultipleOf7 < 35) nextMultipleOf7 = 35;
            
            for (var k = totalCells; k < nextMultipleOf7; k++) {
                cells.push({
                    day: 0,
                    date: "",
                    count: 0,
                    level: -1
                });
            }
            
            months.push({
                name: shortMonthName,
                fullName: monthName,
                cells: cells
            });
        }
        
        return months;
    }

    function updateCalendarData(contributions) {
        if (!contributions || contributions.length === 0) {
            monthsModel = [];
            return;
        }
        
        monthsModel = generateMonthsData(contributions);
        
        // Set today's contributions count
        var today = new Date();
        var todayStr = formatDateString(today);
        var foundCount = 0;
        for (var j = 0; j < contributions.length; j++) {
            if (contributions[j].date === todayStr) {
                foundCount = contributions[j].count;
                break;
            }
        }
        todayContributions = foundCount;
        gitDisplay.text = todayContributions + " today";
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12
        
        Text {
            id: greetingDisplay
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                var now = new Date()
                var hrs = now.getHours()
                var greeting = "Welcome back"
                if (hrs < 12) greeting = "Good morning"
                else if (hrs < 18) greeting = "Good afternoon"
                else greeting = "Good evening"
                return greeting + ", " + root.homePath.split("/").pop() + "!"
            }
            color: root.walColor8
            font.pixelSize: 14
            font.family: root.theme.textFont
        }

        // Stats Status Row (GitHub + LeetCode)
        Row {
            id: statsRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            
            // GitHub Info
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: "󰊤"
                    color: root.walColor2
                    font.pixelSize: 13
                    font.family: root.theme.iconFont
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: gitDisplay
                    text: "Loading..."
                    color: root.walColor8
                    font.pixelSize: 11
                    font.family: root.theme.textFont
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // LeetCode Info
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: ""
                    color: "#FFA116"
                    font.pixelSize: 13
                    font.family: root.theme.iconFont
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: leetcodeDisplay
                    text: "Loading..."
                    color: root.walColor8
                    font.pixelSize: 11
                    font.family: root.theme.textFont
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // 3 Calendar Months Row Layout (Fills the ~348px width)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            visible: monthsModel.length > 0

            Repeater {
                model: monthsModel
                delegate: Column {
                    spacing: 6
                    
                    Text {
                        text: modelData.name
                        color: root.walColor8
                        font.pixelSize: 10
                        font.family: root.theme.textFont
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Weekday Headers for this month
                    Row {
                        spacing: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        Repeater {
                            model: ["M", "T", "W", "T", "F", "S", "S"]
                            delegate: Text {
                                width: 12
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                color: root.walColor8
                                font.pixelSize: 8
                                font.family: root.theme.textFont
                                font.bold: true
                            }
                        }
                    }

                    // Grid of squares (7 columns)
                    Grid {
                        columns: 7
                        spacing: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Repeater {
                            model: modelData.cells
                            delegate: Rectangle {
                                width: 12
                                height: 12
                                radius: 3
                                visible: modelData.level !== -1
                                color: {
                                    if (modelData.level === 0) return Qt.rgba(1, 1, 1, 0.08);
                                    if (modelData.level === 1) return "#0e4429";
                                    if (modelData.level === 2) return "#006d32";
                                    if (modelData.level === 3) return "#26a641";
                                    if (modelData.level === 4) return "#39d353";
                                    return Qt.rgba(1, 1, 1, 0.08);
                                }
                                
                                border.width: modelData.isToday ? 1.5 : (hoverArea.containsMouse ? 1 : 0)
                                border.color: modelData.isToday ? root.walColor2 : root.walForeground
                                
                                MouseArea {
                                    id: hoverArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onContainsMouseChanged: {
                                        if (containsMouse) {
                                            var parts = modelData.date.split("-");
                                            var d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
                                            var formattedDate = Qt.formatDate(d, "MMM d, yyyy");
                                            gitDisplay.text = modelData.count + (modelData.count === 1 ? " contribution" : " contributions") + " on " + formattedDate;
                                            gitDisplay.color = root.walColor5;
                                        } else {
                                            gitDisplay.text = todayContributions + " today";
                                            gitDisplay.color = root.walColor8;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Color Legend
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            topPadding: 2
            visible: monthsModel.length > 0
            Text {
                text: "Less"
                color: root.walColor8
                font.pixelSize: 8
                font.family: root.theme.textFont
                anchors.verticalCenter: parent.verticalCenter
            }
            Repeater {
                model: [
                    Qt.rgba(1, 1, 1, 0.08),
                    "#0e4429",
                    "#006d32",
                    "#26a641",
                    "#39d353"
                ]
                delegate: Rectangle {
                    width: 8
                    height: 8
                    radius: 2
                    color: modelData
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "More"
                color: root.walColor8
                font.pixelSize: 8
                font.family: root.theme.textFont
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Process {
        id: gitContributionsProc
        command: ["bash", "-c", "username=$(git config --global user.name); [ -n \"$username\" ] && curl -s https://github-contributions-api.jogruber.de/v4/$username | jq -c . 2>/dev/null || echo '{\"contributions\":[]}'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data.trim());
                    if (parsed && parsed.contributions) {
                        updateCalendarData(parsed.contributions);
                    }
                } catch (e) {
                    console.log("Error parsing contributions JSON: " + e);
                }
            }
        }
    }

    Process {
        id: leetcodeProc
        command: ["bash", "-c", "username=$(git config --global user.name); [ -n \"$username\" ] && curl -s -X POST https://leetcode.com/graphql -H \"Content-Type: application/json\" -d '{\"query\": \"query userProfileCalendar($username: String!) { matchedUser(username: $username) { userCalendar { streak } } }\", \"variables\": {\"username\": \"'\"$username\"'\"}}' | jq -r '.data.matchedUser.userCalendar.streak' 2>/dev/null || echo '0'"]
        stdout: SplitParser {
            onRead: data => {
                var streak = parseInt(data.trim()) || 0;
                leetcodeStreak = streak;
                leetcodeDisplay.text = streak + " day streak";
            }
        }
    }

    Timer {
        id: gitRefreshTimer
        interval: 600000 // 10 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!gitContributionsProc.running) gitContributionsProc.running = true
            if (!leetcodeProc.running) leetcodeProc.running = true
        }
    }
}