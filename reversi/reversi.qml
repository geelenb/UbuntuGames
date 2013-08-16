import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "model.js" as Model

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: main
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename
    applicationName: "Reversi"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(40)
    height: units.gu(75)

    property string p1: "#DD4814"
    property string p0: "#2C001E"

    property bool busy: false

    // main functions
    function clicked(index) {
        if (!busy && Model.movePossible(Model.state, index)) {
            busy = true;
            Model.set(index);
            Model.switchTurn();
            syncToModel();
            flipWaitAnimation.start()
        }
    }

    property bool prevWasImpossible: false;

    function checkEnding() {
        if (Model.score[0] + Model.score[1] !== 64)
            return false
        PopupUtils.open(Model.score[0] === Model.score[1] ? tieDialog : winDialog, null)
        return true;
    }

    function machineMove() {
        var bestMove = Model.getBestMove(difficulty.selectedIndex, Model.state)[0];
        Model.set(bestMove);
        Model.switchTurn();
        syncToModel();
        checkEnding();
    }

    Component.onCompleted: reset();

    function syncToModel() {
        for (var i = 0; i < 8; i++)
            for (var j = 0; j < 8; j++)
                repeater.itemAt(i * 8 + j).setToPlayer(Model.state[i][j]);

        markPossibleMoves();
        scoreRect.update()
    }

    function reset() {
        if (playSound.checked)
            resetSound.play();
        Model.reset();
        syncToModel();
        flipWaitAnimation.start();
    }

    SequentialAnimation {
        id: flipWaitAnimation
        PauseAnimation { duration: 500 }
        ScriptAction {
            script: {
                if (!checkEnding() && againstMachine.checked && Model.turn == goFirst.checked)
                    machineMove();
                busy = false;
            }
        }
    }

    function markPossibleMoves() {
        var posMoves = Model.getPossibleMoves(Model.state);
        for (var i = 0; i < posMoves.length; i++)
            repeater.itemAt(posMoves[i]).markPossible();
    }


    Audio {
        id: resetSound
        source: "sounds/reset.wav"
    }

    Tabs {
        id: tabs
        Tab {
            title: i18n.tr("Reversi")

            page: Page {
                id: gamePage

                Rectangle {
                    id: scoreRect
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    height: units.gu(10)
                    color: "transparent"

                    function update() {
                        labelLeft.text = Model.score[0]
                        usLeft.visible = Model.turn === 0
                        labelRight.text = Model.score[1]
                        usRight.visible = Model.turn === 1
                    }

                    Rectangle {
                        id: leftScore
                        anchors.left: parent.left

                        height: parent.height
                        width: height
                        color: "transparent"

                        Label {
                            id: labelLeft
                            anchors.centerIn: parent
                            text: Model.score[0]
                            fontSize: "x-large"
                            color: p0
                        }
                        UbuntuShape {
                            id: usLeft
                            anchors.centerIn: parent

                            width: parent.width * 0.6
                            height: width

                            radius: "medium"
                            color: "transparent"
                            visible: Model.turn === 0
                        }
                    }

                    Rectangle {
                        id: rightScore
                        anchors.right: parent.right

                        height: parent.height
                        width: height
                        color: "transparent"

                        Label {
                            id: labelRight
                            anchors.centerIn: parent
                            text: Model.score[1]
                            fontSize: "x-large"
                            color: p1
                        }
                        UbuntuShape {
                            id: usRight
                            anchors.centerIn: parent

                            width: parent.width * 0.6
                            height: width

                            radius: "medium"
                            color: "transparent"
                            visible: Model.turn === 1
                        }
                    }
                }

                Rectangle {
                    id: gameField

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: scoreRect.bottom

                    width: Math.min(parent.width, parent.height) - units.gu(3)
                    height: width

                    color: "transparent"


                    Grid {
                        columns: 8
                        rows: 8
                        rowSpacing: units.gu(1)
                        columnSpacing: units.gu(1)

                        Repeater {
                            id : repeater
                            model: 64

                            Flipable {
                                id: flipable

                                width: (gameField.width - units.gu(7)) / 8
                                height: width

                                //either side can be either color
                                property bool flipped: false
                                property int currentPlayer: -1

                                function setToPlayer (player) {
                                    if (player === -1) {
                                        frontCell.color = "white"
                                        backCell.color = "white"
                                        return;
                                    }

                                    if (player !== currentPlayer) {
                                        if (flipable.flipped)
                                            frontCell.color = (player === 1) ? p1 : p0
                                        else
                                            backCell.color = (player === 1) ? p1 : p0

                                        flipable.flipped = !flipable.flipped
                                        currentPlayer = player
                                    }
                                }

                                function markPossible() {
                                    frontCell.color = UbuntuColors.warmGrey
                                    backCell.color = UbuntuColors.warmGrey
                                }

                                transform: Rotation {
                                    id: rotation
                                    origin.x: flipable.width/2
                                    origin.y: flipable.height/2
                                    axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
                                    angle: 0    // the default angle
                                }

                                states: State {
                                    name: "back"
                                    PropertyChanges { target: rotation; angle: 180 }
                                    when: flipable.flipped
                                }

                                transitions: Transition {
                                    NumberAnimation { target: rotation; property: "angle"; duration: 500 }
                                }

                                front: UbuntuShape {
                                    id: frontCell

                                    width: (gameField.width - units.gu(7)) / 8
                                    height: width

                                    radius: "medium"
                                    color: "white"
                                }

                                back: UbuntuShape {
                                    id: backCell

                                    width: (gameField.width - units.gu(7)) / 8
                                    height: width

                                    radius: "medium"
                                    color: "white"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: main.clicked(index)
                                }
                            }
                        }
                    }
                }

                tools: ToolbarItems {
                    id: toolbarTimer
                    ToolbarButton {
                        action: Action {
                            id: resetButton

                            iconSource: Qt.resolvedUrl("new.png")
                            text: i18n.tr("New Game")
                            onTriggered: PopupUtils.open(newDialog, null)
                       }
                    }
                }
            }
        }

        Tab {
            title: "Settings"
            page: Page {
                id: settingsPage

                Column {
                    anchors.fill: parent

                    ListItem.Standard {
                        text: i18n.tr("Sound")
                        control: Switch {
                            id: playSound
                            anchors.verticalCenter: parent.verticalCenter
                            checked: true
                        }
                    }

                    ListItem.Standard {
                        text: i18n.tr("Play against machine")
                        control: Switch {
                            id: againstMachine
                            anchors.verticalCenter: parent.verticalCenter
                            checked: true
                        }
                    }

                    ListItem.Standard {
                        text: i18n.tr("Go first")
                        control: Switch {
                            id: goFirst
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: againstMachine.checked
                            checked: true
                        }
                    }

                    ListItem.ValueSelector {
                        id: difficulty
                        text: i18n.tr("Difficulty")
                        values: ["1", "2", "3", "4", "5"]
                        selectedIndex: 1
                    }
                }
            }
        }
    }

    Component {
        id: winDialog

        Dialog {
            id: dialogue

            title: (!againstMachine.checked || (goFirst.checked != (Model.score[0] < Model.score[1]))) ? i18n.tr("Winner!") : i18n.tr("Loss!")
            text: i18n.tr(Model.score[0] < Model.score[1] ? "Orange won the game." : "Purple won the game.")

            Button {
                text: i18n.tr("Back")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(dialogue);
                }
            }

            Button {
                text: i18n.tr("New Game")
                onClicked: {
                    reset();
                    PopupUtils.close(dialogue);
                }
            }
        }
    }

    Component {
        id: newDialog

        Dialog {
            id: dialogue

            title: i18n.tr("Reset")
            text: i18n.tr("Reset the current game?")

            Button {
                text: i18n.tr("Back")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(dialogue);
                }
            }

            Button {
                text: i18n.tr("New Game")
                onClicked: {
                    reset();
                    PopupUtils.close(dialogue);
                }
            }
        }
    }

    Component {
        id: tieDialog

        Dialog {
            id: dialogue

            title: i18n.tr("Tie!")
            text: i18n.tr("It's a tied game!")

            Button {
                text: i18n.tr("Back")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(dialogue);
                }
            }

            Button {
                text: i18n.tr("New Game")
                onClicked: {
                    reset();
                    PopupUtils.close(dialogue);
                }
            }
        }
    }
}
