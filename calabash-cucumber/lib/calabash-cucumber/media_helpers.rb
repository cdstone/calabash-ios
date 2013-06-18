require 'calabash-cucumber/tests_helpers'
require 'base64'

module Calabash
    module Cucumber
        module MediaHelpers
            include Calabash::Cucumber::Core
            include Calabash::Cucumber::TestsHelpers
            
            def base64_encode(str)
                @out = Base64.encode64(str.to_s).gsub(/\n/, '') # encodes then strips new line to match php style
            end
            
            # counts the media items in the specified album according to the filter
            # "Saved Photos" defaults to all media items on the device
            # filter type can be :video or :photo
            # other filter types will return as if there were no filter
            def count_media(album="Saved Photos", filter=:default)
                res = http({:method => :post, :path => 'count'},
                           {:album => album, :filter => filter.to_s})
                res = JSON.parse(res)
                if res['outcome'] != 'SUCCESS'
                    msg = "Count failed because: #{res['reason']}\n#{res['details']}"
                    raise msg
                    else
                    msg = "#res['count']}\n"
                end
                res['count']
            end
            
            # returns true/false if the specified album exists on the device
            def album_exists?(album)
                res = http({:method => :post, :path => 'count'},
                           {:album => album})
                res = JSON.parse(res)
                res['results'] == "album exists"
            end
            
            # adds the album to the device
            def add_album(album)
                res = http({:method => :post, :path => 'photo'},
                           {:album => album})
                res = JSON.parse(res)
                if res['outcome'] != 'SUCCESS'
                    msg = "Album creation failed because: #{res['reason']}\n#{res['details']}"
                    raise msg
                end
                res['results']
            end
            
            # adds the video from the specified path to the device
            def add_video(path)
                video = base64_encode(File.read(dir))
                res = http({:method => :post, :path => 'photo'},
                           {:media => video, :type => 'video'})
                res = JSON.parse(res)
                if res['outcome'] != 'SUCCESS'
                    msg = "Video failed because: #{res['reason']}\n#{res['details']}"
                    raise msg
                end
                res['results']
            end
            
            # adds the specified photo to the device under the specified album
            # "Saved Photos defaults to no album
            def add_photo(path, album="Saved Photos")
                image = base64_encode(File.read(dir))
                
                res = http({:method => :post, :path => 'photo'},
                            {:media => image, :album => album})
                
                res = JSON.parse(res)
                if res['outcome'] != 'SUCCESS'
                    msg = "Image failed because: #{res['reason']}\n#{res['details']}"
                    raise msg
                end
                res['results']
            end
            
        end
    end
end