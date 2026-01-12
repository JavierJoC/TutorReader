#!/usr/bin/env ruby

require 'fileutils'
require 'ruby/openai'

save_dir = "."
FileUtils.mkdir_p(save_dir)
filename = File.join(save_dir, "highlights_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt")

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

puts "Listening for highlighted text (X11 polling)... saving to:"
puts filename
puts "(Press Ctrl+C to stop)"

last_text = ""
last_audio = "last_explanation.wav"

File.open(filename, "a") do |file|
  loop do
    text = `xclip -o -selection primary 2>/dev/null`.strip
    if !text.empty? && text != last_text
      last_text = text
      file.puts text
      file.flush
      puts "\n\nAppended highlight at #{Time.now}\n\t\e[33m#{text}\e[0m"

      # AI explanation
      prompt = "Explain this text in very simple English for learners:\n\n#{text}"
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [{ role: "user", content: prompt }],
          temperature: 0.4
        }
      )

      explanation = response.dig("choices", 0, "message", "content")
      puts "\n\n\e[32mAI Explanation:\n\t#{explanation.strip}\n\e[0m"

# Save audio to file with correct format
system("echo '#{explanation.strip}' | ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/piper \
  --model ~/Mylinux_tools/ClipBoardUtilities/CopyWords/piper/en_US-ryan-high.onnx \
  --output-raw | aplay -r 22050 -f S16_LE -t raw - > last_explanation.raw")

# Convert raw to wav so 'aplay' knows the format
system("sox -r 22050 -e signed -b 16 -c 1 last_explanation.raw last_explanation.wav")
system("aplay last_explanation.wav")

      # Replay loop (press Enter)
      Thread.new do
        loop do
          puts "Press ENTER to replay last explanation, or type 'q' to stop replay mode:"
          input = $stdin.gets.chomp
          break if input.downcase == "q"
system("aplay last_explanation.wav")
        end
      end
    end
    sleep 2
  end
end

