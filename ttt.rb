require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'

class Board
    def initialize(w, h, cells = nil)
        @stride = w
        @cells = cells || Array.new(w*h)
    end

    def to_s
        [ @stride, @cells ].to_json
    end

    def self.from_s(s)
        stride, cells = JSON.parse(s)
        result = Board.new(stride, cells.length / stride, cells)
    end

    def cell_type(index)
        type = []
        if index < @stride
            type << :top
        elsif index >= @cells.length - @stride
            type << :bottom
        else
            type << :vmiddle
        end

        if index % @stride == 0
            type << :left
        elsif index % @stride == 3
            type << :right
        else
            type << :hmiddle
        end
    end

    def each
        @cells.each_with_index do |cell, index|
            yield cell, cell_type(index), "cell#{index}"
        end
    end

    def play(action)
    end
end

module Helpers
    def image_for_cell(cell)
        if ['x','o'].include? cell
            haml "%img{src => '/#{cell}.png'}"
        end
    end
end

helpers(Helpers)

get '/' do
    haml 'test'
end

get '/play/?:action' do |action|
    cookie = request.cookies['board']
    board =
        if cookie
            Board.from_s(cookie)
        else
            Board.new(4,4)
        end
    board.play action
    set_cookie 'board', board.to_s
    haml :board, :locals => { :board => board }
end
