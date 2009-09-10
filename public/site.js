var currentTurn = 'x'

function whosNext() {
    if (currentTurn == 'x')
        return 'o'
    else
        return 'x'
}

function setupTurn(marker) {
    currentTurn = marker
    $('#message').html('<img src="/place' + marker + '.png"/>')
}

function getCellUpdater(cell, marker) {
    return function updateCellContents(data) {
        if (data[0] == 'ok') {
            $(cell).html('<img src="/' + marker + '.png"/>')
            setupTurn(whosNext())
            enablePlay()
        } else if (data[0] == 'game-over') {
            $(cell).html('<img src="/' + marker + '.png"/>')
            if (data[1]) {
                $('#message').html(data[1] + " has won!")
            } else {
                $('#message').html('<h1>CAT</h1>')
            }
            $('#message').append('<br/><a href="/">New Game</a>')
        } else if (data[0] == 'error') {
            $('#message').html("error: " + data[1])
            enablePlay()
        }
    }
}

function clickCell(cell) {
    disablePlay()
    jQuery.post('/play',
                {marker: currentTurn, index: cell.id.replace('cell', '')},
                getCellUpdater(cell, currentTurn),
                'json')
}

function enablePlay() {
    $('.cell').live('click', function() {
        clickCell(this)
    })
    $('.cell').live('mouseover', function() {
        $(this).css('background-color', '#BBBBBB')
    })
    $('.cell').live('mouseout', function() {
        $(this).css('background-color', 'white')
    })
}

function disablePlay() {
    $('.cell').die('click')
    $('.cell').die('mouseover')
    $('.cell').die('mouseout')
}

$(document).ready(function() {
    enablePlay()
    setupTurn('x')
})
