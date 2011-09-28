require 'rubygems'
require 'json'

module Plan

  class CLI

    class << self

      def run(args)
        begin
          command args.first, args[1..-1]
        rescue Plan::Advice => e
          e.lines.each do |line|
            puts "\e[31m[uh-oh]\e[0m #{line}"
          end
        end
      end

      # decide what to do
      def command(command, paths)
        # default is list
        return list([]) if command.nil?
        # choose other command
        case command
        when 'create' then create paths
        when 'list' then list paths
        when 'finish' then finish paths
        when 'unfinish' then unfinish paths
        when 'cleanup' then cleanup paths
        when 'help' then help
        else unknown_command(command)
        end
      end

      COMMAND_GLOSSARY = {
        'create' => 'create a new item',
        'list' => 'list items',
        'finish' => 'mark an item finished',
        'unfinish' => 'mark an item unfinished',
        'cleanup' => 'remove finished items from view',
        'help' => 'display a list of commands'
      }

      # display a list of help
      def help
        puts "plan #{Plan::VERSION} - john crepezzi - http://github.com/seejohnrun/plan"
        COMMAND_GLOSSARY.each do |cmd, description|
          puts "\e[0;33m#{cmd}\e[0m - #{description}"
        end
      end

      # Remove all finished items that are descendents
      def cleanup(paths)
        item = path_tree.descend(paths)
        item.cleanup  
        save_path_tree
        # print what happened here
        print_depth item
      end

      # Mark a task or group of tasks as "unfinished"
      def unfinish(paths)
        if paths.empty?
          raise Plan::Advice.new('please drill down to a level to unfinish')
        end
        # go to the right depth and unfinish
        item = path_tree.descend(paths)
        item.unfinish!
        save_path_tree
        # print what happened here
        print_depth item
      end

      # Mark a task or group of tasks as "finished"
      def finish(paths)
        if paths.empty?
          raise Plan::Advice.new('please drill down to a level to finish')
        end
        # descend and finish
        item = path_tree.descend(paths)
        item.finish!
        save_path_tree
        # print what happened here
        print_depth item
      end

      # list things at a certain depth
      def list(paths)
        item = path_tree.descend(paths)
        if item.visible_child_count == 0
          raise Plan::Advice.new('no events here - create some with `plan create`')
        end
        print_depth item
      end

      # create a new todo
      def create(paths)
        if paths.empty?
          raise Plan::Advice.new('please provide something to create')
        end
        # descend to the right depth
        item = path_tree.descend(paths[0..-2])
        # and then create
        if item.children.any? { |c| !c.hidden? && c.has_label?(paths[-1]) }
          raise Plan::Advice.new("duplicate entry at level: #{paths[-1]}")
        else
          item.children << Item.new(paths[-1])
          save_path_tree
          # and say what happened
          print_depth item
        end
      end

      private

      DATA_STORE = ENV['PLAN_DATA_PATH'] || "#{ENV['HOME']}/plan"
      DATE_FORMAT = '%b. %e, %Y %l:%M %P'

      def unknown_command(cmd)
        raise Plan::Advice.new("unknown command: #{cmd}. try `plan help` for options.")
      end

      # print the item and its descendents
      def print_depth(item)
        return if item.hidden?
        print_item item, 0
        list_recur_print item, 2
      end

      # Used by #print_depth to print its tree
      def list_recur_print(item, desc = 0)
        item.children.each do |child|
          next if child.hidden?
          print_item child, desc
          list_recur_print(child, desc + 2)
        end
      end

      # output an individual item
      def print_item(item, desc = 0)
        if item.finished?
          puts "\e[1;30m#{'-' * desc}#{desc > 0 ? " #{item.label}" : item.label} \e[1;31m(finished @ #{item.finished.strftime(DATE_FORMAT)})\e[0m"
        else
          puts "\e[1;30m#{'-' * desc}\e[0m#{desc > 0 ? " #{item.label}" : item.label}"
        end
      end

      # Save any changes to the tree
      def save_path_tree
        file = File.open(DATA_STORE, 'w')
        file.write path_tree.dump.to_json
        file.close
      end

      # Get the path tree from the data file
      def path_tree
        @path_tree ||= if File.exists?(DATA_STORE)
          Item.load JSON.parse(File.read(DATA_STORE))
        else
          Item.new 'plan'
        end
      end

    end

  end

end
