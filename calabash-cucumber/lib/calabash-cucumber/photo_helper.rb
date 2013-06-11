require 'calabash-cucumber/tests_helpers'
require 'base64'

include Calabash::Cucumber::Core
include Calabash::Cucumber::TestsHelpers

def base64_encode(str)
    @out = Base64.encode64(str.to_s).gsub(/\n/, '') # encodes then strips new line to match php style
end

def count_photos(album)
    res = http({:method => :post, :path => 'count'},
               {:album => album})
    res = JSON.parse(res)
    if res['outcome'] != 'SUCCESS'
        msg = "Count failed because: #{res['reason']}\n#{res['details']}"
        raise msg
        else
        msg = "#res['count']}\n"
        puts msg
    end
end

def add_album(album)
    res = http({:method => :post, :path => 'photo'},
               {:album => album})
    res = JSON.parse(res)
    if res['outcome'] != 'SUCCESS'
        msg = "Album creation failed because: #{res['reason']}\n#{res['details']}"
        raise msg
    end
end

def add_photo(dir)
    add_photo(dir, nil)
end

def add_photo(dir, album)
    image = base64_encode(File.read(dir))
    
    if album != nil
        res = http({:method => :post, :path => 'photo'},
                   {:phto => image, :album => album})
        else
        res = http({:method => :post, :path => 'photo'},
                   {:phto => image})
    end
    
    res = JSON.parse(res)
    if res['outcome'] != 'SUCCESS'
        msg = "Image failed because: #{res['reason']}\n#{res['details']}"
        raise msg
    end
end