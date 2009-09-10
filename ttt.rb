require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'

class Board
    attr_reader :winner, :full

    def initialize(w, h, cells = nil)
        @w = w
        @h = h
        @cells = cells || Array.new(w*h, '-')
    end

    def to_s
        [ @w, @cells ].to_json
    end

    def self.from_s(s)
        stride, cells = JSON.parse(s)
        result = Board.new(stride, cells.length / stride, cells)
    end

    def cell_type(index)
        type = []
        if index < @w
            type << :top
        elsif index >= @cells.length - @w
            type << :bottom
        else
            type << :vmiddle
        end

        if index % @w == 0
            type << :left
        elsif index % @w == 3
            type << :right
        else
            type << :hmiddle
        end
    end

    def [](index)
        @cells[index]
    end

    def each
        @cells.each_with_index do |cell, index|
            yield cell, cell_type(index), "cell#{index}"
        end
    end

    class Counter
        attr_reader :winner

        def initialize
            @winner     = nil
            @in_a_row   = 3
            @full = false
            reset
        end

        def count(marker)
            return if marker == '-'
            if marker == @current_marker
                @count += 1
            else
                @current_marker = marker
                @count = 1
            end

            if @count == @in_a_row
                @winner = @current_marker
                throw :done
            end
        end

        def reset
            @current_marker = nil
            @count          = 0
        end
    end

    def play(marker, index)
        raise "There is already an #{@cells[index]} at index #{index}" if @cells[index] != '-'

        @cells[index] = marker

        counter = Counter.new
        found_empty = false
        catch (:done) do
            # look for horizontals
            @h.times do |i|
                counter.reset
                @w.times do |j|
                    found_empty = true if @cells[i*@w+j] == '-'
                    counter.count @cells[i*@w+j]
                end
            end

            throw :done unless found_empty

            # look for verticals
            @w.times do |j|
                counter.reset
                @h.times do |i|
                    counter.count @cells[i*@w+j]
                end
            end
            # TODO look for diagonals
        end

        @full   = !found_empty
        @winner = counter.winner
    end
end

module Helpers
    def image_for_cell(cell)
        if ['x','o'].include? cell
            haml "%img{:src => '/#{cell}.png'}"
        end
    end

    def get_board(request)
        cookie = request.cookies['board']
        if cookie
            Board.from_s(cookie)
        else
            Board.new(4,4)
        end
    end
end

helpers(Helpers)

get '/' do
    board = Board.new(4, 4)
    response.set_cookie 'board', board.to_s
    haml :board, :locals => { :board => board }
end

post '/play' do
    board = get_board(request)
    response['Content-Type'] = 'application/json'
    begin
        board.play params[:marker], params[:index].to_i
    rescue => err
        return ['error', err.message].to_json
    end

    response.set_cookie 'board', board.to_s
    if board.full or board.winner
        ['game-over', board.winner].to_json
    else
        ['ok', image_for_cell(params[:marker])].to_json
    end
end
