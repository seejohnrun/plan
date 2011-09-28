module Plan

  class Item

    attr_reader :label, :finished, :children
      
    # Create a new item
    def initialize(label, finished = nil, hidden = nil)
      @label = label.strip
      @finished = finished.is_a?(Fixnum) ? Time.at(finished) : nil
      @hidden = hidden
      @children = []
    end

    # determine whether a label is a duplicate of this item's label
    # downcases to get rid of basic mistakes
    def has_label?(other_label)
      label.downcase == other_label.downcase
    end

    # for fuzzy matching on descending - so you can do things like
    # todo create so hi - instead of
    # todo create something hi
    def has_label_like?(other_label)
      label.downcase.include? other_label.downcase
    end

    # count of the visible children
    def visible_child_count
      children.select { |c| !c.hidden? }.size
    end

    # remove all finished items from this tree, by hiding them
    def cleanup
      @hidden = true if finished?
      children.each { |c| c.cleanup }
    end

    # mark a finish date for this item
    def finish!(at = Time.now)
      @finished = at unless finished? # don't overwrite
      children.each { |c| c.finish!(at) unless c.hidden? } # and finish each child
    end

    # mark a finished item as unfinished
    # and all descendents
    def unfinish!
      @finished = nil
      children.each { |c| c.unfinish! unless c.hidden? }
    end

    # return a boolean indicating whether or not this item is hidden
    def hidden?
      !!@hidden
    end

    # return whether this item is finished
    def finished?
      !!@finished && children.all? { |c| c.finished? || c.hidden? }
    end

    # recursively descent through children until you find the given item
    def descend(paths)
      return self if paths.empty?
      # prefer exact matches
      next_items = children.select { |c| !c.hidden? && c.has_label?(paths.first) }
      # fall back on approximates
      if next_items.empty?
        next_items = children.select { |c| !c.hidden? && c.has_label_like?(paths.first) }
      end
      # give an error if we have no matches
      if next_items.empty?
        lines = []
        lines << "no match for #{paths.first}"
        unless children.empty?
          avail = children.map { |c| c.label unless c.hidden? }.compact
          lines << "available options are: #{avail.join(', ')}"
        end
        raise Plan::Advice.new(*lines)
      end
      # give an error if we have too many matches
      if next_items.size > 1
        lines = []
        lines << "ambiguous match for '#{paths.first}' - please choose one of:"
        next_items.each do |np|
          lines << "* #{np.label}"
        end
        raise Plan::Advice.new(*lines)
      end 
      # and off we go, continuing to descent
      next_items.first.descend(paths[1..-1])
    end

    # Load a Item from a data hash
    def self.load(data)
      item = Item.new data['label'], data['finished'], data['hidden']
      data['children'] && data['children'].each do |child|
        item.children << Item.load(child) 
      end
      item
    end

    # dump a nested representation of this item
    def dump
      data = {}
      data['label'] = label
      data['finished'] = finished.nil? ? nil : finished.to_i
      data['children'] = children.map { |c| c.dump }
      data['hidden'] = true if hidden?
      data
    end

  end

end
