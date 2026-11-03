require 'spec_helper'

describe 'The stack of helpers a block is nested in' do
  let(:bh) { RailsView.new }
  before { Bh.framework = :rails }

  specify 'is not shared with a view rendering on another thread' do
    inside_nav = Queue.new
    release = Queue.new
    other_thread = Thread.new do
      RailsView.new.nav do
        inside_nav << true
        release.pop
        'content'
      end
    end
    inside_nav.pop

    begin
      expect(bh.link_to 'content', '/').to eq '<a href="/">content</a>'
    ensure
      release << true
      other_thread.join
    end
  end

  specify 'is popped when a helper block raises' do
    expect { bh.nav { raise 'boom' } }.to raise_error 'boom'
    expect(bh.link_to 'content', '/').to eq '<a href="/">content</a>'
  end
end
