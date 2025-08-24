import QtQuick 2.15
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root

    property color color1: plasmoid.configuration.color1
    property color color2: plasmoid.configuration.color2
    property int speed: plasmoid.configuration.speed

    property int fontSize: 14
    property var grid: []
    property var streams: []

    property string characterPool: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    function randomChar() {
        return characterPool.charAt(Math.floor(Math.random() * characterPool.length));
    }

    function initialize() {
        var newGrid = [];
        var newStreams = [];
        var newColumns = Math.floor(width / fontSize);
        var newRows = Math.floor(height / fontSize);

        for (var i = 0; i < newColumns; i++) {
            newGrid[i] = [];
            for (var j = 0; j < newRows; j++) {
                newGrid[i][j] = randomChar();
            }
        }

        for (var i = 0; i < newColumns / 4; i++) {
            newStreams.push({
                x: Math.floor(Math.random() * newColumns),
                y: Math.floor(Math.random() * newRows),
                length: Math.floor(Math.random() * (newRows / 2)) + 5
            });
        }
        root.grid = newGrid;
        root.streams = newStreams;
    }

    Component.onCompleted: {
        initialize();
    }

    onWidthChanged: initialize()
    onHeightChanged: initialize()

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext('2d');
            ctx.fillStyle = 'black';
            ctx.fillRect(0, 0, width, height);

            if (root.grid.length === 0) return;

            var columns = root.grid.length;
            var rows = root.grid[0].length;
            ctx.font = root.fontSize + 'px monospace';

            for (var i = 0; i < columns; i++) {
                for (var j = 0; j < rows; j++) {
                    var isStream = false;
                    for (var s = 0; s < root.streams.length; s++) {
                        if (i === root.streams[s].x && j >= root.streams[s].y && j < root.streams[s].y + root.streams[s].length) {
                            isStream = true;
                            break;
                        }
                    }
                    ctx.fillStyle = isStream ? root.color2 : root.color1;
                    ctx.fillText(root.grid[i][j], i * root.fontSize, j * root.fontSize);
                }
            }

            for (var s = 0; s < root.streams.length; s++) {
                root.streams[s].y++;
                if (root.streams[s].y > rows) {
                    root.streams[s].x = Math.floor(Math.random() * columns);
                    root.streams[s].y = -root.streams[s].length;
                }
            }

            for (var i = 0; i < 10; i++) {
                var x = Math.floor(Math.random() * columns);
                var y = Math.floor(Math.random() * rows);
                if (root.grid[x]) {
                    root.grid[x][y] = randomChar();
                }
            }
        }
    }

    Timer {
        interval: root.speed
        running: true
        repeat: true
        onTriggered: canvas.requestPaint()
    }
}
