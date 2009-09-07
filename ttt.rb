require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'

class Board
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

    def play(marker, index)
        raise "There is already an #{@cells[index]} at index #{index}" if @cells[index] != '-'

        @cells[index] = marker
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
    board.play params[:marker], params[:index].to_i
    response.set_cookie 'board', board.to_s
    image_for_cell(params[:marker])
end
