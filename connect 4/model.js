var state = [[-1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1]]

var turn = 0;

function switchTurn () {
    turn = 1 - turn;
}

function getColumn (index) {
    return index % 7;
}

function getRow (index) {
    return index / 7;
}

function set (index) {
    var column = index % 7;
    for (var i = 0; i < 5; i++) {
        if (state[i + 1][column] !== -1) {
            state[i][column] = turn;
            return i;
        }
    }

    state[5][column] = turn;
    return 5;
}

function unset (index) {
    var column = index % 7;
    for (var i = 0; i < 6; i++) {
        if (state[i][column] !== -1) {
            state[i][column] = -1;
            return;
        }
    }
}

function reset () {
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 7; j++) {
            state[i][j] = -1;
        }
    }
    turn = 0;
}

function possible (index) {
    return state[0][index % 7] === -1;
}

function shuffleArray(array) {
    for (var i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}

function haveWinner (lastColumn) {
    var posWinner = -1;
    var lastRow = -1;
    for (var i = 0; i < 6; i++) {
        if (state[i][lastColumn] !== -1) {
            posWinner = state[i][lastColumn];
            lastRow = i;
            break;
        }
    }

    // check vertical
    var count = 0;
    for (var i = lastRow; i < 6; i++) {
        if (state[i][lastColumn] === posWinner) {
            count++;
            if (count === 4) {
                return true;
            }
        } else {
            count = 0;
        }
    }

    //check horizontal
    count = 0;
    for (i = 0; i < 7; i++) {
        if (state[lastRow][i] === posWinner) {
            count++;
            if (count === 4) {
                return true;
            }
        } else {
            count = 0;
        }
    }

    // check diagonal
    // SE
    var j = lastColumn - lastRow;
    count = 0;
    for (i = 0; i < 6 && j < 7; i++, j++) {
        if (state[i][j] === posWinner) {
            count++;
            if (count === 4) {
                return true;
            }
        } else {
            count = 0;
        }
    }

    // SW
    j = lastColumn + lastRow;
    count = 0;
    for (i = 0; i < 6 && j >= 0; i++, j--) {
        if (state[i][j] === posWinner) {
            count++;
            if (count === 4){
                return true;
            }
       } else {
            count = 0;
        }
    }
}

function getPossibleMoves () {
    var moves = [];
    for (var i = 0; i < 9; i++) {
        if (state[0][i] === -1) {
            moves.push(i);
        }
    }
    return moves;
}

function getBestMove(depth) {
    console.debug("getBestMove(" + depth + ")")
    var bestMove = -1;
    var posMoves = shuffleArray(getPossibleMoves());

    //first, check for a winning move
    for (var i = 0; i < posMoves.length; i++){
        set (posMoves[i]);
        switchTurn();

        if (haveWinner(posMoves[i])) {
            switchTurn();
            unset(posMoves[i]);
            return posMoves[i];
        }

        switchTurn();
        unset(posMoves[i]);
    }

    // then search for move that doesnt have a losing child
    for (i = 0; i < posMoves.length; i++){
        set (posMoves[i]);
        switchTurn();

        if (getBestMoveRec(depth - 1) === -1) {
            switchTurn();
            unset(posMoves[i]);
            return posMoves[i];
        }

        switchTurn();
        unset(posMoves[i]);
    }

    // then return random
    return posMoves[0];
}


function getBestMoveRec(depth) {
    var bestMove = -1;
    var posMoves = shuffleArray(getPossibleMoves());

    //first, check for a winning move
    for (var i = 0; i < posMoves.length; i++){
        set (posMoves[i]);
        switchTurn();

        if (haveWinner(posMoves[i])) {
            switchTurn();
            unset(posMoves[i]);
            return posMoves[i];
        }

        switchTurn();
        unset(posMoves[i]);
    }

    if (depth === 0)
        return -1;

    // then search for move that doesnt have a losing child
    for (i = 0; i < posMoves.length; i++){
        set (posMoves[i]);
        switchTurn();

        if (getBestMoveRec(depth - 1) === -1) {
            switchTurn();
            unset(posMoves[i]);
            return posMoves[i];
        }

        switchTurn();
        unset(posMoves[i]);
    }

    // then return there is no possible positive ending.
    return -1;
}

function printState() {
    for (var i = 0; i < 6; i++) {
        var s = state[i].join();
        for (var j = 0; j < 7; j++)
            s = s.replace("-1", " ");
        console.log(s);
    }
}
