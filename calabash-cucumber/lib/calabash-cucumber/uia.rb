require 'edn'
require 'location-one'

module Calabash
    module Cucumber
        module UIA
            
            def send_uia_command(opts ={})
                run_loop = opts[:run_loop] || (@calabash_launcher && @calabash_launcher.active? && @calabash_launcher.run_loop)
                command = opts[:command]
                raise ArgumentError, 'please supply :run_loop or instance var @calabash_launcher' unless run_loop
                raise ArgumentError, 'please supply :command' unless command
                RunLoop.send_command(run_loop, opts[:command])
            end
            
            def uia_query(*queryparts)
                #TODO escape '\n etc in query
                uia_handle_command(:query, queryparts)
            end
            
            def uia_names(*queryparts)
                #TODO escape '\n etc in query
                uia_handle_command(:names, queryparts)
            end
            
            def uia_tap(*queryparts)
                uia_handle_command(:tap, queryparts)
            end
            
            def uia_tap_mark(mark)
                uia_handle_command(:tapMark, mark)
            end
            
            def uia_pan(from_q, to_q)
                uia_handle_command(:pan, from_q, to_q)
            end
            
            def uia_scroll_to(*queryparts)
                uia_handle_command(:scrollTo, queryparts)
            end
            
            def uia_element_exists?(*queryparts)
                uia_handle_command(:elementExists, queryparts)
            end
            
            def uia_element_does_not_exist?(*queryparts)
                uia_handle_command(:elementDoesNotExist, queryparts)
            end
            
            def uia_screenshot(name)
                uia_handle_command(:elementDoesNotExist, name)
            end
            
            def uia_type_string(string)
                uia_handle_command(:typeString, string)
            end
            
            def uia_enter()
                uia_handle_command(:enter)
            end
                        
            # code for selecting photos from an album
            # @album (string) = the album name (input "Saved Photos" for the default album)
            # @index (int) = the index of the photo in the album starting at 0
            # @popover (boolean) = whether the album display will appear as a popover (only available on iPads)
            def select_photo(album="Saved Photos", index=0, popover=false)
                count = count_media(album)
                if count == 0
                    raise "No images in album"
                end
                # append to album name to match iOS name scheme
                albumName = "\"" + album + ",   (#{count})\""
                # alter command if using an iPad popover
                ipad_name = ""
                ipad_name = "popover()." if ENV['DEVICE'] == "ipad" && popover
                
                # select the correct album
                albumName = 0 if album=="Saved Photos" # In case the device is in another language
                send_uia_command({:command => "UIATarget.localTarget().frontMostApp().mainWindow().#{ipad_name}tableViews()[0].cells()[#{albumName}].tap()"})
                # select the correct photograph using its index and the max number of images in each row
                maxRow = send_uia_command({:command => "window = UIATarget.localTarget().frontMostApp().mainWindow().#{ipad_name}tableViews()[0];\nwindow.cells()[0].elements().length"})['value']
                x = index % maxRow
                y = (index/maxRow).floor
                # make sure element is visible for selection
                if count.to_i > maxRow
                    send_uia_command({:command => "window.cells()[#{y}].scrollToVisible()"})
                end
                # select
                res = send_uia_command({:command => "window.cells()[#{y}].images()[#{x}].tap()"})
                # check for errors
                if res['status'] != "success"
                    raise "error: photo not selected - #{res['value']}"
                else
                    res['status']
                end
            end

            
            def uia_set_location(place)
                if place.is_a?(String)
                    loc = LocationOne::Client.location_by_place(place)
                    loc_data = {"latitude"=>loc.latitude, "longitude"=>loc.longitude}
                    else
                    loc_data = place
                end
                uia_handle_command(:setLocation, loc_data)
            end
            
            def uia_handle_command(cmd, *query_args)
                args = query_args.map do |part|
                    if part.is_a?(String)
                        "'#{escape_uia_string(part)}'"
                        else
                        "'#{escape_uia_string(part.to_edn)}'"
                    end
                end
                command = %Q[uia.#{cmd}(#{args.join(', ')})]
                if ENV['DEBUG'] == '1'
                    puts "Sending UIA command"
                    puts command
                end
                s=send_uia_command :command => command
                if ENV['DEBUG'] == '1'
                    puts "Result"
                    p s
                end
                if s['status'] == 'success'
                    s['value']
                    else
                    raise s
                end
            end
            
            def escape_uia_string(string)
                #TODO escape '\n in query
                string
            end
            
        end
    end
end