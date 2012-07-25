require "spec_helper"

describe "viewlet helper" do
  let(:view) { SimpleView.new }

  it "does not require a block" do
    output = view.viewlet(:div)
    output.should == "<div></div>\n"
  end

  it "accepts a argument-less block" do
    output = view.viewlet(:div) {}
    output.should == "<div></div>\n"
  end

  it "accepts a block with argument" do
    output = view.viewlet(:div) { |v| }
    output.should == "<div></div>\n"
  end

  describe "variable setting" do
    it "allows to pass variables by hash" do
      output = view.viewlet(:content, :content => "by-hash")
      output.should == "by-hash\n"
    end

    it "allows to pass variables by block" do
      output = view.viewlet(:content) do |v|
        v.content "by-block"
      end

      output.should == "by-block\n"
    end

    it "overrides variables set by hash when set again by block" do
      output = view.viewlet(:content, :content => "by-hash") do |v|
        v.content "by-block"
      end

      output.should == "by-block\n"
    end

    it "allows to set variable as a block" do
      output = view.viewlet(:block_without_argument) do |v|
        v.content { "content-no-arg" }
      end

      output.should == "content-no-arg\n"
    end

    it "allows to set variable as a block that takes arguments" do
      output = view.viewlet(:block_with_argument) do |v|
        v.content { |arg| "content-#{arg}" }
      end

      output.should == "content-argument\n"
    end
  end
end