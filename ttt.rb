require 'rubygems'
require 'sinatra'
require 'haml'

class Board
    def initialize(w, h)
        @stride = w
        @cells = Array.new(w*h)
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
end

get '/' do
    haml 'test'
end

get '/play' do
    haml :board, :locals => { :board => Board.new(4,4) }
end

get '/play/(.*)' do |layout|
    haml :board
end
