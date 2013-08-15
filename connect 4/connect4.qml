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
    applicationName: "connect4"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(40)
    height: units.gu(75)

    property string p1: "#DD4814"
    property string p0: "#2C001E"

    // main functions
    function clicked(index) {
        if (Model.possible(index)) {
            var newRow = Model.set(index);
            fallingAnimation.run(newRow * 7 + index % 7);
        }
    }

    function checkEnding(lastMove) {
        if (Model.haveWinner(lastMove % 7)) {
            PopupUtils.open(winDialog, null);
            return true;
        }

        var free = 0;
        for (var i = 0; i < 7; i++)
            if (Model.state[0][i] === -1)
                free++;

        if (free === 0) {
            PopupUtils.open(tieDialog, null);
            return true;
        }
        return false;
    }

    function machineMove() {
        var bestMove = Model.getBestMove(parseInt(difficulty.values[difficulty.selectedIndex]));
        var newRow = Model.set(bestMove);
        fallingAnimation2.run(newRow * 7 + bestMove);
        /*
        repeater.itemAt(newRow * 7 + bestMove % 7).setPlayer(Model.turn);

        checkEnding(bestMove % 7)
        Model.switchTurn();
        */
    }

    Component.onCompleted: reset();

    function reset() {
        if (playSound.checked)
            resetSound.play();
        Model.reset();
        for (var i = 0; i < 42; i++)
            repeater.itemAt(i).color = "white";

        fallingCoin.x = -10000
        fallingCoin2.x = -10000

        if (!goFirst.checked)
            machineMove();
    }

    Audio {
        id: resetSound
        source: "sounds/reset.wav"
    }

    Audio {
        id: dropSound
        source: "sounds/drop.wav"
    }

    Audio {
        id: dropSound2
        source: "sounds/drop.wav"
    }
    
    Tabs {
        id: tabs
        Tab {
            title: i18n.tr("Connect 4")

            page: Page {
                id: gamePage

                Rectangle {
                    id: gameField

                    anchors.centerIn: parent

                    width: Math.min(parent.width, parent.height * 7 / 6) - units.gu(3)
                    height: width * 6 / 7

                    color: "transparent"


                    Grid {
                        columns: 7
                        rows: 6
                        rowSpacing: units.gu(1)
                        columnSpacing: units.gu(1)

                        Repeater {
                            id : repeater
                            model: 42

                            UbuntuShape {
                                id: cell

                                width: (gameField.width - units.gu(6)) / 7
                                height: width

                                radius: "medium"
                                color: "white"



                                //only 0 or 1
                                function setPlayer(player) {
                                    if (player)
                                        color = p1
                                    else
                                        color = p0
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: main.clicked(index)
                                }
                            }
                        }
                    }

//                    Rectangle {
                    UbuntuShape {
                        id: fallingCoin

                        width: (gameField.width - units.gu(6)) / 7
                        height: width
                        color: "transparent"
//                        radius: "medium"

                        // to change
                        x: 0
                        y: 0

                        SequentialAnimation {
                            id: fallingAnimation

                            property int index: 0;

                            function run(i) {
                                index = i;
                                yChange.to = repeater.itemAt(i).y;
                                yChange.duration = yChange.to;
                                fallingCoin.x = repeater.itemAt(i).x;
                                fallingCoin.y = 0;
                                fallingCoin.color = Model.turn ? p1 : p0
                                repeater.itemAt(i).z = -11
                                if (playSound.checked)
                                    dropSound.play();
                                fallingAnimation.start();
                            }

                            NumberAnimation {
                                id: yChange
                                target: fallingCoin;
                                property: "y";
                                duration: 0
                                to: 0
                            }

                            ScriptAction {
                                script: {
                                    repeater.itemAt(fallingAnimation.index).setPlayer(Model.turn);

                                    if (!checkEnding(fallingAnimation.index)) {
                                        Model.switchTurn();
                                        if (againstMachine.checked && Model.turn == goFirst.checked)
                                            machineMove();
                                    }
                                }
                            }
                        }
                    }

                    UbuntuShape {
                        id: fallingCoin2

                        width: (gameField.width - units.gu(6)) / 7
                        height: width
                        color: "transparent"
//                        radius: "medium"

                        // to change
                        x: 0
                        y: 0

                        SequentialAnimation {
                            id: fallingAnimation2

                            property int index: 0;

                            function run(i) {
                                index = i;
                                yChange2.to = repeater.itemAt(i).y;
                                yChange2.duration = yChange2.to;
                                fallingCoin2.x = repeater.itemAt(i).x;
                                fallingCoin2.y = 0;
                                fallingCoin2.color = Model.turn ? p1 : p0
                                repeater.itemAt(i).z = -11
                                if (playSound.checked)
                                    dropSound2.play();
                                fallingAnimation2.start();
                            }

                            NumberAnimation {
                                id: yChange2
                                target: fallingCoin2;
                                property: "y";
                                duration: 0
                                to: 0
                            }

                            ScriptAction {
                                script: {
                                    repeater.itemAt(fallingAnimation2.index).setPlayer(Model.turn);

                                    if (!checkEnding(fallingAnimation2.index))
                                        Model.switchTurn();
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
                        values: ["1", "3", "5", "7"]
                        selectedIndex: 3
                    }
                }
            }
        }
    }

    Component {
        id: winDialog

        Dialog {
            id: dialogue

            title: (!againstMachine.checked || (goFirst.checked != Model.turn)) ? i18n.tr("Winner!") : i18n.tr("Loss!")
            text: i18n.tr(Model.turn ? "Orange won the game." : "Purple won the game.")

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
