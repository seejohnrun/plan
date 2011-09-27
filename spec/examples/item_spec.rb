require File.dirname(__FILE__) + '/../spec_helper'

describe Plan::Item do

  describe :descend do

    it 'should return self if given nothing to descend with' do
      plan = Plan::Item.new 'hello'
      plan.descend([]).should == plan
    end

    it 'should descend to child if given an exact path match' do
      plan = Plan::Item.new 'hello'
      child_plan = Plan::Item.new 'child'
      plan.children << child_plan
      plan.descend(['child']).should == child_plan
    end

    it 'should descend to child if given an approximate path match' do
      plan = Plan::Item.new 'hello'
      child_plan = Plan::Item.new 'child'
      plan.children << child_plan
      plan.descend(['chi']).should == child_plan
    end

    it 'should prefer an exact match to an approximate match' do
      plan = Plan::Item.new 'hello'
      child_plan = Plan::Item.new 'child'
      chi_plan = Plan::Item.new 'chi'
      plan.children << child_plan
      plan.children << chi_plan
      plan.descend(['chi']).should == chi_plan
    end

    it 'should raise an error when descending an finding multiple matches' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello1')
      plan.children << Plan::Item.new('hello2')
      lambda do
        plan.descend(['hello'])
      end.should raise_error Plan::Advice
    end

    it 'should be able to descend two levels deep' do
      plan = Plan::Item.new 'base'
      plan.children << (one = Plan::Item.new 'one')
      one.children << (two = Plan::Item.new 'two')
      plan.descend(['one', 'two']).should == two
    end

    it 'should raise an error when there is no match' do
      plan = Plan::Item.new 'hello'
      lambda do
        plan.descend(['what'])
      end.should raise_error Plan::Advice
    end

  end

  describe :new do
    
    it 'should trim labels on the way in' do
      plan = Plan::Item.new '  hello  '
      plan.label.should == 'hello'
    end

  end

  describe 'round trip to hash' do

    it 'should work with a label' do
      plan = Plan::Item.new 'hello'
      plan = Plan::Item.load plan.dump
      plan.label.should == 'hello'
    end

    it 'should work with a child' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello')
      plan = Plan::Item.load plan.dump
      plan.children.count.should == 1
    end

    it 'should work with a finished time' do
      plan = Plan::Item.new 'hello', 0
      plan = Plan::Item.load plan.dump
      plan.finished.should be_a Time
    end

    it 'should work with a nil finished time' do
      plan = Plan::Item.new 'hello'
      plan = Plan::Item.load plan.dump
      plan.finished.should be_nil
    end

    it 'should work with hidden true' do
      plan = Plan::Item.new 'hello', 0, true
      plan = Plan::Item.load plan.dump
      plan.should be_hidden
    end

    it 'should work with hidden false' do
      plan = Plan::Item.new 'hello', 0, false
      plan = Plan::Item.load plan.dump
      plan.should_not be_hidden
    end

  end

  describe :finished do

    it 'should turn into a time on instantiation' do
      plan = Plan::Item.new 'hello', 0
      plan.finished.should be_a Time
    end

  end

  describe :load do

    it 'should be able to loda an item from a hash' do
      plan = Plan::Item.load 'label' => 'hello'
      plan.should be_a Plan::Item
    end

  end

  describe :dump do

    it 'should dump an item to a hash' do
      plan = Plan::Item.new 'hello'
      plan.dump.should be_a Hash
    end

  end

  describe :finished? do

    it 'should report things as finished that are' do
      plan = Plan::Item.new 'hello', 0
      plan.should be_finished
    end

    it 'should report default items as not finished' do
      plan = Plan::Item.new 'hello'
      plan.should_not be_finished
    end

    it 'should refuse to accept that an item is finished if its children are not' do
      plan = Plan::Item.new 'hello', 0
      plan.children << Plan::Item.new('hello')
      plan.should_not be_finished
    end

  end

  describe :hidden? do

    it 'should report things as hidden when they are' do
      plan = Plan::Item.new 'hello', nil, true
      plan.should be_hidden
    end

    it 'should report a default item as not hidden' do
      plan = Plan::Item.new 'hello'
      plan.should_not be_hidden
    end

  end

  describe :unfinish! do

    it 'should mark a finished item unfinished' do
      plan = Plan::Item.new 'hello', 0
      plan.unfinish!
      plan.should_not be_finished
    end

    it 'should mark all children unfinished' do
      plan = Plan::Item.new 'hello', 0
      plan.children << Plan::Item.new('hello', 0)
      plan.unfinish!
      plan.children.each { |c| c.should_not be_finished }
    end

  end

  describe :finish! do

    it 'should mark an item finished' do
      plan = Plan::Item.new 'hello'
      plan.finish!
      plan.should be_finished
    end

    it 'should mark all children finished' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello')
      plan.finish!
      plan.children.each { |c| c.should be_finished }
    end

    it 'should mark all children finished NOW' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello')
      plan.finish!
      plan.children.each { |c| c.finished.to_i.should be > 0 }
    end

    it 'should not alter finish dates of children already finished' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello', 0)
      plan.finish!
      plan.children.each { |c| c.finished.to_i.should == 0 }
    end

    it 'should mark all children finished at the same instant' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello')
      plan.children << Plan::Item.new('hello')
      plan.finish!
      times = [plan.finished]
      times.concat plan.children.map(&:finished)
      times.uniq.count.should == 1
    end

  end

  describe :cleanup do

    it 'should hide finished items' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello', 0)
      plan.cleanup
      plan.children.each { |c| c.should be_hidden }
    end

    it 'should not hide unfinished items' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello', nil)
      plan.cleanup
      plan.children.each { |c| c.should_not be_hidden }
    end

    it 'should hide itself if its finished' do
      plan = Plan::Item.new 'hello', 0
      plan.cleanup
      plan.should be_hidden
    end

  end

  describe :visible_child_count do

    it 'should count visible children' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello', nil, false)
      plan.visible_child_count.should == 1
    end

    it 'should not count hidden children' do
      plan = Plan::Item.new 'hello'
      plan.children << Plan::Item.new('hello', nil, true)
      plan.visible_child_count.should == 0
    end

  end

  describe :has_label_like? do

    it 'should respond true when the one in question is a subset of the real label' do
      plan = Plan::Item.new 'hello'
      plan.should have_label_like 'hell'
    end

    it 'should respond true when the one in question is a case-insensitive subset of the real label' do
      plan = Plan::Item.new 'hello'
      plan.should have_label_like 'HELL'
    end

    it 'should return true for an exact match' do
      plan = Plan::Item.new 'hello'
      plan.should have_label_like 'hello'
    end

  end

  describe :has_label? do

    it 'should respond true regardless of case' do
      plan = Plan::Item.new 'hello'
      plan.should have_label 'HELLO'
    end

    it 'should respond false for different labels' do
      plan = Plan::Item.new 'hello'
      plan.should_not have_label 'HELP'
    end

  end

end
