import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
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
        if (Model.turn === 0) {// TODO 2player mode
            if (Model.possible(index)) {
                var newRow = Model.set(index);
                repeater.itemAt(newRow * 7 + index % 7).setPlayer(Model.turn);
                if (Model.haveWinner(index % 7)) {
                    PopupUtils.open(winDialog, null)
                } else {
                    Model.switchTurn();

                    var bestMove = Model.getBestMove(7);
                    newRow = Model.set(bestMove);
                    repeater.itemAt(newRow * 7 + bestMove % 7).setPlayer(Model.turn);
                    if (Model.haveWinner(bestMove % 7)) {
                        setTimeout(PopupUtils.open(winDialog, null), 100)

                    }

                    Model.switchTurn();
                }
            }
        }
    }

    function reset() {
        Model.reset();
        for (var i = 0; i < 42; i++)
            repeater.itemAt(i).color = "white";
    }
    
    Tabs {
        id: tabs
        Tab {
            title: "Connect 4"

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
                    ToolbarButton {
                        text: "New Game"
                        action: Action {
                            iconSource: Qt.resolvedUrl("new.png")
                            onTriggered: main.reset()
                            visible: true
                        }
                    }
                }
            }
        }

        Tab {
            title: "Settings"
        }
    }

    Component {
        id: winDialog

        Dialog {
            id: dialogue

            title: "Winner!"
            text: (Model.turn ? "Orange" : "Purple") + " won the game."

            Button {
                text: "Back"
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(dialogue);
                }
            }

            Button {
                text: "New Game"
                onClicked: {
                    reset();
                    PopupUtils.close(dialogue);
                }
            }
        }
    }
}
