class TestJob < Struct.new(:content)
  def perform
    Gift.create(name: 'Test worker')
  end
end