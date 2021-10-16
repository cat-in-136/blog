require 'rubygems'
require 'yaml'
require 'term/ansicolor'

posts_dir = '_posts'
drafts_dir = '_drafts'

jekyll_rb = Pathname.new(File.join(Gem.bindir, 'jekyll')).relative_path_from(Pathname.pwd).to_path

desc "Draft jekyll site"
task :preview do
  system "ruby #{jekyll_rb} serve --watch --drafts #{ENV['JEKYLL_ARGS']}"
end

desc "Generate jekyll site"
task :generate do
  system "ruby #{jekyll_rb} build --lsi #{ENV['JEKYLL_ARGS']}"
end

desc "Watch the site and regenerate when it changes"
task :watch do
  system "ruby #{jekyll_rb} serve --watch #{ENV['JEKYLL_ARGS']}"
end

desc "Begin a new content"
task :new, :dir, :title, :new_post_ext do |t, args|
  p args
  if File.directory? args.dir
    dir = args.dir
  else
    abort("dir not found")
  end
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title: ")
  end
  if args.new_post_ext
    new_post_ext = args.new_post_ext
  else
    #new_post_ext = 'md'
    new_post_ext = 'html'
  end

  filename = "#{dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  File.open(filename, 'w') do |post|
    post << ({
      'layout' => 'post',
      'title' => title,
      'date' => Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z'),
      'tags' => [],
    }).to_yaml
    post << "---\n"
    post << "<p>\n</p>\n" if new_post_ext
  end
end

desc "Begin a new post in #{posts_dir}"
task :new_post, :title, :new_post_ext do |t, args|
  Rake::Task[:new].invoke(posts_dir, args.title, args.new_post_ext)
end

desc "Begin a new post in #{drafts_dir}"
task :new_draft, :title, :new_post_ext do |t, args|
  Rake::Task[:new].invoke(drafts_dir, args.title, args.new_post_ext)
end

desc "Update datetime in a given post"
task :touch_post, :path do |t, args|
  abort("File not found: #{args.path}") unless File.exists?(args.path)

  formatter_str = "---\n"
  postbody = ''
  File.open(args.path, 'r') do |f|
    f.flock(File::LOCK_SH)
    abort("YAML front formatter not found") unless f.readline == "---\n"

    in_formatter = true
    f.each_line do |line|
      if in_formatter
        if line == "---\n"
          in_formatter = false
        else
          formatter_str << line
        end
      else
        postbody << line
      end
    end
  end

  require 'time'
  require 'yaml'

  formatter = YAML.load(formatter_str)
  formatter["date"] = Time.now.xmlschema unless formatter["date"]
  formatter["last_modified_at"] = Time.now.xmlschema

  File.open(args.path, 'w') do |f|
    f << YAML.dump(formatter)
    f << "---\n"
    f << postbody
  end
end

desc "Validates _site/"
task :validate do
  require 'rexml/parsers/streamparser'
  require 'rexml/streamlistener'

  class NullStreamListener
    include REXML::StreamListener
  end

  ng_count = 0
  ok_count = 0
  Dir.glob('_site/**/*.html') do |file|
    begin
      l = NullStreamListener.new
      File.open(file, 'r') { |f| REXML::Parsers::StreamParser.new(f, l).parse }
      ok_count = ok_count.succ
    rescue REXML::ParseException => ex
      puts "#{Term::ANSIColor::red}#{Term::ANSIColor::bold}NG#{Term::ANSIColor::clear} #{file}(#{ex.line}:#{ex.position}): #{ex.message.split(/\n/).first}\n"
      ng_count = ng_count.succ
    end
  end
  puts "#{Term::ANSIColor::green}OK:#{ok_count} #{Term::ANSIColor::red}NG:#{ng_count}#{Term::ANSIColor::clear}\n"
  raise 'Not valid' if ng_count > 0
end

def ok_failed(condition)
  if (condition)
    puts "#{Term::ANSIColor::green}#{Term::ANSIColor::bold}OK#{Term::ANSIColor::clear}"
  else
    puts "#{Term::ANSIColor::red}#{Term::ANSIColor::bold}FAILED#{Term::ANSIColor::clear}"
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end
def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end
class String
  def to_url
    self.gsub('&', ' and ').gsub(/[^\w\-\s]/, '').strip.gsub(/\s+/, '-').downcase
  end
end


