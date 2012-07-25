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

  it "raises error when variable used in the template is not provided" do
    expect {
      view.viewlet(:content)
    }.to raise_error(ActionView::Template::Error, /undefined local variable or method `text'/)
  end

  describe "variable setting" do
    it "allows to pass variables by hash" do
      output = view.viewlet(:content, :text => "by-hash")
      output.should == "by-hash\n"
    end

    it "allows to pass variables by block" do
      output = view.viewlet(:content) do |v|
        v.text "by-block"
      end

      output.should == "by-block\n"
    end

    it "overrides variables set by hash when set again by block" do
      output = view.viewlet(:content, :text => "by-hash") do |v|
        v.text "by-block"
      end

      output.should == "by-block\n"
    end

    it "allows to set variable as a block" do
      output = view.viewlet(:block_without_argument) do |v|
        v.text { "no-arg" }
      end

      output.should == "no-arg\n"
    end

    it "allows to set variable as a block that takes arguments" do
      output = view.viewlet(:block_with_argument) do |v|
        v.text { |arg| arg }
      end

      output.should == "method-argument\ncapture-argument\ncall-argument\n"
    end
  end
end