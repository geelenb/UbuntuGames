var state = [[-1, -1, -1, -1, -1, -1, -1, -1],
                [-1, -1, -1, -1, -1, -1, -1, -1],
                [-1, -1, -1, -1, -1, -1, -1, -1],
                [-1, -1, -1, -1, -1, -1, -1, -1],
                [-1, -1, -1, -1, -1, -1, -1, -1],
                [-1, -1, -1, -1, -1, -1, -1, -1],
                [-1, -1, -1, -1, -1, -1, -1, -1],
                [-1, -1, -1, -1, -1, -1, -1, -1]];

var turn = 0;
var score = [2, 2];

function switchTurn () {
    turn = 1 - turn;
}

function set (index) {
    var delta = setOn(index, state);
    score[turn] += delta + 1;
    score[1 - turn] -= delta;
}

function setOn(index, array) {
    var ci = Math.floor(index / 8);
    var cj = index % 8;
    array[ci][cj] = turn;
    var i, j;
    var delta = 0;

    // NW
    for (i = ci - 1, j = cj - 1; i >= 0 && array[i][j] === 1 - turn; i--, j--);
    if (i >= 0 && array[i][j] === turn) {
        for (i++, j++; i < ci; i++, j++) {
            array[i][j] = turn;
            delta++;
        }
    }

    //N
    for (i = ci - 1, j = cj; i >= 0 && array[i][j] === 1 - turn; i--);
    if (i >= 0 && array[i][j] === turn) {
        for (i++; i < ci; i++) {
            array[i][j] = turn;
            delta++;
        }
    }

    // NE
    for (i = ci - 1, j = cj + 1; i >= 0 && array[i][j] === 1 - turn; i--, j++);
    if (i >= 0 && array[i][j] === turn) {
        for (i++, j--; i < ci; i++, j--) {
            array[i][j] = turn;
            delta++;
        }
    }

    // E
    for (i = ci, j = cj + 1; array[i][j] === 1 - turn; j++);
    if (array[i][j] === turn) {
        for (j--; j > cj; j--) {
            array[i][j] = turn;
            delta++;
        }
    }

    // SE
    for (i = ci + 1, j = cj + 1; i < 8 && array[i][j] === 1 - turn; i++, j++);
    if (i < 8 && array[i][j] === turn) {
        for (i--, j--; j > cj; i--, j--) {
            array[i][j] = turn;
            delta++;
        }
    }

    // S
    for (i = ci + 1, j = cj; i < 8 && array[i][j] === 1 - turn; i++);
    if (i < 8 && array[i][j] === turn) {
        for (i--; i > ci; i--) {
            array[i][j] = turn;
            delta++;
        }
    }

    // SW
    for (i = ci + 1, j = cj - 1; i < 8 && array[i][j] === 1 - turn; i++, j--);
    if (i < 8 && array[i][j] === turn) {
        for (i--, j++; i > ci; i--, j++) {
            array[i][j] = turn;
            delta++;
        }
    }

    // W
    for (i = ci, j = cj - 1; array[i][j] === 1 - turn; j--);
    if (array[i][j] === turn) {
        for (j++; j < cj; j++) {
            array[i][j] = turn;
            delta++;
        }
    }

    return delta;
}

function reset () {
    for (var i = 0; i < 8; i++) {
        for (var j = 0; j < 8; j++) {
            state[i][j] = -1;
        }
    }
    turn = 0;
    score[0] = score[1] = 2;
    state[3][3] = state[4][4] = 0;
    state[3][4] = state[4][3] = 1;
}

function movePossible (array, index) {
    var ci = Math.floor(index / 8);
    var cj = index % 8;
    if (array[ci][cj] !== -1)
        return false;

    var i, j;

    // NW
    for (i = ci - 1, j = cj - 1; i >= 0 && array[i][j] === 1 - turn; i--, j--);
    if (i > 0 && i !== ci - 1 && array[i][j] === turn)
        return true;

    //N
    for (i = ci - 1, j = cj; i >= 0 && array[i][j] === 1 - turn; i--);
    if (i > 0 && i !== ci - 1 && array[i][j] === turn)
        return true;

    // NE
    for (i = ci - 1, j = cj + 1; i >= 0 && array[i][j] === 1 - turn; i--, j++);
    if (i > 0 && i !== ci - 1 && array[i][j] === turn)
        return true;

    // E
    for (i = ci, j = cj + 1; array[i][j] === 1 - turn; j++);
    if (j !== cj + 1 && array[i][j] === turn)
        return true;

    // SE
    for (i = ci + 1, j = cj + 1; i < 8 && array[i][j] === 1 - turn; i++, j++);
    if (i < 8 && i !== ci + 1 && array[i][j] === turn)
        return true;

    // S
    for (i = ci + 1, j = cj; i < 8 && array[i][j] === 1 - turn; i++);
    if (i < 8 && i !== ci + 1 && array[i][j] === turn)
        return true;

    // SW
    for (i = ci + 1, j = cj - 1; i < 8 && array[i][j] === 1 - turn; i++, j--);
    if (i < 8 && i !== ci + 1 && array[i][j] === turn)
        return true;

    // W
    for (i = ci, j = cj - 1; array[i][j] === 1 - turn; j--);
    if (j !== cj - 1 && array[i][j] === turn)
        return true;

    return false;
}

function possibleMoveExists() {
    if (score[0] + score[1] === 64)
        return false;

    for (var i = 0; i < 8; i++)
        for (var j = 0; j < 8; j++)
            if (movePossible(state, i * 8 + j))
                return true;

    return false;
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

// This could probably be made faster, by going through all the owned coins and their possible moves
function getPossibleMoves (array) {
    var moves = [];
    for (var i = 0; i < 64; i++)
        if (movePossible(array, i))
            moves.push(i);

    return moves;
}

function arrayCopy(array) {
    var a = new Array(8);
    for (var i = 0; i < 8; i++) {
        a[i] = new Array(8);
        for (var j = 0; j < 8; j++) {
            a[i][j] = array[i][j];
        }
    }
    return a;
}

function getBestMove(depth, array) {
//    console.debug("getBestMove(" + depth + ")");
    var result = [-1, Number.MIN_VALUE]; // [the best move, its score]
    var posMoves = shuffleArray(getPossibleMoves(array));
    if (depth === 0)
        return [posMoves[0], 0]

    for (var i = 0; i < posMoves.length; i++) {
        var copy = arrayCopy(array);
        var delta = setOn(posMoves[i], copy); // how good this move is without its concequences
//        printState(copy);
//        console.debug(delta);
        switchTurn();
        var nextResult = getBestMove(depth - 1, copy);
//        printState(copy)
        switchTurn();

        if (delta - nextResult[1] > result[1])
            result = [posMoves[i], delta - nextResult[1]];
    }

    return result;
}

function printState(array) {
    for (var i = 0; i < 8; i++) {
        var s = array[i].join();
        for (var j = 0; j < 8; j++)
            s = s.replace("-1", " ");
        console.log(s);
    }
}
