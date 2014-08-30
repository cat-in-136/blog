require 'rubygems'
require 'yaml'
require 'term/ansicolor'

posts_dir = '_posts'
drafts_dir = '_drafts'
deploy_dir = '_deploy'
deploy_branch = 'master'

desc "Draft jekyll site"
task :preview do
  system 'jekyll serve --watch --drafts'
end

desc "Generate jekyll site"
task :generate do
  system 'jekyll build --lsi'
end

desc "Watch the site and regenerate when it changes"
task :watch do
  system 'jekyll serve --watch'
end

desc "Begin a new content"
task :new, :dir, :new_post_ext do |dir, t, args|
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
      'updated' => Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z'),
      'tags' => [],
    }).to_yaml
    post << "---\n"
    post << "<p>\n</p>\n" if new_post_ext
  end
end

desc "Begin a new post in #{posts_dir}"
task :new_post, :title, :new_post_ext do |t, args|
  Rake::Task[:new].invoke(posts_dir, t, args)
end

desc "Begin a new post in #{drafts_dir}"
task :new_draft, :title, :new_post_ext do |t, args|
  Rake::Task[:new].invoke(drafts_dir, t, args)
end

desc "Deploy to github.io"
task :deploy do
  Rake::Task[:generate].execute

  cd "#{deploy_dir}" do
    puts "git pull in #{deploy_dir}... "
    ok_failed system "git pull"
  end

  puts "\nCopy to _site/ to #{deploy_dir}... "
  ok_failed system("rsync -a --delete --exclude .git _site/ #{deploy_dir}")

  cd "#{deploy_dir}" do
    FileUtils.touch '.nojekyll' unless File.exists?('.nojekyll')

    message = "Site updated at #{Time.now} (#{Time.now.utc})"
    puts "Commiting: #{message}"

    ok_failed system("git add -A")
    ok_failed system("git commit -m -m \"#{message}\"")
    ok_failed system("git push origin #{deploy_branch}")
  end
  
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




