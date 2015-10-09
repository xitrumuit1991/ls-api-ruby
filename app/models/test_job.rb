class TestJob
  def demo
    Gift.create(name: 'Testtttt worker')
  end

  handle_asynchronously :demo, :run_at => Proc.new { 3.seconds.from_now }
end