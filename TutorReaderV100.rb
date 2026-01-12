#!/usr/bin/env ruby

require 'fileutils'
require 'ruby/openai'

# Gemfile
gem 'colorize'
# Code
require 'colorize'



#This is the code for puts text in the terminal
def wrap_text(text, width = 70)
  text.scan(/\S.{0,#{width-2}}\S(?=\s|$)|\S+/).join("\n")
end
def wrap_text_indent(text, width = 70, indent = 4)
  prefix = ' ' * indent
  wrap_text(text, width).lines.map { |line| prefix + line }.join
end

#############################################################################
#########   CONFIGURATION ENDS  ############################################
#############################################################################

save_dir = "."
FileUtils.mkdir_p(save_dir)
filename = File.join(save_dir, "./New-historyhiglightWords/highlights_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt")



#actuallykey="OPENAI_API_KEY_IIIII"
#actuallykey="OPENAI_API_KEY"
#client = OpenAI::Client.new(access_token: ENV[actuallykey])
#      system( "echo $#{actuallykey} ")

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])



puts wrap_text_indent("Listening for highlighted text (X11 polling)... saving to:", 70, 2).gray
puts wrap_text_indent(filename, 100,2).gray
puts wrap_text_indent("Press Ctrl+C to stop", 70, 2).white.bold
puts "\n\n\n"

last_text = ""

File.open(filename, "a") do |file|
  loop do
    text = `xclip -o -selection primary 2>/dev/null`.strip
    if !text.empty? && text != last_text
      last_text = text
      text = text.gsub("'", "’")
      text = text.gsub("-\n",'')
      text = text.gsub(/\n/,' ')

      file.puts text
      file.flush
      puts wrap_text_indent("Input at #{Time.now}\n" , 80, 2).gray
      puts "\n\n\n"
      puts wrap_text_indent("\"#{text}\"", 80, 4 ).center(80).yellow.bold
      #puts "\"#{text}\"".center(100).yellow.bold
      puts "\n\n"
      
      # the new speak  input phrase
      system( "echo '#{text}' > input_prompt.txt")
      system( "echo '#{text}' >> speach_history")
      system('bash -c " cat input_prompt.txt \
              | ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper \
                  --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-lessac-high.onnx \
                  --output-raw  2>/dev/null \
              | tee >(aplay -r 22050 -f S16_LE -t raw  >/dev/null 2>&1)  \
              | sox -r 22050 -e signed -b 16 -c 1 -t raw - input_prompt.wav >/dev/null 2>&1"')

      # AI explanation
      #prompt = "Explain the meaning of this text (a phrase, a sentence, or a word) as if you were talking to a friend learning English. Use clear, simple, everyday language and make it flow naturally. Focus on the core meaning, without deep analysis. Write it as one continuous piece of text, not with isolated short sentences, so it works well with text-to-speech. Also explain the link between the literal meaning and the deeper message. If this is the same text you already explained before, give a new explanation:\n\n<#{text}>"
      #prompt = "Explain the ideas or meanings, from this text(that contain a phrase, a sentence or maybe a simple word) as if you were speaking to a friend who is learning English. Use very simple, everyday language and a natural, conversational flow. The focus is on conveying the core meaning in a way that is easy to grasp intuitively, without complex analysis. Write it as a single, fluid piece of text  as Dr. Krashen suggests, please don't use sentences whit just two or one words (like: hey, so) isolated ideas because my tex to spech app doesn't works good,  and analyze the relationship between its literal meaning and its underlying message, and if you get the same text that ytou process before, create a new explanation:\n\n<#{text}>"
      prompt = "Explain the ideas or meanings, from this text(that contain a phrase, a sentence or maybe a simple word) as if you were speaking to a friend who is learning English. Use very simple, everyday language and a natural, conversational flow. The focus is on conveying the core meaning in a way that is easy to grasp intuitively, without complex analysis. Write it as a single, fluid piece of text  as Dr. Krashen suggests, please don't use sentences whit just two or one words (like: hey, so) isolated ideas because my tex to spech app doesn't works good,  and analyze the relationship between its literal meaning and its underlying message, and if you get the same text that ytou process before, create a new explanation about the phase between follows angle brakets:\n\n<#{text}>"
      response = client.chat(
        parameters: {
          model: "gpt-4o",
          #model: "gpt-4o-mini",
          messages: [{ role: "user", content: prompt }],
          temperature: 0.4
        }
      )

      explanation = response.dig("choices", 0, "message", "content")

      puts wrap_text_indent(explanation.strip,  80, 4).cyan

      #  Piper speak out the Explanation
      speach = explanation.strip.gsub("'", "’")
      system( "echo '#{speach}' > speach.txt")
      system('bash -c " cat speach.txt \
              | ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper \
                --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-ryan-high.onnx \
                --output-raw  2>/dev/null \
              | tee >(aplay -r 22050 -f S16_LE -t raw  >/dev/null 2>&1)  \
              | sox -r 22050 -e signed -b 16 -c 1 -t raw - speach.wav >/dev/null 2>&1"')
      
      puts "\n\n"
      puts wrap_text_indent(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::", 80,4).center(80).gray
      puts "\n\n\n"
 
      system( "echo '#{speach}' >> speach_history")
    end
    sleep 3
#print "\a"
print "\7"
  end
end

