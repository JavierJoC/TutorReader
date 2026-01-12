#!/usr/bin/env ruby

require 'fileutils'

# --- Output setup ---
save_dir = "./New-historyhiglightWords"
FileUtils.mkdir_p(save_dir)
filename = File.join(save_dir, "highlights_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt")

puts "Listening for highlighted text (X11 polling)... saving to:"
puts filename
puts "(Press Ctrl+C to stop)"

last_text = ""

File.open(filename, "a") do |file|
  loop do
    # --- Get PRIMARY selection (highlighted text, not Ctrl+C clipboard) ---
    text = `xclip -o -selection primary 2>/dev/null`.strip
    if !text.empty? && text != last_text
      last_text = text
text = text.gsub("'", "’")
 text = text.gsub("-\n",'')
text = text.gsub(/\n/,' ')

      file.puts text
      file.flush
      puts "Appended highlight at #{Time.now}\n\t\e[32m #{text}\e[0m"

      #system("echo 'In English, you ryan say: ... ...#{text}'|   ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-ryan-high.onnx  --output-raw |sox -t raw -r 22050 -e signed -b 16 -c 1 - -t raw - trim 0.88|   aplay -r 22050 -f S16_LE -t raw ")

      
      
      #system("echo 'In English, you libritts say: ... ...#{text}'|   ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-libritts-high.onnx --output-raw |sox -t raw -r 22050 -e signed -b 16 -c 1 - -t raw - trim 0.75|   aplay -r 22050 -f S16_LE -t raw ")
# \e[32m :::AI Explanation:\n\t#{explanation.strip}\n\e[0m"     
      system("echo 'In English, you ljspeech say: ... ...#{text}'|   ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-ryan-high.onnx --output-raw |sox -t raw -r 22050 -e signed -b 16 -c 1 - -t raw - trim 2|   aplay -r 22050 -f S16_LE -t raw ")

    end
    sleep 2
  end
end

# -------------------------------------------------------------------------
# 🔽 Tray indicator code (disabled for now, uncomment later when debugging ok)
#
# require 'gtk3'
#
# icon = Gtk::StatusIcon.new
# icon.stock = Gtk::Stock::YES
# icon.tooltip_text = "Highlight watcher running"
#
# Thread.new do
#   File.open(filename, "a") do |file|
#     loop do
#       text = `xclip -o -selection primary 2>/dev/null`.strip
#       if !text.empty? && text != last_text
#         last_text = text
#         file.puts text
#         file.flush
#         puts "Appended highlight at #{Time.now}\n\t#{text}"
#       end
#       sleep 1
#     end
#   end
# end
#
# Gtk.main
# -------------------------------------------------------------------------

