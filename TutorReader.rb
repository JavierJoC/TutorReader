#!/usr/bin/env ruby

require 'fileutils'
require 'ruby/openai'


save_dir = "./New-historyhiglightWords"
FileUtils.mkdir_p(save_dir)
filename = File.join(save_dir, "highlights_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt")

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

puts "\033[0;90mListening for highlighted text (X11 polling)... saving to:"
puts filename
puts "\e[0m(Press Ctrl+C to stop)"

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
      puts "\n\n\033[0;90mAppended highlight at #{Time.now}\n\t\033[0;33m#{text}\e[0m"

      # speak out the input phrase
#      system("echo '#{text}' | ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper \
#              --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-lessac-high.onnx\
#              --output-raw | aplay -r 22050 -f S16_LE -t raw ")
#      

      # the new speak  input phrase
      system( "echo '#{text}' > input_prompt.txt")
      system('bash -c " cat input_prompt.txt \
              | ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper \
                  --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-lessac-high.onnx \
                  --output-raw  2>/dev/null \
              | tee >(aplay -r 22050 -f S16_LE -t raw  >/dev/null 2>&1)  \
              | sox -r 22050 -e signed -b 16 -c 1 -t raw - input_prompt.wav >/dev/null 2>&1"')
#      


      # AI explanation
      #prompt = "Generate a Title about it and explain this text idea by idea to achive the understanding in very simple English for learners in a fluid text to speach, don't use extra labels like 'title' or extra punct char:\n\n#{text}"
      prompt = "Explain the ideas from this text as if you were speaking to a friend who is learning English. Use very simple, everyday language and a natural, conversational flow. The focus is on conveying the core meaning in a way that is easy to grasp intuitively, without complex analysis. Write it as a single, fluid piece of text  as Dr. Krashen suggests, and don't use sentences whit just two or one words, and try correct this phrase, and analyze the relationship between its literal meaning and its underlying message:\n\n<#{text}>"
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [{ role: "user", content: prompt }],
          temperature: 0.4
        }
      )

      explanation = response.dig("choices", 0, "message", "content")
      #puts "\n\n\e[32mAI Explanation:\n\t#{explanation.strip}\n\e[0m"
      finaltext = "\n\n\e[22m :::AI Explanation:\e[0m\n\t\e[32m :#{explanation.strip}\n\e[0m"
      puts finaltext.ljust(40, '*')  # "Ruby******"


     
      #  Piper speak out the Explanation
      speach = explanation.strip.gsub("'", "’")


      puts "\033[0;90m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\e[0m"



      system( "echo '#{speach}' > speach.txt")
      system('bash -c " cat speach.txt \
              | ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper \
                --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-ryan-high.onnx \
                --output-raw  2>/dev/null \
              | tee >(aplay -r 22050 -f S16_LE -t raw  >/dev/null 2>&1)  \
              | sox -r 22050 -e signed -b 16 -c 1 -t raw - speach.wav >/dev/null 2>&1"')
#      
#    system('bash -c "cat speach.txt \
#  | ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper \
#      --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-ryan-high.onnx \
#      --output-raw \
#  | sox -r 22050 -e signed -b 16 -c 1 -t raw - speach.wav  -d"')
## 
    end
    sleep 3
print "\a"
  end
end

