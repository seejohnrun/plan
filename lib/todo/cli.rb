require 'json'

module Todo

  class CLI

    class << self

      # TODO colors
      def run(args)
        if args.count > 0
          command args.first, args[1..-1]
        else
          list []
        end
      end

      # decide what to do
      def command(command, paths)
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

      # display a list of help
      def help
        puts 'create - create a new item'
        puts 'list - list items'
        puts 'finish - mark an item finished'
        puts 'unfinish - mark an item unfinished'
        puts 'cleanup - remove finished items from view'
        puts 'help - display this list'
      end

      # Remove all finished items that are descendents
      def cleanup(paths)
        item = path_tree.descend(paths)
        item.cleanup  
        save_path_tree
      end

      # Mark a task or group of tasks as "unfinished"
      def unfinish(paths)
        if paths.empty?
          puts 'please drill down to a level to unfinish'
          exit
        end
        # go to the right depth and unfinish
        item = path_tree.descend(paths)
        item.unfinish!
        save_path_tree
      end

      # Mark a task or group of tasks as "finished"
      def finish(paths)
        if paths.empty?
          puts 'please drill down to a level to unfinish'
          exit
        end
        # descend and finish
        item = path_tree.descend(paths)
        item.finish!
        save_path_tree
      end

      # list things at a certain depth
      def list(paths)
        item = path_tree.descend(paths)
        list_recur_print(item)
      end

      # create a new todo
      def create(paths)
        if paths.empty?
          puts 'please provide something to create'
          exit
        end
        # descend to the right depth
        item = path_tree.descend(paths[0..-2])
        # and then create
        if item.children.any? { |c| c.has_label?(paths[-1]) }
          puts "duplicate entry at level: #{paths[-1]}"
        else
          item.children << Item.new(paths[-1])
          save_path_tree
          list_recur_print item # show the added item in context
        end
      end

      private

      DATA_STORE = 'data'

      def unknown_command(cmd)
        puts "unknown command: #{cmd}"
        puts 'try `todo help`'
        exit
      end

      # Used by #list to print its tree
      def list_recur_print(item, desc = 0)
        item.children.each do |child|
          if child.finished?
            puts "#{'-' * desc}#{desc > 0 ? " #{child.label}" : child.label} (finished @ #{child.finished})"
          else
            puts "#{'-' * desc}#{desc > 0 ? " #{child.label}" : child.label}"
          end
          list_recur_print(child, desc + 2)
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
          Item.new 'root'
        end
      end

    end

  end

end
