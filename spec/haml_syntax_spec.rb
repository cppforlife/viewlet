require "spec_helper"
require "haml"
require "viewlet"
require "viewlet/haml"

describe "HAML syntax" do
  let(:view) { SimpleView.new }

  Dir[File.dirname(__FILE__) + "/haml/*.haml"].each do |f|
    it("is able to render #{f}") { check_template(f) }
  end

  def check_template(file_path)
    output = Haml::Engine.new(File.read(file_path)).render(view, {})
    template_piece(output, :first).should == template_piece(File.read(file_path), :last)
  end

  def template_piece(output, piece=:first)
    output.split("__END__").send(piece).strip
  end
end