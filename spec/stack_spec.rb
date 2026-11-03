require 'spec_helper'
require 'timeout'

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

    begin
      Timeout.timeout(5) { inside_nav.pop }
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

  specify 'keeps the enclosing helpers when a nested block raises' do
    html = bh.navbar do
      expect { bh.nav { raise 'boom' } }.to raise_error 'boom'
      bh.nav { 'content' }
    end
    expect(html).to include '<ul class="nav navbar-nav">content</ul>'
  end
end
