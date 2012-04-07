require 'spec_helper'

describe WordPressTools::CLI do
  before :each do
    @original_wd = Dir.pwd
    wp_api_response = <<-eof
      upgrade
      http://wordpress.org/download/
      http://wordpress.org/wordpress-3.3.1.zip
      3.3.1
      en_US
      5.2.4
      5.0
    eof
    FakeWeb.register_uri(:get, %r|http://api.wordpress.org/core/version-check/1.5/.*|, :body => wp_api_response)
    FakeWeb.register_uri(:get, "http://wordpress.org/wordpress-3.3.1.zip", :body => File.expand_path('spec/fixtures/wordpress_stub.zip'))
    Dir.chdir('tmp')
  end
  
  context "#new" do
    context "with no arguments" do
      it "downloads a copy of WordPress" do
        WordPressTools::CLI.start ['new']
        File.exists?('wordpress/wp-content/index.php').should eq true
      end

      it "initializes a git repository" do
        WordPressTools::CLI.start ['new']
        File.directory?('wordpress/.git').should eq true
      end
      
      it "doesn't leave a stray 'wordpress' directory" do
        WordPressTools::CLI.start ['new']
        File.directory?('wordpress/wordpress').should eq false
      end
    end
    
    context "with a custom directory name" do
      it "downloads a copy of WordPress in directory 'myapp'" do
        WordPressTools::CLI.start ['new', 'myapp']
        File.exists?('myapp/wp-content/index.php').should eq true
      end
    end
    
    context "with the 'bare' option" do
      it "downloads a copy of WordPress and removes default plugins and themes" do
        WordPressTools::CLI.start ['new', '--bare']
        (File.exists?('wordpress/wp-content/plugins/hello.php') || File.directory?('wordpress/wp-content/themes/twentyeleven')).should eq false
      end
    end
  end
  
  after :each do
    Dir.chdir(@original_wd)
    %w(tmp/wordpress tmp/myapp).each do |dir|
      FileUtils.rm_rf(dir) if File.directory? dir
    end
  end
end