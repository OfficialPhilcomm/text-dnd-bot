require "pry"
require "discordrb"
require "emoji_regex"
require_relative "config"

module TextDnD
  class Bot
    attr_reader :bot

    def initialize
      build_bot
    end

    def run
      bot.run
    end

    private

    def build_bot
      @bot = Discordrb::Bot.new(token: TextDnD::Config.discord.token)

      bot.message with_text: "Ping", in: "#bot-test" do |event|
        event.message.reply! "Pong"
      end

      bot.register_application_command(:check, "Give me a check!", server_id: "906610348726038529") do |cmd|
        cmd.string "message", "check message", required: true
      end
      bot.application_command(:check) do |event|
        event.respond(content: "Generating #{event.options["message"]}", ephemeral: true)

        event.send_message(content: event.options["message"]) do |_, view|
          view.row do |row|
            row.button label: "Roll the D20!", style: :primary, custom_id: "roll"
          end
        end
      end
      bot.button(custom_id: "roll") do |event|
        roll = rand(1..20)

        roll_message = case roll
        when 1
          "<@#{event.user.id}> rolled a #{roll}! Damn!"
        when 20
          "<@#{event.user.id}> rolled a #{roll}! Excelsior!"
        else
          "<@#{event.user.id}> rolled a #{roll}!"
        end

        message = [
          event.message.content,
          roll_message
        ].join("\n")

        event.update_message(content: message)
      end

      bot.register_application_command(:vote, "Start a vote!", server_id: "906610348726038529") do |cmd|
        cmd.string "message", "Ask a question to receive wisdom", required: true
        cmd.string "option1", "Option 1", required: true
        cmd.string "option2", "Option 2", required: true
        cmd.string "option3", "Option 3"
      end
      bot.application_command(:vote) do |event|
        content = [
          event.options["message"],
          event.options["option1"],
          event.options["option2"],
          event.options["option3"]
        ].compact.join("\n")

        options = [
          event.options["option1"],
          event.options["option2"],
          event.options["option3"]
        ]
          .compact
          .map do |option|
            option.match(EmojiRegex::Regex)
          end
          .compact
          .map(&:to_s)

        event.respond content: "Generating message", ephemeral: true
        message = event.send_message content: content

        options.each do |option|
          message.message.react option
        end
      end
    end
  end
end
