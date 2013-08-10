import QtQuick 2.0
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

    // main functions
    function clicked(index) {
        if (Model.possible(index)) {
            var newRow = Model.set(index);
            repeater.itemAt(newRow * 7 + index % 7).setPlayer(Model.turn);

            if (Model.haveWinner(index % 7)) {
                PopupUtils.open(winDialog, null)
            } else {
                Model.switchTurn();
                if (againstMachine.checked)
                    machineMove();
            }
        }
    }

    function machineMove() {
        var bestMove = Model.getBestMove(parseInt(difficulty.values[difficulty.selectedIndex]));
        var newRow = Model.set(bestMove);
        repeater.itemAt(newRow * 7 + bestMove % 7).setPlayer(Model.turn);
        if (Model.haveWinner(bestMove % 7))
            PopupUtils.open(winDialog, null)
        Model.switchTurn();
    }

    Component.onCompleted: {
        if (!goFirst.checked) {
            machineMove();
        }
    }

    function reset() {
        Model.reset();
        for (var i = 0; i < 42; i++)
            repeater.itemAt(i).color = "white";

        if (!goFirst.checked) {
            machineMove();
        }
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
                                        color = "#DD4814"
                                    else
                                        color = "#2C001E"
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

            title: i18n.tr("Winner!")
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
}
